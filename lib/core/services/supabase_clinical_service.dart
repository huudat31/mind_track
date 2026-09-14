import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/dashboard/models/frequency_analytics_model.dart';
import '../../features/logging/models/daily_log_model.dart';
import '../../features/report/models/report_config_model.dart';

class SupabaseClinicalService {
  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Lấy ID người dùng: ưu tiên ID của phiên đăng nhập Supabase Auth,
  /// nếu chưa đăng nhập thì tự động đăng nhập ẩn danh (anonymous auth)
  static Future<String> getUserId() async {
    final client = _client;
    if (client == null) return 'anonymous_user';

    final currentUser = client.auth.currentUser;
    if (currentUser != null) {
      return currentUser.id;
    }

    try {
      // Đăng nhập ẩn danh tạo UID thật trên Supabase Auth
      final authResponse = await client.auth.signInAnonymously();
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
      final client = _client;
      if (client == null) return false;

      final userId = await getUserId();
      final answersJson = answers.map((k, v) => MapEntry(k.toString(), v));

      await client.from('dass21_assessments').insert({
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
      final client = _client;
      if (client == null) return [];

      final userId = await getUserId();
      final response = await client
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
      final client = _client;
      if (client == null) return false;

      final userId = await getUserId();

      await client.from('daily_logs').insert({
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
      final client = _client;
      if (client == null) return null;

      final userId = await getUserId();
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

      final response = await client
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

  /// Lấy danh sách Daily Logs theo số ngày (14, 60 hoặc all)
  static Future<List<Map<String, dynamic>>> getDailyLogs(int days) async {
    try {
      final client = _client;
      if (client == null) return [];

      final userId = await getUserId();
      final query = client
          .from('daily_logs')
          .select()
          .eq('user_id', userId);

      final dynamic response;
      if (days < 1000) {
        final cutoff = DateTime.now().subtract(Duration(days: days)).toIso8601String();
        response = await query.gte('created_at', cutoff).order('created_at', ascending: true);
      } else {
        response = await query.order('created_at', ascending: true);
      }

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

    final totalDays = timeframe.isAll
        ? (logs.isNotEmpty ? logs.length : 1)
        : timeframe.days;

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
          totalDays: totalDays,
          trend: count / totalDays >= 0.5 ? 'up' : 'stable',
        ));
      }
    }

    list.sort((a, b) => b.count.compareTo(a.count));
    return list;
  }

  /// Tính toán timeline Nhịp điệu Cảm xúc & Năng lượng từ dữ liệu thật
  static Future<List<DailyMoodEnergyPoint>> getRealDailyMoodEnergyTimeline(TimeframeOption timeframe) async {
    final logs = await getDailyLogs(timeframe.days);
    if (logs.isEmpty) return [];

    final weekdayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final List<DailyMoodEnergyPoint> list = [];

    for (final log in logs) {
      final createdAt = DateTime.tryParse(log['created_at']?.toString() ?? '') ?? DateTime.now();
      final weekdayStr = weekdayNames[createdAt.weekday - 1];
      final moodScore = (log['mood_score'] as num?)?.toInt() ?? 3;
      final energyLevel = (log['energy_level'] as num?)?.round() ?? 3;
      final flags = (log['clinical_flags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

      list.add(DailyMoodEnergyPoint(
        date: createdAt,
        dayLabel: '$weekdayStr ${createdAt.day}',
        moodScore: moodScore,
        energyLevel: energyLevel,
        flagIds: flags,
      ));
    }
    return list;
  }

  /// Thống kê chuỗi ngày check-in (streak) và tiến trình 28 ngày từ Supabase
  static Future<Map<String, dynamic>> getStreakStats() async {
    final logs = await getDailyLogs(28);
    if (logs.isEmpty) {
      return {
        'totalDaysRecorded': 0,
        'currentStreak': 0,
        'recordedDates': <String>{},
        'dateValenceMap': <String, double>{},
      };
    }

    final Set<String> recordedDates = {};
    final Map<String, double> dateValenceMap = {};

    for (final log in logs) {
      final createdAt = DateTime.tryParse(log['created_at']?.toString() ?? '');
      if (createdAt != null) {
        final dateKey = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
        recordedDates.add(dateKey);
        final val = (log['valence'] as num?)?.toDouble() ?? 0.5;
        dateValenceMap[dateKey] = val;
      }
    }

    // Tính toán chuỗi ngày liên tiếp (streak)
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 28; i++) {
      final d = now.subtract(Duration(days: i));
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      if (recordedDates.contains(key)) {
        streak++;
      } else {
        if (i == 0) {
          // Chưa check-in hôm nay thì vẫn xét chuỗi từ hôm qua
          continue;
        }
        break;
      }
    }

    return {
      'totalDaysRecorded': recordedDates.length,
      'currentStreak': streak,
      'recordedDates': recordedDates,
      'dateValenceMap': dateValenceMap,
    };
  }

  /// Tóm tắt lâm sàng tuần này (7 ngày gần nhất) từ Supabase
  static Future<Map<String, String>> getRealWeeklySnapshot() async {
    final logs = await getDailyLogs(7);
    if (logs.isEmpty) {
      return {
        'mood': 'Chưa ghi nhận',
        'moodSub': '0 ngày trong tuần',
        'energy': '-- / 5',
        'energySub': 'Chưa có dữ liệu',
        'flag': 'Chưa có',
        'flagSub': '0 cờ đỏ ghi nhận',
      };
    }

    // Năng lượng trung bình
    double totalEnergy = 0;
    for (final l in logs) {
      totalEnergy += (l['energy_level'] as num?)?.toDouble() ?? 0;
    }
    final avgEnergy = (totalEnergy / logs.length).toStringAsFixed(1);

    // Cảm xúc chủ đạo
    final Map<int, int> moodCounts = {};
    for (final l in logs) {
      final m = (l['mood_score'] as num?)?.toInt() ?? 3;
      moodCounts[m] = (moodCounts[m] ?? 0) + 1;
    }
    int topMood = 3;
    int maxMoodCount = 0;
    moodCounts.forEach((m, c) {
      if (c > maxMoodCount) {
        maxMoodCount = c;
        topMood = m;
      }
    });
    final moodLabels = {
      1: 'Kiệt quệ',
      2: 'Lo âu',
      3: 'Tạm ổn',
      4: 'Bình yên',
      5: 'Hào hứng',
    };
    final dominantMood = moodLabels[topMood] ?? 'Tạm ổn';
    final moodPct = ((maxMoodCount / logs.length) * 100).toInt();

    // Cờ đỏ xuất hiện nhiều nhất
    final Map<String, int> flagCounts = {};
    for (final l in logs) {
      final flags = (l['clinical_flags'] as List<dynamic>?) ?? [];
      for (final f in flags) {
        final fid = f.toString();
        flagCounts[fid] = (flagCounts[fid] ?? 0) + 1;
      }
    }
    String topFlagName = 'Không có';
    int maxFlagCount = 0;
    flagCounts.forEach((fid, count) {
      if (count > maxFlagCount) {
        maxFlagCount = count;
        final item = ClinicalFlagsCatalog.getFlagById(fid);
        if (item != null) topFlagName = item.name;
      }
    });

    return {
      'mood': dominantMood,
      'moodSub': '$moodPct% ($maxMoodCount/${logs.length} ngày)',
      'energy': '$avgEnergy / 5',
      'energySub': '${logs.length}/7 ngày ghi nhận',
      'flag': topFlagName,
      'flagSub': maxFlagCount > 0 ? '$maxFlagCount/${logs.length} ngày' : 'Không có cờ đỏ',
    };
  }

  /// Phát hiện các cặp triệu chứng đồng xuất hiện thật từ Supabase
  static Future<List<CoOccurrenceInsight>> getRealCoOccurrences(TimeframeOption timeframe) async {
    final logs = await getDailyLogs(timeframe.days);
    if (logs.length < 3) return [];

    final List<CoOccurrenceInsight> insights = [];

    // Tương quan Năng lượng thấp (<= 2) và Khó ngủ
    int lowEnergyCount = 0;
    int lowEnergyAndInsomnia = 0;
    for (final l in logs) {
      final energy = (l['energy_level'] as num?)?.toDouble() ?? 3.0;
      final flags = (l['clinical_flags'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? {};
      if (energy <= 2.5) {
        lowEnergyCount++;
        if (flags.contains('insomnia') || flags.contains('mid_wake')) {
          lowEnergyAndInsomnia++;
        }
      }
    }

    if (lowEnergyCount >= 2) {
      final pct = ((lowEnergyAndInsomnia / lowEnergyCount) * 100).toInt();
      if (pct >= 40) {
        insights.add(CoOccurrenceInsight(
          title: 'Năng lượng thấp & Khó ngủ',
          observation: 'Trong các ngày năng lượng ghi nhận mức 1–2/5, cờ đỏ "Khó ngủ / Chập chờn" đồng xuất hiện ở $pct% trường hợp.',
          factorA: 'Năng lượng thấp (1–2)',
          factorB: 'Khó ngủ / Chập chờn',
          percentage: pct,
          icon: Icons.nights_stay_rounded,
          accentColor: const Color(0xFFE07A5F),
        ));
      }
    }

    // Tương quan Công việc và Triệu chứng thể chất
    int workCount = 0;
    int workAndSomatic = 0;
    for (final l in logs) {
      final tags = (l['context_tags'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? {};
      final flags = (l['clinical_flags'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? {};
      if (tags.contains('work') || tags.contains('Công việc')) {
        workCount++;
        if (flags.contains('muscle_tension') || flags.contains('headache') || flags.contains('chest_tightness')) {
          workAndSomatic++;
        }
      }
    }

    if (workCount >= 2) {
      final pct = ((workAndSomatic / workCount) * 100).toInt();
      if (pct >= 40) {
        insights.add(CoOccurrenceInsight(
          title: 'Bối cảnh Công việc & Căng thẳng thể chất',
          observation: 'Vào các ngày gắn thẻ bối cảnh "Công việc", các triệu chứng căng cơ / đau đầu / tức ngực đồng xuất hiện ở $pct% số lần.',
          factorA: 'Bối cảnh Công việc',
          factorB: 'Triệu chứng thể chất',
          percentage: pct,
          icon: Icons.work_outline_rounded,
          accentColor: const Color(0xFFF4A261),
        ));
      }
    }

    return insights;
  }

  /// Lấy danh sách trích đoạn nhật ký CBT thật của người dùng từ Supabase
  static Future<List<CbtJournalExcerpt>> getRealCbtJournals() async {
    final logs = await getDailyLogs(28);
    final List<CbtJournalExcerpt> list = [];

    for (final log in logs) {
      final autoThought = log['automatic_thought'] as String?;
      final balanced = log['balanced_response'] as String?;
      final trigger = log['trigger_event'] as String?;
      final id = log['id']?.toString() ?? UniqueKey().toString();
      final createdAt = DateTime.tryParse(log['created_at']?.toString() ?? '') ?? DateTime.now();

      if ((autoThought != null && autoThought.trim().isNotEmpty) ||
          (balanced != null && balanced.trim().isNotEmpty)) {
        final tags = (log['context_tags'] as List<dynamic>?) ?? [];
        final tagStr = tags.isNotEmpty ? tags.first.toString() : 'Hàng ngày';

        list.add(CbtJournalExcerpt(
          id: id,
          date: createdAt,
          dateLabel: '${createdAt.day}/${createdAt.month}/${createdAt.year}',
          contextTag: tagStr,
          situation: trigger?.isNotEmpty == true ? trigger! : 'Nhật ký cảm xúc ngày ${createdAt.day}/${createdAt.month}',
          automaticThought: autoThought ?? 'Chưa ghi nhận',
          balancedResponse: balanced ?? 'Chưa ghi nhận',
        ));
      }
    }

    return list;
  }
}
