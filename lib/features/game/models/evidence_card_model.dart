enum EvidenceSide {
  support, // Ủng hộ suy nghĩ tiêu cực
  against, // Bằng chứng ngược lại (phản bác suy nghĩ tiêu cực)
  neutral; // Trung tính (thả đĩa nào cũng hợp lệ)

  String get displayName {
    switch (this) {
      case EvidenceSide.support:
        return 'Ủng hộ suy nghĩ tiêu cực';
      case EvidenceSide.against:
        return 'Bằng chứng ngược lại';
      case EvidenceSide.neutral:
        return 'Thông tin trung tính';
    }
  }

  static EvidenceSide? fromString(String key) {
    switch (key.trim().toLowerCase()) {
      case 'support':
      case 'ung_ho':
        return EvidenceSide.support;
      case 'against':
      case 'nguoc_lai':
        return EvidenceSide.against;
      case 'neutral':
      case 'trung_tinh':
        return EvidenceSide.neutral;
      default:
        return null;
    }
  }
}

class EvidenceCardModel {
  final String id;
  final String text;
  final EvidenceSide side;

  const EvidenceCardModel({
    required this.id,
    required this.text,
    required this.side,
  });

  factory EvidenceCardModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      throw const FormatException('Thẻ bằng chứng thiếu trường "id".');
    }

    final text = json['text'] as String?;
    if (text == null || text.isEmpty) {
      throw FormatException('Thẻ bằng chứng $id thiếu trường "text".');
    }

    final rawSide = json['side'] as String?;
    final side = EvidenceSide.fromString(rawSide ?? '');
    if (side == null) {
      throw FormatException('Thẻ bằng chứng $id có "side" không hợp lệ: $rawSide');
    }

    return EvidenceCardModel(
      id: id,
      text: text,
      side: side,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'side': side.name,
    };
  }
}

class EvidenceScenario {
  final String id;
  final String contextTag; // hoc_tap, gia_dinh, tinh_cam, mang_xa_hoi
  final String negativeThought;
  final List<EvidenceCardModel> evidenceCards;
  final String balancedThought;

  const EvidenceScenario({
    required this.id,
    required this.contextTag,
    required this.negativeThought,
    required this.evidenceCards,
    required this.balancedThought,
  });

  factory EvidenceScenario.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      throw const FormatException('Tình huống cán cân thiếu trường "id".');
    }

    final contextTag = json['contextTag'] as String?;
    if (contextTag == null || contextTag.isEmpty) {
      throw FormatException('Tình huống $id thiếu trường "contextTag".');
    }

    final negativeThought = json['negativeThought'] as String?;
    if (negativeThought == null || negativeThought.isEmpty) {
      throw FormatException('Tình huống $id thiếu trường "negativeThought".');
    }

    final rawCards = json['evidenceCards'] as List<dynamic>?;
    if (rawCards == null || rawCards.isEmpty) {
      throw FormatException('Tình huống $id phải có ít nhất 1 thẻ bằng chứng.');
    }

    final cards = rawCards.map((c) => EvidenceCardModel.fromJson(c as Map<String, dynamic>)).toList();
    final balancedThought = json['balancedThought'] as String? ?? '';

    return EvidenceScenario(
      id: id,
      contextTag: contextTag,
      negativeThought: negativeThought,
      evidenceCards: cards,
      balancedThought: balancedThought,
    );
  }
}
