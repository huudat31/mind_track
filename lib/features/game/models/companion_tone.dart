/// Các mức giọng điệu của Muội Đen
enum ToneType {
  chill('chill'),
  friendly('friendly'),
  calm('calm');

  final String id;
  const ToneType(this.id);

  static ToneType fromId(String id) {
    return values.firstWhere(
      (t) => t.id == id,
      orElse: () => throw FormatException('ToneType không hợp lệ: "$id"'),
    );
  }

  String get displayName {
    switch (this) {
      case ToneType.chill:
        return 'Chill (Hài hước, tự nhiên)';
      case ToneType.friendly:
        return 'Thân thiện (Ấm áp, kiên nhẫn)';
      case ToneType.calm:
        return 'Điềm tĩnh (Khách quan, nghiêm túc)';
    }
  }
}

/// Lời dẫn mở đầu của Muội Đen hỗ trợ 3 tone giọng với fallback nghiêm ngặt
class CompanionIntro {
  final Map<ToneType, String> intros;

  const CompanionIntro(this.intros);

  factory CompanionIntro.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('chill') || !json.containsKey('friendly') || !json.containsKey('calm')) {
      throw FormatException('companion_intro thiếu tone bắt buộc: ${json.keys.toList()}');
    }
    return CompanionIntro({
      ToneType.chill: json['chill'] as String,
      ToneType.friendly: json['friendly'] as String,
      ToneType.calm: json['calm'] as String,
    });
  }

  /// Fallback một chiều nghiêm ngặt: chill -> friendly -> calm
  String getIntro(ToneType preferredTone) {
    return intros[preferredTone] ??
        intros[ToneType.friendly] ??
        intros[ToneType.calm] ??
        (throw StateError('companion_intro không có tone nào hợp lệ'));
  }
}
