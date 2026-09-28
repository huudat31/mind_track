import 'package:flutter/material.dart';
import 'package:mind_track/core/constants/app_colors.dart';
import '../logic/breathing_phase.dart';
import '../logic/breathing_scorer.dart';

class BreathingCircleWidget extends StatelessWidget {
  final double cycleProgress; // 0.0 -> 1.0
  final bool isUserHolding;

  const BreathingCircleWidget({
    super.key,
    required this.cycleProgress,
    this.isUserHolding = false,
  });

  /// Tính scale theo chu kỳ 4-4-6 (Inhale: 1.0 -> 1.45, Hold: 1.45, Exhale: 1.45 -> 1.0)
  double get _currentScale {
    if (cycleProgress <= BreathingConstants.inhaleEndProgress) {
      // 0.0 -> ~0.2857: Inhale
      final t = cycleProgress / BreathingConstants.inhaleEndProgress;
      return 1.0 + (0.45 * Curves.easeInOut.transform(t));
    } else if (cycleProgress <= BreathingConstants.holdEndProgress) {
      // ~0.2857 -> ~0.5714: Hold
      return 1.45;
    } else {
      // ~0.5714 -> 1.0: Exhale
      final t = (cycleProgress - BreathingConstants.holdEndProgress) /
          (1.0 - BreathingConstants.holdEndProgress);
      return 1.45 - (0.45 * Curves.easeInOut.transform(t));
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final scale = disableAnim ? 1.2 : _currentScale;

    final phase = BreathingScorer.getPhaseFromProgress(cycleProgress);
    Color ringColor;
    switch (phase) {
      case BreathingPhase.inhale:
        ringColor = AppColors.primaryLight;
        break;
      case BreathingPhase.hold:
        ringColor = const Color(0xFFF4A261);
        break;
      case BreathingPhase.exhale:
        ringColor = AppColors.primary;
        break;
    }

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 190,
        height: 190,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              ringColor.withValues(alpha: 0.35),
              ringColor.withValues(alpha: 0.12),
              Colors.transparent,
            ],
            stops: const [0.45, 0.75, 1.0],
          ),
        ),
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ringColor,
              boxShadow: [
                BoxShadow(
                  color: ringColor.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              phase == BreathingPhase.hold ? Icons.pause_rounded : Icons.air_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
        ),
      ),
    );
  }
}
