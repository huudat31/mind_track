import '../constants/game_strings.dart';

enum SkillId {
  breathing,
  distortionSpotting,
  evidenceScale;

  String get title {
    switch (this) {
      case SkillId.breathing:
        return GameStrings.skillBreathing;
      case SkillId.distortionSpotting:
        return GameStrings.skillDistortionSpotting;
      case SkillId.evidenceScale:
        return GameStrings.skillEvidenceScale;
    }
  }

  String get description {
    switch (this) {
      case SkillId.breathing:
        return GameStrings.skillBreathingDesc;
      case SkillId.distortionSpotting:
        return GameStrings.skillDistortionSpottingDesc;
      case SkillId.evidenceScale:
        return GameStrings.skillEvidenceScaleDesc;
    }
  }
}
