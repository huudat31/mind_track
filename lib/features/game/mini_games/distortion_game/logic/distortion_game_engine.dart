import 'dart:convert';
import 'dart:math' as math;
import '../../../models/cognitive_distortion_type.dart';
import '../../../models/distortion_scenario.dart';

/// Một lượt chơi câu hỏi nhận diện méo mó nhận thức
class DistortionScenarioRound {
  final DistortionScenario scenario;
  final List<DistortionType> options;
  final int correctOptionIndex;

  const DistortionScenarioRound({
    required this.scenario,
    required this.options,
    required this.correctOptionIndex,
  });
}

typedef DistortionQuestionRound = DistortionScenarioRound;

/// Engine quản lý logic chọn lọc và tính điểm cho mini-game Nhận Diện Méo Mó Nhận Thức
class DistortionGameEngine {
  final List<DistortionScenario> allScenarios;
  final math.Random _random;

  DistortionGameEngine({
    required this.allScenarios,
    math.Random? random,
  }) : _random = random ?? math.Random();

  /// Parse danh sách tình huống từ chuỗi JSON và kiểm tra tính toàn vẹn (validate schema)
  static List<DistortionScenario> parseScenariosFromJson(String rawJson) {
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw const FormatException('Dữ liệu JSON câu hỏi méo mó nhận thức phải là một danh sách (List).');
    }

    final List<DistortionScenario> result = [];
    for (int i = 0; i < decoded.length; i++) {
      final item = decoded[i];
      if (item is! Map<String, dynamic>) {
        throw FormatException('Phần tử thứ $i trong danh sách tình huống không đúng định dạng Map.');
      }
      result.add(DistortionScenario.fromJson(item));
    }

    if (result.isEmpty) {
      throw const FormatException('Danh sách tình huống méo mó nhận thức không được rỗng.');
    }

    return result;
  }

  /// Chọn các tình huống cho một lượt chơi, ưu tiên contextTag nếu được chỉ định
  List<DistortionScenarioRound> generateSessionRounds({
    String? preferredContextTag,
    int count = 6,
  }) {
    if (allScenarios.isEmpty) return [];

    final targetCount = math.min(count, allScenarios.length);
    final List<DistortionScenario> selected = [];

    // 1. Ưu tiên các câu thuộc preferredContextTag
    if (preferredContextTag != null && preferredContextTag.isNotEmpty) {
      final preferred = allScenarios
          .where((s) => s.contextTag.toLowerCase() == preferredContextTag.toLowerCase())
          .toList();
      preferred.shuffle(_random);
      selected.addAll(preferred.take(targetCount));
    }

    // 2. Nếu chưa đủ số lượng, lấy thêm các câu từ bối cảnh khác
    if (selected.length < targetCount) {
      final remaining = allScenarios.where((s) => !selected.contains(s)).toList();
      remaining.shuffle(_random);
      final needed = targetCount - selected.length;
      selected.addAll(remaining.take(needed));
    }

    // Shuffle lại toàn bộ các câu đã chọn để thứ tự tự nhiên
    selected.shuffle(_random);

    return selected.map((scenario) {
      final options = scenario.getShuffledChoices();
      final correctIndex = options.indexOf(scenario.distortionType);
      return DistortionScenarioRound(
        scenario: scenario,
        options: options,
        correctOptionIndex: correctIndex,
      );
    }).toList();
  }

  /// Tính phần trăm độ chính xác (0 - 100%)
  static int calculateAccuracy(int correctAnswers, int totalQuestions) {
    if (totalQuestions <= 0) return 0;
    return ((correctAnswers / totalQuestions) * 100).round().clamp(0, 100);
  }

  /// Tính sao theo tiêu chuẩn:
  /// - ≥ 90% = 3 sao
  /// - ≥ 75% = 2 sao
  /// - ≥ 50% = 1 sao
  /// - < 50% = 0 sao
  static int calculateStars(int correctAnswers, int totalQuestions) {
    final accuracy = calculateAccuracy(correctAnswers, totalQuestions);
    if (accuracy >= 90) {
      return 3;
    } else if (accuracy >= 75) {
      return 2;
    } else if (accuracy >= 50) {
      return 1;
    } else {
      return 0;
    }
  }
}
