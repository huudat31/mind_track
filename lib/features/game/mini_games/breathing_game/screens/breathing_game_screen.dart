import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_track/core/constants/app_colors.dart';
import '../../../constants/game_strings.dart';
import '../../../models/game_level.dart';
import '../../../progress/game_progress_provider.dart';
import '../../../widgets/game_scaffold.dart';
import '../../../widgets/muoi_den_widget.dart';
import '../../../widgets/result_dialog.dart';
import '../../../widgets/speech_bubble.dart';
import '../logic/breathing_phase.dart';
import '../logic/breathing_scorer.dart';
import '../widgets/breathing_circle_widget.dart';
import 'breathing_tutorial_dialog.dart';

class BreathingGameScreen extends ConsumerStatefulWidget {
  final bool showTutorialInitially;

  const BreathingGameScreen({
    super.key,
    this.showTutorialInitially = true,
  });

  @override
  ConsumerState<BreathingGameScreen> createState() => _BreathingGameScreenState();
}

class _BreathingGameScreenState extends ConsumerState<BreathingGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  final BreathingScorer _scorer = BreathingScorer();

  int _currentCycle = 1;
  bool _isUserHolding = false;
  bool _isTapMode = false;
  bool _isGameCompleted = false;
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  Timer? _sampleTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: BreathingConstants.totalCycleSeconds),
    );

    _controller.addListener(_onTick);
    _controller.addStatusListener(_onStatusChanged);

    if (widget.showTutorialInitially) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorial();
      });
    } else {
      _startSession();
    }
  }

  void _showTutorial() {
    BreathingTutorialDialog.show(context, onStart: _startSession);
  }

  void _startSession() {
    _currentCycle = 1;
    _isGameCompleted = false;
    _scorer.reset();
    _controller.forward(from: 0.0);

    // Ghi nhận mẫu định kỳ mỗi 250ms để tính toán độ đồng bộ
    _sampleTimer?.cancel();
    _sampleTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_controller.isAnimating && !_isGameCompleted) {
        _scorer.recordSample(
          cycleProgress: _controller.value,
          isUserHolding: _isUserHolding,
        );
      }
    });
  }

  void _onTick() {
    final newPhase = BreathingScorer.getPhaseFromProgress(_controller.value);
    if (newPhase != _currentPhase) {
      setState(() {
        _currentPhase = newPhase;
      });
      // Rung phản hồi nhẹ khi chuyển pha
      HapticFeedback.lightImpact();
    } else {
      setState(() {});
    }
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (_currentCycle < BreathingConstants.totalCycles) {
        setState(() {
          _currentCycle++;
        });
        _controller.forward(from: 0.0);
      } else {
        _onSessionFinished();
      }
    }
  }

  void _onSessionFinished() async {
    _sampleTimer?.cancel();
    setState(() {
      _isGameCompleted = true;
    });

    final accuracy = _scorer.calculateAccuracy();
    final stars = _scorer.calculateStars();

    // Lưu kết quả vào tiến trình
    await ref.read(gameProgressProvider.notifier).markCompleted(
          levelId: 'level_1',
          score: accuracy,
          stars: stars,
        );

    if (!mounted) return;

    ResultDialog.show(
      context: context,
      stars: stars,
      score: accuracy,
      onReplay: () {
        _startSession();
      },
      onContinue: () {
        Navigator.pop(context, true);
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!_isGameCompleted && !_controller.isAnimating) {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sampleTimer?.cancel();
    _controller.removeListener(_onTick);
    _controller.removeStatusListener(_onStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  SootMood get _sootMood {
    if (_isGameCompleted) return SootMood.happy;
    if (_currentCycle >= 3) return SootMood.calm;
    if (_currentCycle == 2) return SootMood.thinking;
    return SootMood.worried;
  }

  @override
  Widget build(BuildContext context) {
    final level = GameLevel.defaultLevels[0];

    return GameScaffold(
      title: level.title,
      trailing: IconButton(
        icon: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
        tooltip: GameStrings.breathingTutorialTitle,
        onPressed: () {
          _controller.stop();
          BreathingTutorialDialog.show(context, onStart: () {
            if (!_isGameCompleted) _controller.forward();
          });
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Companion Dialogue
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  MuoiDenWidget(mood: _sootMood, size: 70),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SpeechBubble(
                      speakerName: GameStrings.sootName,
                      text: _currentPhase.instruction,
                      enableTypewriter: false,
                      tailPosition: BubbleTailPosition.left,
                    ),
                  ),
                ],
              ),
            ),

            // Cycle Counter Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Vòng thở: $_currentCycle / ${BreathingConstants.totalCycles}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),

            // Animated Breathing Circle Center
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BreathingCircleWidget(
                          cycleProgress: _controller.value,
                          isUserHolding: _isUserHolding,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _currentPhase.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Interactive Touch Control Area
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isTapMode)
                    // Chế độ chạm nhịp
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isUserHolding ? AppColors.primaryDark : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isUserHolding = !_isUserHolding;
                          });
                          HapticFeedback.selectionClick();
                        },
                        child: Text(
                          _isUserHolding ? 'Đang giữ hơi' : 'Chạm để hít/giữ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    // Chế độ đè giữ ngón tay (Hold & Release)
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() => _isUserHolding = true);
                        HapticFeedback.selectionClick();
                      },
                      onTapUp: (_) {
                        setState(() => _isUserHolding = false);
                      },
                      onTapCancel: () {
                        setState(() => _isUserHolding = false);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          color: _isUserHolding ? AppColors.primaryDark : AppColors.primary,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isUserHolding ? Icons.fingerprint_rounded : Icons.touch_app_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _isUserHolding ? 'Đang giữ ngón tay...' : 'Chạm & Giữ khi hít vào',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Nút chuyển đổi chế độ Chạm nhịp / Đè giữ
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isTapMode = !_isTapMode;
                        _isUserHolding = false;
                      });
                    },
                    child: Text(
                      _isTapMode ? 'Chuyển sang chế độ Giữ ngón tay' : 'Khó giữ ngón tay? Chuyển sang Chạm nhịp',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
