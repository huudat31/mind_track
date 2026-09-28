import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_track/core/constants/app_colors.dart';
import '../../../constants/game_strings.dart';
import '../../../models/cognitive_distortion_type.dart';
import '../../../models/distortion_question.dart';
import '../../../models/game_level.dart';
import '../../../progress/game_progress_provider.dart';
import '../../../widgets/game_scaffold.dart';
import '../../../widgets/muoi_den_widget.dart';
import '../../../widgets/result_dialog.dart';
import '../../../widgets/speech_bubble.dart';
import '../logic/distortion_game_engine.dart';
import '../widgets/distortion_choice_button.dart';
import '../widgets/reframe_suggestion_card.dart';

class DistortionGameScreen extends ConsumerStatefulWidget {
  final List<DistortionQuestion>? initialQuestions;
  final String? preferredContextTag;

  const DistortionGameScreen({
    super.key,
    this.initialQuestions,
    this.preferredContextTag,
  });

  @override
  ConsumerState<DistortionGameScreen> createState() => _DistortionGameScreenState();
}

class _DistortionGameScreenState extends ConsumerState<DistortionGameScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<DistortionQuestionRound> _rounds = [];
  int _currentRoundIndex = 0;
  int _correctCount = 0;

  CognitiveDistortionType? _selectedOption;
  bool _hasAnsweredCurrent = false;
  bool _isAnswerCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadQuestionsAndStart();
  }

  Future<void> _loadQuestionsAndStart() async {
    try {
      List<DistortionQuestion> questions;
      if (widget.initialQuestions != null && widget.initialQuestions!.isNotEmpty) {
        questions = widget.initialQuestions!;
      } else {
        final jsonString =
            await rootBundle.loadString('assets/game/distortion_questions.json');
        questions = DistortionGameEngine.parseQuestionsFromJson(jsonString);
      }

      final engine = DistortionGameEngine(allQuestions: questions);
      final sessionRounds = engine.generateSessionRounds(
        preferredContextTag: widget.preferredContextTag,
        count: 8,
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

  void _onOptionSelected(CognitiveDistortionType option) {
    if (_hasAnsweredCurrent) return;

    final currentRound = _rounds[_currentRoundIndex];
    final isCorrect = option == currentRound.question.correctType;

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
        _loadQuestionsAndStart();
      },
      onContinue: () {
        Navigator.pop(context, true);
      },
    );
  }

  SootMood get _sootMood {
    if (!_hasAnsweredCurrent) return SootMood.worried;
    if (_isAnswerCorrect) return SootMood.happy;
    return SootMood.thinking;
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
    final question = currentRound.question;

    return GameScaffold(
      title: level.title,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            // Question Counter Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Câu ${_currentRoundIndex + 1} / ${_rounds.length}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Đúng: $_correctCount',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
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
            const SizedBox(height: 18),

            // Muội Đen & Suy nghĩ tự động
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MuoiDenWidget(mood: _sootMood, size: 76),
                const SizedBox(width: 12),
                Expanded(
                  child: SpeechBubble(
                    speakerName: GameStrings.sootName,
                    text: '“${question.thought}”',
                    enableTypewriter: false,
                    tailPosition: BubbleTailPosition.left,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Text(
              GameStrings.distortionInstruction,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // 4 Option Buttons
            ...currentRound.options.map((option) {
              ChoiceFeedbackState state = ChoiceFeedbackState.idle;
              if (_hasAnsweredCurrent) {
                if (option == question.correctType) {
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

            // Reframe Suggestion Card when answered
            if (_hasAnsweredCurrent) ...[
              const SizedBox(height: 12),
              ReframeSuggestionCard(
                question: question,
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
