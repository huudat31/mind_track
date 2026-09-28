import 'dart:convert';
import 'dart:math' as math;
import '../../../models/evidence_card_model.dart';

class EvidenceScaleSession {
  final EvidenceScenario scenario;
  final List<EvidenceCardModel> remainingCards;
  final List<EvidenceCardModel> leftPlateCards; // Đĩa ủng hộ (support)
  final List<EvidenceCardModel> rightPlateCards; // Đĩa ngược lại (against)
  final Set<String> firstAttemptFailedCardIds; // Những thẻ từng đặt sai ở lần đầu

  EvidenceScaleSession({
    required this.scenario,
    List<EvidenceCardModel>? remainingCards,
    List<EvidenceCardModel>? leftPlateCards,
    List<EvidenceCardModel>? rightPlateCards,
    Set<String>? firstAttemptFailedCardIds,
  })  : remainingCards = remainingCards ?? List.from(scenario.evidenceCards),
        leftPlateCards = leftPlateCards ?? [],
        rightPlateCards = rightPlateCards ?? [],
        firstAttemptFailedCardIds = firstAttemptFailedCardIds ?? {};

  bool get isCompleted => remainingCards.isEmpty;

  /// Đặt thẻ vào đĩa cân được chọn (`targetSide` là support hoặc against):
  /// - Thẻ `neutral`: hợp lệ cho cả hai đĩa.
  /// - Thẻ `support`: chỉ hợp lệ cho đĩa `support`.
  /// - Thẻ `against`: chỉ hợp lệ cho đĩa `against`.
  bool tryPlaceCard(EvidenceCardModel card, EvidenceSide targetSide) {
    final bool isCorrect;
    if (card.side == EvidenceSide.neutral) {
      isCorrect = true;
    } else {
      isCorrect = card.side == targetSide;
    }

    if (!isCorrect) {
      firstAttemptFailedCardIds.add(card.id);
      return false;
    }

    remainingCards.removeWhere((c) => c.id == card.id);
    if (targetSide == EvidenceSide.support) {
      leftPlateCards.add(card);
    } else {
      rightPlateCards.add(card);
    }
    return true;
  }

  /// Trọng lượng đĩa trái (ủng hộ)
  int get leftWeight => leftPlateCards.where((c) => c.side == EvidenceSide.support).length;

  /// Trọng lượng đĩa phải (ngược lại)
  int get rightWeight => rightPlateCards.where((c) => c.side == EvidenceSide.against).length;

  /// Góc nghiêng cán cân tính bằng radian:
  /// - Giá trị dương: đĩa phải nặng hơn (nghiêng về bằng chứng ngược lại).
  /// - Giá trị âm: đĩa trái nặng hơn (nghiêng về suy nghĩ tiêu cực).
  /// - Góc tối đa: ~14 độ (0.24 radian).
  double calculateTiltAngle() {
    final diff = rightWeight - leftWeight;
    // Giới hạn độ chênh lệch tối đa 4 đơn vị
    final normalized = (diff / 4.0).clamp(-1.0, 1.0);
    return normalized * (14.0 * math.pi / 180.0);
  }

  /// Tính phần trăm thẻ đặt đúng ngay lần đầu
  int calculateFirstAttemptAccuracy() {
    final total = scenario.evidenceCards.length;
    if (total == 0) return 100;
    final failedCount = firstAttemptFailedCardIds.length;
    final successFirstCount = total - failedCount;
    return ((successFirstCount / total) * 100).round().clamp(0, 100);
  }

  /// Tính sao:
  /// - 100% đúng ngay lần đầu = 3 sao
  /// - ≥ 70% đúng ngay lần đầu = 2 sao
  /// - < 70% = 1 sao (hoàn thành bài tập)
  int calculateStars() {
    final accuracy = calculateFirstAttemptAccuracy();
    if (accuracy >= 100) {
      return 3;
    } else if (accuracy >= 70) {
      return 2;
    } else {
      return 1;
    }
  }

  static List<EvidenceScenario> parseScenariosFromJson(String rawJson) {
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw const FormatException('Dữ liệu JSON kịch bản cán cân phải là List.');
    }
    return decoded.map((item) => EvidenceScenario.fromJson(item as Map<String, dynamic>)).toList();
  }
}
