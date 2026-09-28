import 'cognitive_distortion_type.dart';
import 'companion_tone.dart';
import 'mock_ui_model.dart';

/// Một tình huống nhận thức hoàn chỉnh được chuẩn hóa theo chuẩn CBT
class DistortionScenario {
  final String id;
  final String contextTag;
  final MockUiData mockUi;
  final String thought;
  final DistortionType distortionType;
  final List<DistortionType> choices;
  final String hintKey;
  final String reframe;
  final CompanionIntro companionIntro;

  DistortionScenario({
    required this.id,
    required this.contextTag,
    required this.mockUi,
    required this.thought,
    required this.distortionType,
    required this.choices,
    required this.hintKey,
    required this.reframe,
    required this.companionIntro,
  });

  factory DistortionScenario.fromJson(Map<String, dynamic> json) {
    final distortion = DistortionType.fromId(json['distortion_type'] as String);
    final rawChoices = (json['choices'] as List)
        .map((e) => DistortionType.fromId(e as String))
        .toList();

    return DistortionScenario(
      id: json['id'] as String,
      contextTag: json['context_tag'] as String,
      mockUi: MockUiData.fromJson(json['mock_ui'] as Map<String, dynamic>),
      thought: json['thought'] as String,
      distortionType: distortion,
      choices: rawChoices,
      hintKey: json['hint_key'] as String,
      reframe: json['reframe'] as String,
      companionIntro:
          CompanionIntro.fromJson(json['companion_intro'] as Map<String, dynamic>),
    );
  }

  /// Trả về choices được xáo trộn ngẫu nhiên để chống quy luật vị trí
  List<DistortionType> getShuffledChoices() {
    final list = List<DistortionType>.from(choices);
    list.shuffle();
    return list;
  }
}
