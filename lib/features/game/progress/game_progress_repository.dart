import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_level.dart';
import '../models/level_progress.dart';

class GameProgressRepository {
  static const String storageKey = 'game_progress_v1';

  final SharedPreferences? _prefs;

  GameProgressRepository([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  /// Trạng thái mặc định khi người chơi mới bắt đầu:
  /// - Level 1 ('level_1') luôn mở (unlocked).
  /// - Các level tiếp theo đều bị khóa (locked).
  Map<String, LevelProgress> _createDefaultProgress() {
    final Map<String, LevelProgress> defaults = {};
    for (final level in GameLevel.defaultLevels) {
      defaults[level.id] = LevelProgress.initial(
        level.id,
        isUnlocked: level.order == 1,
      );
    }
    return defaults;
  }

  /// Lấy toàn bộ tiến trình của tất cả các màn chơi.
  /// Nếu JSON bị hỏng hoặc chưa có, tự động reset về mặc định và không gây crash.
  Future<Map<String, LevelProgress>> getAll() async {
    try {
      final prefs = await _getPrefs();
      final rawJson = prefs.getString(storageKey);
      if (rawJson == null || rawJson.trim().isEmpty) {
        final defaults = _createDefaultProgress();
        await _save(defaults);
        return defaults;
      }

      final dynamic decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('⚠️ Dữ liệu game progress không đúng định dạng Map. Đặt lại mặc định.');
        final defaults = _createDefaultProgress();
        await _save(defaults);
        return defaults;
      }

      final Map<String, LevelProgress> result = {};
      for (final level in GameLevel.defaultLevels) {
        if (decoded.containsKey(level.id) && decoded[level.id] is Map<String, dynamic>) {
          final progress = LevelProgress.fromJson(decoded[level.id] as Map<String, dynamic>);
          // Đảm bảo Level 1 không bao giờ bị locked
          if (level.order == 1 && progress.isLocked) {
            result[level.id] = progress.copyWith(status: LevelStatus.unlocked);
          } else {
            result[level.id] = progress;
          }
        } else {
          result[level.id] = LevelProgress.initial(level.id, isUnlocked: level.order == 1);
        }
      }
      return result;
    } catch (e, stack) {
      debugPrint('⚠️ Lỗi khi đọc game_progress_v1: $e\n$stack. Reset về mặc định an toàn.');
      final defaults = _createDefaultProgress();
      try {
        await _save(defaults);
      } catch (_) {}
      return defaults;
    }
  }

  /// Kiểm tra xem màn chơi có đang mở khóa (hoặc đã hoàn thành) hay không.
  Future<bool> isUnlocked(String levelId) async {
    final all = await getAll();
    final progress = all[levelId];
    if (progress == null) return false;
    return progress.isUnlocked || progress.isCompleted;
  }

  /// Ghi nhận hoàn thành màn chơi:
  /// - Status chuyển thành completed (không bao giờ bị hạ bậc).
  /// - bestScore và stars chỉ tăng, không giảm.
  /// - attempts tăng thêm 1.
  /// - Tự động mở khóa màn chơi tiếp theo (level N -> mở N+1).
  Future<Map<String, LevelProgress>> markCompleted({
    required String levelId,
    required int score,
    required int stars,
  }) async {
    final all = await getAll();
    final current = all[levelId] ?? LevelProgress.initial(levelId, isUnlocked: true);

    final clampedStars = stars.clamp(0, 3);
    final newBestScore = math.max(current.bestScore, score);
    final newStars = math.max(current.stars, clampedStars);

    final updatedCurrent = current.copyWith(
      status: LevelStatus.completed,
      bestScore: newBestScore,
      stars: newStars,
      attempts: current.attempts + 1,
      completedAt: DateTime.now(),
    );
    all[levelId] = updatedCurrent;

    // Tìm và mở khóa màn tiếp theo nếu có
    final currentLevel = GameLevel.findById(levelId);
    if (currentLevel != null) {
      final nextOrder = currentLevel.order + 1;
      final nextLevel = GameLevel.findByOrder(nextOrder);
      if (nextLevel != null) {
        final nextProgress = all[nextLevel.id] ?? LevelProgress.initial(nextLevel.id);
        // Chỉ chuyển sang unlocked nếu đang bị locked
        if (nextProgress.isLocked) {
          all[nextLevel.id] = nextProgress.copyWith(status: LevelStatus.unlocked);
        }
      }
    }

    await _save(all);
    return all;
  }

  /// Lưu toàn bộ map tiến trình vào SharedPreferences
  Future<void> _save(Map<String, LevelProgress> progressMap) async {
    final prefs = await _getPrefs();
    final mapToEncode = progressMap.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(storageKey, jsonEncode(mapToEncode));
  }

  /// Xóa toàn bộ tiến trình game (dành cho kiểm thử hoặc reset dữ liệu)
  Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.remove(storageKey);
  }
}
