import 'package:flutter/material.dart';
import '../../../core/services/supabase_clinical_service.dart';
import '../../logging/models/daily_log_model.dart';
import '../models/frequency_analytics_model.dart';

class ClinicalDataRepository {
  // DASS-21 Historical assessments (T0 to Day 28)
  static final List<DassHistoryPoint> dassHistory = [
    DassHistoryPoint(
      date: DateTime.now().subtract(const Duration(days: 28)),
      label: 'Ngày 0 (T0)',
      depression: 18, // Vừa phải
      anxiety: 16,    // Nặng
      stress: 26,     // Nặng
    ),
    DassHistoryPoint(
      date: DateTime.now().subtract(const Duration(days: 21)),
      label: 'Ngày 7',
      depression: 16, // Vừa phải
      anxiety: 14,    // Vừa phải
      stress: 24,     // Vừa phải
    ),
    DassHistoryPoint(
      date: DateTime.now().subtract(const Duration(days: 14)),
      label: 'Ngày 14',
      depression: 14, // Vừa phải
      anxiety: 12,    // Vừa phải
      stress: 20,     // Vừa phải
    ),
    DassHistoryPoint(
      date: DateTime.now().subtract(const Duration(days: 7)),
      label: 'Ngày 21',
      depression: 12, // Nhẹ
      anxiety: 10,    // Vừa phải
      stress: 18,     // Nhẹ
    ),
    DassHistoryPoint(
      date: DateTime.now(),
      label: 'Ngày 28 (Hiện tại)',
      depression: 10, // Nhẹ
      anxiety: 8,     // Nhẹ
      stress: 15,     // Nhẹ
    ),
  ];

  /// Lấy xu hướng DASS-21: ưu tiên nạp từ Supabase, nếu chưa có thì dùng dữ liệu mẫu
  static Future<List<DassHistoryPoint>> getDynamicDassTrend(TimeframeOption timeframe) async {
    final realData = await SupabaseClinicalService.getDassHistory();
    if (realData.length >= 2) {
      if (timeframe == TimeframeOption.sevenDays && realData.length > 2) {
        return realData.sublist(realData.length - 2);
      }
      return realData;
    }
    return getDassTrend(timeframe);
  }

  static List<DassHistoryPoint> getDassTrend(TimeframeOption timeframe) {
    switch (timeframe) {
      case TimeframeOption.sevenDays:
        return dassHistory.sublist(dassHistory.length - 2); // Ngày 21 và Ngày 28
      case TimeframeOption.fourteenDays:
        return dassHistory.sublist(dassHistory.length - 3); // Ngày 14, 21, 28
      case TimeframeOption.twentyEightDays:
        return dassHistory; // Cả chu kỳ 28 ngày
    }
  }

  /// Lấy tần suất cờ đỏ: ưu tiên nạp từ Supabase, nếu chưa có thì dùng dữ liệu mẫu
  static Future<List<FlagFrequencyStat>> getDynamicFlagFrequencies(
    TimeframeOption timeframe, {
    String? categoryFilter,
  }) async {
    final realFlags = await SupabaseClinicalService.getRealFlagFrequencies(
      timeframe,
      categoryFilter: categoryFilter,
    );
    if (realFlags.isNotEmpty) {
      return realFlags;
    }
    return getFlagFrequencies(timeframe, categoryFilter: categoryFilter);
  }

