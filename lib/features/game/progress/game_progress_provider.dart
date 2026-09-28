import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level_progress.dart';
import 'game_progress_repository.dart';

final gameProgressRepositoryProvider = Provider<GameProgressRepository>((ref) {
  return GameProgressRepository();
});

final gameProgressProvider =
    AsyncNotifierProvider<GameProgressNotifier, Map<String, LevelProgress>>(
  GameProgressNotifier.new,
);

class GameProgressNotifier extends AsyncNotifier<Map<String, LevelProgress>> {
  @override
  Future<Map<String, LevelProgress>> build() async {
    final repo = ref.read(gameProgressRepositoryProvider);
    return await repo.getAll();
  }

  /// Ghi nhận hoàn thành màn chơi và tự động cập nhật state
  Future<void> markCompleted({
    required String levelId,
    required int score,
    required int stars,
  }) async {
    final repo = ref.read(gameProgressRepositoryProvider);
    final updated = await repo.markCompleted(
      levelId: levelId,
      score: score,
      stars: stars,
    );
    state = AsyncData(updated);
  }

  /// Khôi phục toàn bộ tiến trình về mặc định
  Future<void> resetAll() async {
    final repo = ref.read(gameProgressRepositoryProvider);
    await repo.clear();
    final fresh = await repo.getAll();
    state = AsyncData(fresh);
  }
}
