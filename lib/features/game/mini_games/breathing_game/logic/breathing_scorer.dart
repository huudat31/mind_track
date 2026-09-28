import 'dart:math' as math;
import 'breathing_phase.dart';

class BreathingSample {
  final double cycleProgress; // 0.0 -> 1.0
  final bool isUserHolding; // Người chơi đang giữ ngón tay
  final BreathingPhase expectedPhase;

  const BreathingSample({
    required this.cycleProgress,
    required this.isUserHolding,
    required this.expectedPhase,
  });

  /// Kiểm tra xem hành động của người chơi có khớp với pha hiện tại không:
  /// - Pha Inhale (Hít) & Hold (Giữ): người chơi nên giữ ngón tay (isUserHolding == true)
  /// - Pha Exhale (Thở ra): người chơi nên thả ngón tay (isUserHolding == false)
  bool get isSynchronized {
    switch (expectedPhase) {
      case BreathingPhase.inhale:
      case BreathingPhase.hold:
        return isUserHolding;
      case BreathingPhase.exhale:
        return !isUserHolding;
    }
  }
}

class BreathingScorer {
  final List<BreathingSample> _samples = [];

  List<BreathingSample> get samples => List.unmodifiable(_samples);

  void recordSample({
    required double cycleProgress,
    required bool isUserHolding,
  }) {
    final phase = getPhaseFromProgress(cycleProgress);
    _samples.add(BreathingSample(
      cycleProgress: cycleProgress,
      isUserHolding: isUserHolding,
      expectedPhase: phase,
    ));
  }

  static BreathingPhase getPhaseFromProgress(double progress) {
    if (progress < BreathingConstants.inhaleEndProgress) {
      return BreathingPhase.inhale;
    } else if (progress < BreathingConstants.holdEndProgress) {
      return BreathingPhase.hold;
    } else {
      return BreathingPhase.exhale;
    }
  }

  /// Tính toán độ đồng bộ phần trăm (0 - 100%)
  int calculateAccuracy() {
    if (_samples.isEmpty) return 100; // Mặc định nếu không ghi nhận được mẫu

    int correctSamples = 0;
    for (final s in _samples) {
      if (s.isSynchronized) {
        correctSamples++;
      }
    }

    final ratio = correctSamples / _samples.length;
    return (ratio * 100).round().clamp(0, 100);
  }

  /// Quy đổi số sao theo tiêu chuẩn:
  /// - 1 sao = Hoàn thành bài tập (dù độ khớp thấp)
  /// - 2 sao = Độ khớp > 60%
  /// - 3 sao = Độ khớp > 85%
  int calculateStars() {
    final accuracy = calculateAccuracy();
    if (accuracy >= 85) {
      return 3;
    } else if (accuracy >= 60) {
      return 2;
    } else {
      return math.max(1, 1); // Luôn tặng ít nhất 1 sao khi hoàn thành
    }
  }

  void reset() {
    _samples.clear();
  }
}