  // Get ranked clinical flags based on timeframe
  static List<FlagFrequencyStat> getFlagFrequencies(TimeframeOption timeframe, {String? categoryFilter}) {
    final totalDays = timeframe.days;
    final Map<String, int> counts28Days = {
      'insomnia': 21,          // 75%
      'muscle_tension': 19,    // 68%
      'brain_fog': 16,         // 57%
      'headache': 15,          // 54%
      'overwhelmed': 14,       // 50%
      'social_withdrawal': 12, // 43%
      'procrastination': 13,   // 46%
      'mid_wake': 11,          // 39%
      'chest_tightness': 9,    // 32%
      'stress_eating': 8,      // 28%
      'loss_appetite': 7,      // 25%
      'stomach_ache': 6,       // 21%
      'hypersomnia': 4,        // 14%
    };

    final Map<String, int> counts14Days = {
      'insomnia': 11,          // 78%
      'muscle_tension': 10,    // 71%
      'brain_fog': 8,          // 57%
      'headache': 8,           // 57%
      'overwhelmed': 7,        // 50%
      'social_withdrawal': 6,  // 43%
      'procrastination': 7,    // 50%
      'mid_wake': 6,           // 43%
      'chest_tightness': 4,    // 29%
      'stress_eating': 4,      // 29%
      'loss_appetite': 3,      // 21%
      'stomach_ache': 3,       // 21%
      'hypersomnia': 2,        // 14%
    };

    final Map<String, int> counts7Days = {
      'insomnia': 5,           // 71%
      'muscle_tension': 5,     // 71%
      'brain_fog': 4,          // 57%
      'headache': 4,           // 57%
      'overwhelmed': 3,        // 43%
      'social_withdrawal': 3,  // 43%
      'procrastination': 3,    // 43%
      'mid_wake': 3,           // 43%
      'chest_tightness': 2,    // 28%
      'stress_eating': 2,      // 28%
      'loss_appetite': 1,      // 14%
      'stomach_ache': 1,       // 14%
      'hypersomnia': 1,        // 14%
    };

    final countsMap = switch (timeframe) {
      TimeframeOption.sevenDays => counts7Days,
      TimeframeOption.fourteenDays => counts14Days,
      TimeframeOption.twentyEightDays => counts28Days,
    };

    final List<FlagFrequencyStat> list = [];
    for (final item in ClinicalFlagsCatalog.allFlags) {
      if (categoryFilter != null && categoryFilter != 'Tất cả' && item.category != categoryFilter) {
        continue;
      }
      final count = countsMap[item.id] ?? 0;
      if (count > 0) {
        list.add(FlagFrequencyStat(
          flag: item,
          count: count,
          totalDays: totalDays,
          trend: count / totalDays >= 0.5 ? 'up' : 'stable',
        ));
      }
    }

    // Sort descending by count / percentage
    list.sort((a, b) => b.count.compareTo(a.count));
    return list;
  }

  // Clinical Co-Occurrence Insights
  static List<CoOccurrenceInsight> getCoOccurrenceInsights(TimeframeOption timeframe) {
    return [
      const CoOccurrenceInsight(
        title: 'Năng lượng cạn kiệt & Khó ngủ',
        observation: 'Trong các ngày năng lượng ghi nhận mức 1–2/5, cờ đỏ "Khó vào giấc" xuất hiện ở 82% trường hợp.',
        factorA: 'Năng lượng thấp (1–2)',
        factorB: 'Khó vào giấc',
        percentage: 82,
        icon: Icons.nights_stay_rounded,
        accentColor: Color(0xFFE07A5F),
      ),
      const CoOccurrenceInsight(
        title: 'Bối cảnh Công việc & Căng cơ / Đau đầu',
        observation: 'Vào các ngày gắn thẻ bối cảnh "Công việc", cờ đỏ "Căng cơ vai gáy" và "Đau đầu" đồng xuất hiện ở 74% số lần.',
        factorA: 'Bối cảnh Công việc',
        factorB: 'Căng cơ vai gáy / Đau đầu',
        percentage: 74,
        icon: Icons.work_outline_rounded,
        accentColor: Color(0xFFF4A261),
      ),
      const CoOccurrenceInsight(
        title: 'Cảm xúc Tiêu cực & Né tránh Xã hội',
        observation: 'Khi tâm trạng ở mức "Kiệt quệ" hoặc "Lo âu", hành vi "Né tránh tin nhắn/gặp gỡ" xuất hiện ở 67% số ngày.',
        factorA: 'Tâm trạng Tiêu cực',
        factorB: 'Né tránh xã hội',
        percentage: 67,
        icon: Icons.person_off_rounded,
        accentColor: Color(0xFF818AA3),
      ),
    ];
  }

  // Daily mood & energy tracking timeline
  static List<DailyMoodEnergyPoint> getDailyMoodEnergyTimeline(TimeframeOption timeframe) {
    final now = DateTime.now();
    final days = timeframe.days;
    final List<DailyMoodEnergyPoint> list = [];

    // Realistic simulation data oscillating across days
    final moodSequence = [2, 1, 2, 3, 2, 3, 4, 3, 2, 3, 4, 4, 3, 4, 3, 2, 2, 3, 4, 3, 4, 3, 4, 5, 4, 4, 3, 4];
    final energySequence = [2, 1, 2, 2, 1, 2, 3, 2, 1, 3, 3, 4, 2, 3, 3, 1, 2, 3, 3, 2, 4, 3, 4, 4, 4, 3, 3, 4];

    final weekdayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    for (int i = days - 1; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final idx = (days - 1 - i) % moodSequence.length;
      final weekdayStr = weekdayNames[d.weekday - 1];

      list.add(DailyMoodEnergyPoint(
        date: d,
        dayLabel: '$weekdayStr ${d.day}',
        moodScore: moodSequence[idx],
        energyLevel: energySequence[idx],
      ));
    }
    return list;
  }
}
