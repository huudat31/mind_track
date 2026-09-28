class BreathingConstants {
  // Chu kỳ hơi thở 4 - 4 - 6 (tổng 14 giây cho 1 chu kỳ)
  static const int inhaleSeconds = 4;
  static const int holdSeconds = 4;
  static const int exhaleSeconds = 6;
  static const int totalCycleSeconds = inhaleSeconds + holdSeconds + exhaleSeconds; // 14s

  static const int totalCycles = 3; // 3 chu kỳ thở để hoàn thành bài tập

  // Tỷ lệ phần trăm thời gian trong chu kỳ
  static const double inhaleEndProgress = inhaleSeconds / totalCycleSeconds; // ~0.2857
  static const double holdEndProgress = (inhaleSeconds + holdSeconds) / totalCycleSeconds; // ~0.5714
  static const double exhaleEndProgress = 1.0;
}

enum BreathingPhase {
  inhale,
  hold,
  exhale;

  String get label {
    switch (this) {
      case BreathingPhase.inhale:
        return 'Hít vào êm dịu (4s)';
      case BreathingPhase.hold:
        return 'Nín giữ nhẹ nhàng (4s)';
      case BreathingPhase.exhale:
        return 'Thở ra từ tốn (6s)';
    }
  }

  String get instruction {
    switch (this) {
      case BreathingPhase.inhale:
        return 'Giữ ngón tay và hít vào';
      case BreathingPhase.hold:
        return 'Tiếp tục giữ yên ngón tay';
      case BreathingPhase.exhale:
        return 'Thả tay ra và thở đều';
    }
  }
}
