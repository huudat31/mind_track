import 'dart:convert';
import 'dart:math' as math;
import '../../../models/cognitive_distortion_type.dart';
import '../../../models/distortion_question.dart';

class DistortionQuestionRound {
  final DistortionQuestion question;
  final List<CognitiveDistortionType> options;
  final int correctOptionIndex;

  const DistortionQuestionRound({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });
}

class DistortionGameEngine {
  final List<DistortionQuestion> allQuestions;
  final math.Random _random;

  DistortionGameEngine({
    required this.allQuestions,
    math.Random? random,
  }) : _random = random ?? math.Random();

  /// Parse danh sách câu hỏi từ chuỗi JSON và kiểm tra tính toàn vẹn (validate schema)
  static List<DistortionQuestion> parseQuestionsFromJson(String rawJson) {
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw const FormatException('Dữ liệu JSON câu hỏi méo mó nhận thức phải là một danh sách (List).');
    }

    final List<DistortionQuestion> result = [];
    for (int i = 0; i < decoded.length; i++) {
      final item = decoded[i];
      if (item is! Map<String, dynamic>) {
        throw FormatException('Phần tử thứ $i trong danh sách câu hỏi không đúng định dạng Map.');
      }
      result.add(DistortionQuestion.fromJson(item));
    }

    if (result.isEmpty) {
      throw const FormatException('Danh sách câu hỏi méo mó nhận thức không được rỗng.');
    }

    return result;
  }

  /// Chọn 8 câu hỏi cho một lượt chơi, ưu tiên contextTag nếu được chỉ định
  List<DistortionQuestionRound> generateSessionRounds({
    String? preferredContextTag,
    int count = 8,
  }) {
    if (allQuestions.isEmpty) return [];

    final targetCount = math.min(count, allQuestions.length);
    final List<DistortionQuestion> selected = [];

    // 1. Ưu tiên các câu thuộc preferredContextTag
    if (preferredContextTag != null && preferredContextTag.isNotEmpty) {
      final preferred = allQuestions
          .where((q) => q.contextTag.toLowerCase() == preferredContextTag.toLowerCase())
          .toList();
      preferred.shuffle(_random);
      selected.addAll(preferred.take(targetCount));
    }

    // 2. Nếu chưa đủ số lượng, lấy thêm các câu từ bối cảnh khác
    if (selected.length < targetCount) {
      final remaining = allQuestions.where((q) => !selected.contains(q)).toList();
      remaining.shuffle(_random);
      final needed = targetCount - selected.length;
      selected.addAll(remaining.take(needed));
    }

    // Shuffle lại toàn bộ các câu đã chọn để thứ tự tự nhiên
    selected.shuffle(_random);

    return selected.map((q) => _createRoundForQuestion(q)).toList();
  }

  DistortionQuestionRound _createRoundForQuestion(DistortionQuestion question) {
    // Lấy đáp án đúng
    final correct = question.correctType;

    // Lấy 2 hoặc 3 đáp án nhiễu khác
    final distractors = CognitiveDistortionType.values.where((t) => t != correct).toList();
    distractors.shuffle(_random);
    final chosenDistractors = distractors.take(3).toList();

    // Ghép và xáo trộn vị trí
    final options = [correct, ...chosenDistractors];
    options.shuffle(_random);

    final correctIndex = options.indexOf(correct);

    return DistortionQuestionRound(
      question: question,
      options: options,
      correctOptionIndex: correctIndex,
    );
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
