import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_track/core/constants/app_colors.dart';
import '../../../constants/game_strings.dart';
import '../../../models/evidence_card_model.dart';
import '../../../models/game_level.dart';
import '../../../progress/game_progress_provider.dart';
import '../../../widgets/game_scaffold.dart';
import '../../../widgets/muoi_den_widget.dart';
import '../../../widgets/result_dialog.dart';
import '../../../widgets/speech_bubble.dart';
import '../logic/evidence_scale_logic.dart';
import '../widgets/evidence_card_widget.dart';
import '../widgets/scale_beam_painter.dart';
import '../widgets/scale_plate_target.dart';

class EvidenceGameScreen extends ConsumerStatefulWidget {
  final EvidenceScenario? initialScenario;
  final String? preferredContextTag;

  const EvidenceGameScreen({
    super.key,
    this.initialScenario,
    this.preferredContextTag,
  });

  @override
  ConsumerState<EvidenceGameScreen> createState() => _EvidenceGameScreenState();
}

class _EvidenceGameScreenState extends ConsumerState<EvidenceGameScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  EvidenceScaleSession? _session;
  EvidenceCardModel? _selectedCard;
  bool _showingBalancedThought = false;

  @override
  void initState() {
    super.initState();
    _loadScenarioAndStart();
  }

  Future<void> _loadScenarioAndStart() async {
    try {
      EvidenceScenario scenario;
      if (widget.initialScenario != null) {
        scenario = widget.initialScenario!;
      } else {
        final jsonString =
            await rootBundle.loadString('assets/game/evidence_scenarios.json');
        final scenarios = EvidenceScaleSession.parseScenariosFromJson(jsonString);

        if (widget.preferredContextTag != null) {
          final matched = scenarios.where((s) =>
              s.contextTag.toLowerCase() == widget.preferredContextTag!.toLowerCase()).toList();
          scenario = matched.isNotEmpty ? matched.first : scenarios.first;
        } else {
          scenario = scenarios.first;
        }
      }

      if (!mounted) return;
      setState(() {
        _session = EvidenceScaleSession(scenario: scenario);
        _isLoading = false;
        _selectedCard = null;
        _showingBalancedThought = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải tình huống cán cân: $e';
        _isLoading = false;
      });
    }
  }

  void _onCardAccepted(EvidenceCardModel card, EvidenceSide side) {
    if (_session == null) return;

    final success = _session!.tryPlaceCard(card, side);
    if (success) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedCard = null;
      });

      if (_session!.isCompleted) {
        setState(() {
          _showingBalancedThought = true;
        });
      }
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Expanded(child: Text(GameStrings.scaleWrongPlacement)),
            ],
          ),
          backgroundColor: AppColors.accentCoral,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _onAcceptBalancedThought() async {
    if (_session == null) return;

    final accuracy = _session!.calculateFirstAttemptAccuracy();
    final stars = _session!.calculateStars();

    // Lưu tiến trình Level 3
    await ref.read(gameProgressProvider.notifier).markCompleted(
          levelId: 'level_3',
          score: accuracy,
          stars: stars,
        );

    if (!mounted) return;

    ResultDialog.show(
      context: context,
      stars: stars,
      score: accuracy,
      onReplay: () {
        _loadScenarioAndStart();
      },
      onContinue: () {
        Navigator.pop(context, true);
      },
    );
  }

  SootMood get _sootMood {
    if (_session == null) return SootMood.thinking;
    if (_showingBalancedThought) return SootMood.happy;
    if (_session!.rightWeight > _session!.leftWeight) return SootMood.happy;
    if (_session!.leftWeight > _session!.rightWeight) return SootMood.worried;
    return SootMood.thinking;
  }

  @override
  Widget build(BuildContext context) {
    final level = GameLevel.defaultLevels[2];

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

    final session = _session!;
    final scenario = session.scenario;
    final tiltAngle = session.calculateTiltAngle();

    return GameScaffold(
      title: level.title,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Negative Thought Header Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(18),
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
                            GameStrings.evidenceNegativeThoughtHeader,
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
                      '“${scenario.negativeThought}”',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF78350F),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Muội Đen và Bong bóng trạng thái cán cân
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  MuoiDenWidget(mood: _sootMood, size: 68),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SpeechBubble(
                      speakerName: GameStrings.sootName,
                      text: _showingBalancedThought
                          ? 'Chúng mình đã thấy rõ sự thật rồi! Hãy tiếp nhận góc nhìn cân bằng này nhé!'
                          : GameStrings.scaleDropHint,
                      enableTypewriter: false,
                      tailPosition: BubbleTailPosition.left,
                    ),
                  ),
                ],
              ),
            ),

            // Mechanical Scale Area with 2 Plates
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Beam custom painter animated with spring
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: tiltAngle),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    builder: (context, angle, child) {
                      return SizedBox(
                        height: 110,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: ScaleBeamPainter(tiltAngle: angle),
                        ),
                      );
                    },
                  ),

                  // 2 Hanging Plates: Left (Support) & Right (Against)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Đĩa trái: Ủng hộ suy nghĩ tiêu cực
                        Expanded(
                          child: ScalePlateTarget(
                            side: EvidenceSide.support,
                            title: GameStrings.scaleSupportSide,
                            placedCards: session.leftPlateCards,
                            isSelectedTarget: _selectedCard != null,
                            onCardAccepted: (card) =>
                                _onCardAccepted(card, EvidenceSide.support),
                            onTapPlate: () {
                              if (_selectedCard != null) {
                                _onCardAccepted(_selectedCard!, EvidenceSide.support);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Đĩa phải: Bằng chứng ngược lại
                        Expanded(
                          child: ScalePlateTarget(
                            side: EvidenceSide.against,
                            title: GameStrings.scaleAgainstSide,
                            placedCards: session.rightPlateCards,
                            isSelectedTarget: _selectedCard != null,
                            onCardAccepted: (card) =>
                                _onCardAccepted(card, EvidenceSide.against),
                            onTapPlate: () {
                              if (_selectedCard != null) {
                                _onCardAccepted(_selectedCard!, EvidenceSide.against);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Section: Remaining Cards OR Balanced Thought Card
            _showingBalancedThought
                ? _buildBalancedThoughtSection(scenario.balancedThought)
                : _buildRemainingCardsSection(session.remainingCards),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildRemainingCardsSection(List<EvidenceCardModel> remainingCards) {
    if (remainingCards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Thẻ bằng chứng cần cân nhắc (${remainingCards.length}):',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Kéo hoặc chạm để chọn',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...remainingCards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: EvidenceCardWidget(
                  card: card,
                  isSelected: _selectedCard?.id == card.id,
                  onTap: () {
                    setState(() {
                      if (_selectedCard?.id == card.id) {
                        _selectedCard = null;
                      } else {
                        _selectedCard = card;
                      }
                    });
                  },
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBalancedThoughtSection(String balancedThought) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFF0FDF4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFF16A34A), size: 22),
              const SizedBox(width: 8),
              Text(
                GameStrings.balancedThoughtTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF166534),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Text(
              balancedThought,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _onAcceptBalancedThought,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(
                GameStrings.acceptBalancedThought,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
