import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/dashboard/models/frequency_analytics_model.dart';
import '../../features/logging/models/daily_log_model.dart';

class SupabaseClinicalService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Lấy ID người dùng: ưu tiên ID của phiên đăng nhập Supabase Auth,
  /// nếu chưa đăng nhập thì tự động đăng nhập ẩn danh (anonymous auth)
  static Future<String> getUserId() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser != null) {
      return currentUser.id;
    }

    try {
      // Đăng nhập ẩn danh tạo UID thật trên Supabase Auth
      final authResponse = await _client.auth.signInAnonymously();
      if (authResponse.user != null) {
        return authResponse.user!.id;
      }
    } catch (e) {
      debugPrint('Anonymous auth fallback: $e');
    }

    return 'anonymous_user';
  }

  // ==========================================
  // 1. DASS-21 ASSESSMENTS SYNC
  // ==========================================

  /// Lưu kết quả bài đánh giá DASS-21 lên Supabase
  static Future<bool> saveDass21({
    required int depressionScore,
    required int anxietyScore,
    required int stressScore,
    required Map<int, int> answers,
  }) async {
    try {
      final userId = await getUserId();
      final answersJson = answers.map((k, v) => MapEntry(k.toString(), v));

      await _client.from('dass21_assessments').insert({
        'user_id': userId,
        'depression_score': depressionScore,
        'anxiety_score': anxietyScore,
        'stress_score': stressScore,
        'answers': answersJson,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Đã lưu kết quả DASS-21 lên Supabase thành công!');
      return true;
    } catch (e) {
      debugPrint('❌ Lỗi khi lưu DASS-21 lên Supabase: $e');
      return false;
    }
  }

  /// Lấy toàn bộ lịch sử các mốc đánh giá DASS-21 từ Supabase
  static Future<List<DassHistoryPoint>> getDassHistory() async {
    try {
      final userId = await getUserId();
      final response = await _client
          .from('dass21_assessments')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      final List<dynamic> rows = response as List<dynamic>;
      if (rows.isEmpty) return [];

      return rows.asMap().entries.map((entry) {
        final idx = entry.key;
        final row = entry.value as Map<String, dynamic>;
        final createdAt = DateTime.parse(row['created_at']);
        final label = idx == 0 ? 'Ngày 0 (T0)' : 'Lần ${idx + 1}';

        return DassHistoryPoint(
          date: createdAt,
          label: label,
          depression: (row['depression_score'] as num?)?.toInt() ?? 0,
          anxiety: (row['anxiety_score'] as num?)?.toInt() ?? 0,
          stress: (row['stress_score'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('Lỗi lấy lịch sử DASS-21 từ Supabase: $e');
      return [];
    }
  }

  // ==========================================
  // 2. DAILY LOGS SYNC
  // ==========================================

  /// Lưu bản ghi check-in cảm xúc & cờ đỏ hàng ngày lên Supabase
  static Future<bool> saveDailyLog({
    required int moodScore,
    required double valence,
    required double energyLevel,
    required Set<String> contextTags,
    required Set<String> clinicalFlags,
    String? triggerEvent,
    String? automaticThought,
    String? balancedResponse,
  }) async {
    try {
      final userId = await getUserId();

      await _client.from('daily_logs').insert({
        'user_id': userId,
        'mood_score': moodScore,
        'valence': valence,
        'energy_level': energyLevel,
        'context_tags': contextTags.toList(),
        'clinical_flags': clinicalFlags.toList(),
        'trigger_event': triggerEvent,
        'automatic_thought': automaticThought,
        'balanced_response': balancedResponse,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Đã lưu Daily Log lên Supabase thành công!');
      return true;
    } catch (e) {
      debugPrint('❌ Lỗi khi lưu Daily Log lên Supabase: $e');
      return false;
    }
  }

  /// Lấy bản ghi check-in mới nhất của ngày hôm nay
  static Future<Map<String, dynamic>?> getTodayLog() async {
    try {
      final userId = await getUserId();
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

      final response = await _client
          .from('daily_logs')
          .select()
          .eq('user_id', userId)
          .gte('created_at', startOfDay)
          .order('created_at', ascending: false)
          .limit(1);

      final list = response as List<dynamic>;
      if (list.isNotEmpty) {
        return list.first as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Lỗi lấy bản ghi hôm nay: $e');
      return null;
    }
  }

  /// Lấy danh sách Daily Logs theo số ngày (7, 14, 28)
  static Future<List<Map<String, dynamic>>> getDailyLogs(int days) async {
    try {
      final userId = await getUserId();
      final cutoff = DateTime.now().subtract(Duration(days: days)).toIso8601String();

      final response = await _client
          .from('daily_logs')
          .select()
          .eq('user_id', userId)
          .gte('created_at', cutoff)
          .order('created_at', ascending: true);

      return (response as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Lỗi lấy danh sách daily logs: $e');
      return [];
    }
  }

  /// Tính toán bảng tần suất cờ đỏ từ dữ liệu Supabase thực tế
  static Future<List<FlagFrequencyStat>> getRealFlagFrequencies(
    TimeframeOption timeframe, {
    String? categoryFilter,
  }) async {
    final logs = await getDailyLogs(timeframe.days);
    if (logs.isEmpty) return [];

    final Map<String, int> flagCounts = {};
    for (final log in logs) {
      final flags = (log['clinical_flags'] as List<dynamic>?)?.map((e) => e.toString()) ?? [];
      for (final flagId in flags) {
        flagCounts[flagId] = (flagCounts[flagId] ?? 0) + 1;
      }
    }

    final List<FlagFrequencyStat> list = [];
    for (final item in ClinicalFlagsCatalog.allFlags) {
      if (categoryFilter != null && categoryFilter != 'Tất cả' && item.category != categoryFilter) {
        continue;
      }
      final count = flagCounts[item.id] ?? 0;
      if (count > 0) {
        list.add(FlagFrequencyStat(
          flag: item,
          count: count,
          totalDays: timeframe.days,
          trend: count / timeframe.days >= 0.5 ? 'up' : 'stable',
        ));
      }
    }

    list.sort((a, b) => b.count.compareTo(a.count));
    return list;
  }
}
