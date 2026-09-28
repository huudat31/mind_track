import 'game_skill.dart';

class GameLevel {
  final String id;
  final SkillId skillId;
  final String title;
  final String description;
  final int order;

  const GameLevel({
    required this.id,
    required this.skillId,
    required this.title,
    required this.description,
    required this.order,
  });

  /// Danh sách 3 màn chơi chuẩn của module Game Tâm Cảnh
  static const List<GameLevel> defaultLevels = [
    GameLevel(
      id: 'level_1',
      skillId: SkillId.breathing,
      title: 'Màn 1: Điều hòa hơi thở 4-4-6',
      description: 'Cùng Muội Đen lắng dịu hệ thần kinh qua nhịp thở điều hòa.',
      order: 1,
    ),
    GameLevel(
      id: 'level_2',
      skillId: SkillId.distortionSpotting,
      title: 'Màn 2: Thám tử bẫy tư duy',
      description: 'Nhận diện các kiểu suy nghĩ méo mó tự động phổ biến.',
      order: 2,
    ),
    GameLevel(
      id: 'level_3',
      skillId: SkillId.evidenceScale,
      title: 'Màn 3: Cán cân bằng chứng',
      description: 'Đối chiếu sự thật khách quan và tìm góc nhìn công tâm.',
      order: 3,
    ),
  ];

  static GameLevel? findById(String id) {
    try {
      return defaultLevels.firstWhere((level) => level.id == id);
    } catch (_) {
      return null;
    }
  }

  static GameLevel? findByOrder(int order) {
    try {
      return defaultLevels.firstWhere((level) => level.order == order);
    } catch (_) {
      return null;
    }
  }
}
