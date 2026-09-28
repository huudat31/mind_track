import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/game/models/game_level.dart';
import 'package:mind_track/features/game/models/game_skill.dart';
import 'package:mind_track/features/game/models/level_progress.dart';
import 'package:mind_track/features/game/progress/game_progress_provider.dart';
import 'package:mind_track/features/game/progress/game_progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameLevel & GameSkill Models', () {
    test('Default levels should be 3 and properly configured', () {
      expect(GameLevel.defaultLevels.length, 3);
      expect(GameLevel.defaultLevels[0].skillId, SkillId.breathing);
      expect(GameLevel.defaultLevels[1].skillId, SkillId.distortionSpotting);
      expect(GameLevel.defaultLevels[2].skillId, SkillId.evidenceScale);
    });

    test('findById and findByOrder work correctly', () {
      final lvl1 = GameLevel.findById('level_1');
      expect(lvl1, isNotNull);
      expect(lvl1!.order, 1);

      final lvl2 = GameLevel.findByOrder(2);
      expect(lvl2, isNotNull);
      expect(lvl2!.id, 'level_2');

      expect(GameLevel.findById('invalid_id'), isNull);
      expect(GameLevel.findByOrder(999), isNull);
    });

    test('SkillId has title and description', () {
      for (final skill in SkillId.values) {
        expect(skill.title, isNotEmpty);
        expect(skill.description, isNotEmpty);
      }
    });
  });

  group('LevelProgress Model Serialization', () {
    test('toJson and fromJson preserve values', () {
      final now = DateTime(2026, 9, 28, 14, 0, 0);
      const original = LevelProgress(
        levelId: 'level_1',
        status: LevelStatus.completed,
        bestScore: 95,
        stars: 3,
        attempts: 2,
        completedAt: null,
      );

      final withDate = original.copyWith(completedAt: now);
      final json = withDate.toJson();
      final restored = LevelProgress.fromJson(json);

      expect(restored.levelId, 'level_1');
      expect(restored.status, LevelStatus.completed);
      expect(restored.bestScore, 95);
      expect(restored.stars, 3);
      expect(restored.attempts, 2);
      expect(restored.completedAt, now);
      expect(restored.isCompleted, isTrue);
    });

    test('stars are clamped between 0 and 3', () {
      final over = LevelProgress.fromJson({
        'levelId': 'test',
        'stars': 5,
      });
      expect(over.stars, 3);

      final under = LevelProgress.fromJson({
        'levelId': 'test',
        'stars': -2,
      });
      expect(under.stars, 0);
    });
  });

  group('GameProgressRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial state: level_1 is unlocked, level_2 and level_3 are locked', () async {
      final repo = GameProgressRepository();
      final all = await repo.getAll();

      expect(all['level_1']?.status, LevelStatus.unlocked);
      expect(all['level_2']?.status, LevelStatus.locked);
      expect(all['level_3']?.status, LevelStatus.locked);

      expect(await repo.isUnlocked('level_1'), isTrue);
      expect(await repo.isUnlocked('level_2'), isFalse);
      expect(await repo.isUnlocked('level_3'), isFalse);
    });

    test('Marking level_1 completed unlocks level_2 and records score/stars', () async {
      final repo = GameProgressRepository();

      final updated = await repo.markCompleted(
        levelId: 'level_1',
        score: 80,
        stars: 2,
      );

      final lvl1 = updated['level_1']!;
      expect(lvl1.status, LevelStatus.completed);
      expect(lvl1.bestScore, 80);
      expect(lvl1.stars, 2);
      expect(lvl1.attempts, 1);
      expect(lvl1.completedAt, isNotNull);

      // Level 2 should now be unlocked!
      final lvl2 = updated['level_2']!;
      expect(lvl2.status, LevelStatus.unlocked);
      expect(await repo.isUnlocked('level_2'), isTrue);
    });

    test('Replaying with lower score does not downgrade bestScore or stars', () async {
      final repo = GameProgressRepository();

      await repo.markCompleted(levelId: 'level_1', score: 90, stars: 3);
      final replay = await repo.markCompleted(levelId: 'level_1', score: 60, stars: 1);

      final lvl1 = replay['level_1']!;
      expect(lvl1.status, LevelStatus.completed);
      expect(lvl1.bestScore, 90); // Preserved
      expect(lvl1.stars, 3); // Preserved
      expect(lvl1.attempts, 2); // Incremented
    });

    test('Corrupted JSON resets to defaults without crashing', () async {
      SharedPreferences.setMockInitialValues({
        GameProgressRepository.storageKey: '{corrupted_json_string:::invalid',
      });

      final repo = GameProgressRepository();
      final all = await repo.getAll();

      expect(all, isNotEmpty);
      expect(all['level_1']?.status, LevelStatus.unlocked);
      expect(all['level_2']?.status, LevelStatus.locked);
    });
  });

  group('GameProgressProvider (Riverpod AsyncNotifier)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Provider loads initial state and reacts to markCompleted', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Read initial state
      final initial = await container.read(gameProgressProvider.future);
      expect(initial['level_1']?.status, LevelStatus.unlocked);
      expect(initial['level_2']?.status, LevelStatus.locked);

      // Complete level 1
      await container.read(gameProgressProvider.notifier).markCompleted(
            levelId: 'level_1',
            score: 100,
            stars: 3,
          );

      final updated = container.read(gameProgressProvider).value;
      expect(updated, isNotNull);
      expect(updated!['level_1']?.status, LevelStatus.completed);
      expect(updated['level_2']?.status, LevelStatus.unlocked);
    });
  });
}
