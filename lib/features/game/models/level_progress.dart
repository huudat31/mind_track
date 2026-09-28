enum LevelStatus {
  locked,
  unlocked,
  completed;

  String toJson() => name;

  static LevelStatus fromJson(String? value) {
    if (value == null) return LevelStatus.locked;
    return LevelStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LevelStatus.locked,
    );
  }
}

class LevelProgress {
  final String levelId;
  final LevelStatus status;
  final int bestScore;
  final int stars; // 0 - 3
  final int attempts;
  final DateTime? completedAt;

  const LevelProgress({
    required this.levelId,
    required this.status,
    this.bestScore = 0,
    this.stars = 0,
    this.attempts = 0,
    this.completedAt,
  });

  bool get isLocked => status == LevelStatus.locked;
  bool get isUnlocked => status == LevelStatus.unlocked;
  bool get isCompleted => status == LevelStatus.completed;

  LevelProgress copyWith({
    String? levelId,
    LevelStatus? status,
    int? bestScore,
    int? stars,
    int? attempts,
    DateTime? completedAt,
  }) {
    return LevelProgress(
      levelId: levelId ?? this.levelId,
      status: status ?? this.status,
      bestScore: bestScore ?? this.bestScore,
      stars: stars ?? this.stars,
      attempts: attempts ?? this.attempts,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'status': status.toJson(),
      'bestScore': bestScore,
      'stars': stars,
      'attempts': attempts,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      levelId: json['levelId'] as String? ?? '',
      status: LevelStatus.fromJson(json['status'] as String?),
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
      stars: ((json['stars'] as num?)?.toInt() ?? 0).clamp(0, 3),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }

  /// Khởi tạo trạng thái mặc định cho một màn chơi
  factory LevelProgress.initial(String levelId, {bool isUnlocked = false}) {
    return LevelProgress(
      levelId: levelId,
      status: isUnlocked ? LevelStatus.unlocked : LevelStatus.locked,
      bestScore: 0,
      stars: 0,
      attempts: 0,
      completedAt: null,
    );
  }
}
