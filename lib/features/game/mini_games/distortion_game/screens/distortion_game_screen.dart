import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../constants/game_strings.dart';
import '../../../models/cognitive_distortion_type.dart';
import '../../../models/companion_tone.dart';
import '../../../models/distortion_scenario.dart';
import '../../../models/game_level.dart';
import '../../../progress/game_progress_provider.dart';
import '../../../widgets/game_scaffold.dart';
import '../../../widgets/muoi_den_widget.dart';
import '../../../widgets/result_dialog.dart';
import '../../../widgets/speech_bubble.dart';
import '../logic/distortion_game_engine.dart';
import '../widgets/distortion_choice_button.dart';
import '../widgets/mock_ui_display_widget.dart';
import '../widgets/reframe_suggestion_card.dart';

class DistortionGameScreen extends ConsumerStatefulWidget {
  final List<DistortionScenario>? initialScenarios;
  final String? preferredContextTag;
  final ToneType initialTone;

  const DistortionGameScreen({
    super.key,
    this.initialScenarios,
    this.preferredContextTag,
    this.initialTone = ToneType.friendly,
  });

  @override
  ConsumerState<DistortionGameScreen> createState() => _DistortionGameScreenState();
}

class _DistortionGameScreenState extends ConsumerState<DistortionGameScreen> {
  static const String _tonePrefKey = 'game_user_tone_preference_v1';

  bool _isLoading = true;
  String? _errorMessage;
  List<DistortionScenarioRound> _rounds = [];
  int _currentRoundIndex = 0;
  int _correctCount = 0;
  ToneType _currentTone = ToneType.friendly;

  DistortionType? _selectedOption;
  bool _hasAnsweredCurrent = false;
  bool _isAnswerCorrect = false;

  @override
  void initState() {
    super.initState();
    _currentTone = widget.initialTone;
    _initToneAndLoadScenarios();
  }

  Future<void> _initToneAndLoadScenarios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToneId = prefs.getString(_tonePrefKey);
      if (savedToneId != null) {
        try {
          _currentTone = ToneType.fromId(savedToneId);
        } catch (_) {}
      }

      await _loadScenariosAndStart();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải câu hỏi: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadScenariosAndStart() async {
    try {
      List<DistortionScenario> scenarios;
      if (widget.initialScenarios != null && widget.initialScenarios!.isNotEmpty) {
        scenarios = widget.initialScenarios!;
      } else {
        final jsonString =
            await rootBundle.loadString('assets/game/distortion_questions.json');
        scenarios = DistortionGameEngine.parseScenariosFromJson(jsonString);
      }

      final engine = DistortionGameEngine(allScenarios: scenarios);
      final sessionRounds = engine.generateSessionRounds(
        preferredContextTag: widget.preferredContextTag,
        count: 6,
      );

      if (!mounted) return;
      setState(() {
        _rounds = sessionRounds;
        _isLoading = false;
        _currentRoundIndex = 0;
        _correctCount = 0;
        _hasAnsweredCurrent = false;
        _selectedOption = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải câu hỏi: $e';
        _isLoading = false;
      });
    }
  }

  void _onOptionSelected(DistortionType option) {
    if (_hasAnsweredCurrent) return;

    final currentRound = _rounds[_currentRoundIndex];
    final isCorrect = option == currentRound.scenario.distortionType;

    HapticFeedback.mediumImpact();

    setState(() {
      _selectedOption = option;
      _hasAnsweredCurrent = true;
      _isAnswerCorrect = isCorrect;
      if (isCorrect) {
        _correctCount++;
      }
    });
  }

  void _onNextQuestion() async {
    if (_currentRoundIndex < _rounds.length - 1) {
      setState(() {
        _currentRoundIndex++;
        _hasAnsweredCurrent = false;
        _selectedOption = null;
      });
    } else {
      _onGameFinished();
    }
  }

