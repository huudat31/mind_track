import 'cognitive_distortion_type.dart';

class DistortionQuestion {
  final String id;
  final String contextTag; // 'hoc_tap', 'gia_dinh', 'tinh_cam', 'mang_xa_hoi'
  final String thought;
  final CognitiveDistortionType correctType;
  final String explanation;
  final String reframeSuggestion;

  const DistortionQuestion({
    required this.id,
    required this.contextTag,
    required this.thought,
    required this.correctType,
    required this.explanation,
    required this.reframeSuggestion,
  });

  factory DistortionQuestion.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      throw const FormatException('Trường "id" trong câu hỏi méo mó nhận thức bị thiếu hoặc rỗng.');
    }

    final contextTag = json['contextTag'] as String?;
    if (contextTag == null || contextTag.isEmpty) {
      throw FormatException('Câu hỏi $id bị thiếu trường "contextTag".');
    }

    final thought = json['thought'] as String?;
    if (thought == null || thought.isEmpty) {
      throw FormatException('Câu hỏi $id bị thiếu trường "thought".');
    }

    final rawType = json['correctType'] as String?;
    if (rawType == null) {
      throw FormatException('Câu hỏi $id bị thiếu trường "correctType".');
    }

    final correctType = CognitiveDistortionType.fromString(rawType);
    if (correctType == null) {
      throw FormatException('Câu hỏi $id có "correctType" không hợp lệ: $rawType');
    }

    final explanation = json['explanation'] as String? ?? '';
    final reframeSuggestion = json['reframeSuggestion'] as String? ?? '';

    return DistortionQuestion(
      id: id,
      contextTag: contextTag,
      thought: thought,
      correctType: correctType,
      explanation: explanation,
      reframeSuggestion: reframeSuggestion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contextTag': contextTag,
      'thought': thought,
      'correctType': correctType.name,
      'explanation': explanation,
      'reframeSuggestion': reframeSuggestion,
    };
  }
}