  void _onGameFinished() async {
    final accuracy = DistortionGameEngine.calculateAccuracy(
      _correctCount,
      _rounds.length,
    );
    final stars = DistortionGameEngine.calculateStars(
      _correctCount,
      _rounds.length,
    );

    // Lưu tiến trình Level 2
    await ref.read(gameProgressProvider.notifier).markCompleted(
          levelId: 'level_2',
          score: accuracy,
          stars: stars,
        );

    if (!mounted) return;

    ResultDialog.show(
      context: context,
      stars: stars,
      score: accuracy,
      onReplay: () {
        _loadScenariosAndStart();
      },
      onContinue: () {
        Navigator.pop(context, true);
      },
    );
  }

  void _changeTone(ToneType newTone) async {
    setState(() => _currentTone = newTone);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tonePrefKey, newTone.id);
  }

  SootMood get _sootMood {
    if (!_hasAnsweredCurrent) return SootMood.thinking;
    if (_isAnswerCorrect) return SootMood.happy;
    return SootMood.calm;
  }

  @override
  Widget build(BuildContext context) {
    final level = GameLevel.defaultLevels[1];

    if (_isLoading) {
      return GameScaffold(
        title: level.title,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return GameScaffold(
        title: level.title,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.accentCoral),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (_rounds.isEmpty) {
      return GameScaffold(
        title: level.title,
        body: const Center(child: Text('Không có câu hỏi khả dụng.')),
      );
    }

    final currentRound = _rounds[_currentRoundIndex];
    final scenario = currentRound.scenario;
    final companionText = scenario.companionIntro.getIntro(_currentTone);

    return GameScaffold(
      title: level.title,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            // Top Bar: Question Counter + Tone Selector Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Câu ${_currentRoundIndex + 1} / ${_rounds.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Tone Dial Popup Menu
                PopupMenuButton<ToneType>(
                  tooltip: 'Đổi giọng điệu Muội Đen',
                  initialValue: _currentTone,
                  onSelected: _changeTone,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Giọng: ${_currentTone.name.toUpperCase()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: ToneType.chill,
                      child: Text(ToneType.chill.displayName),
                    ),
                    PopupMenuItem(
                      value: ToneType.friendly,
                      child: Text(ToneType.friendly.displayName),
                    ),
                    PopupMenuItem(
                      value: ToneType.calm,
                      child: Text(ToneType.calm.displayName),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (_currentRoundIndex + 1) / _rounds.length,
                minHeight: 6,
                backgroundColor: AppColors.surfaceMuted,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),

            // 1. Mock UI Display Widget (Giao diện đời thực)
            MockUiDisplayWidget(mockUi: scenario.mockUi),
            const SizedBox(height: 14),

            // 2. Suy nghĩ tự động (Thought Box)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.psychology_alt_outlined,
                        size: 16,
                        color: Color(0xFFB45309),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Suy nghĩ lóe lên trong đầu:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '“${scenario.thought}”',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF78350F),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Muội Đen & Lời dẫn theo Tone đã chọn
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MuoiDenWidget(mood: _sootMood, size: 68),
                const SizedBox(width: 10),
                Expanded(
                  child: SpeechBubble(
                    speakerName: GameStrings.sootName,
                    text: companionText,
                    enableTypewriter: false,
                    tailPosition: BubbleTailPosition.left,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tiêu đề câu hỏi
            Text(
              GameStrings.distortionInstruction,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // 4 Option Buttons (Đã được xáo trộn)
            ...currentRound.options.map((option) {
              ChoiceFeedbackState state = ChoiceFeedbackState.idle;
              if (_hasAnsweredCurrent) {
                if (option == scenario.distortionType) {
                  state = ChoiceFeedbackState.correct;
                } else if (option == _selectedOption) {
                  state = ChoiceFeedbackState.wrong;
                }
              }

              return DistortionChoiceButton(
                type: option,
                isSelected: _selectedOption == option,
                feedbackState: state,
                onTap: () => _onOptionSelected(option),
              );
            }),

            // 4. Reframe Suggestion Card khi đã trả lời
            if (_hasAnsweredCurrent) ...[
              const SizedBox(height: 12),
              ReframeSuggestionCard(
                scenario: scenario,
                isCorrect: _isAnswerCorrect,
                onNext: _onNextQuestion,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
