import '../../../core/services/supabase_clinical_service.dart';
import '../models/frequency_analytics_model.dart';

class ClinicalDataRepository {
  /// Lấy toàn bộ lịch sử DASS-21 thật của người dùng từ Supabase
  static Future<List<DassHistoryPoint>> getDynamicDassTrend(TimeframeOption timeframe) async {
    final realData = await SupabaseClinicalService.getDassHistory();
    if (realData.isEmpty) {
      return [];
    }

    if (timeframe.isAll) {
      return realData;
    }

    final cutoff = DateTime.now().subtract(Duration(days: timeframe.days));
    final filtered = realData.where((p) => p.date.isAfter(cutoff) || p.date.isAtSameMomentAs(cutoff)).toList();
    if (filtered.isEmpty) {
      return [realData.last];
    }
    return filtered;
  }

  /// Lấy tần suất cờ đỏ lâm sàng thật từ Supabase
  static Future<List<FlagFrequencyStat>> getDynamicFlagFrequencies(
    TimeframeOption timeframe, {
    String? categoryFilter,
  }) async {
    return await SupabaseClinicalService.getRealFlagFrequencies(
      timeframe,
      categoryFilter: categoryFilter,
    );
  }

  /// Nhịp điệu cảm xúc & năng lượng thật từ Supabase
  static Future<List<DailyMoodEnergyPoint>> getDynamicDailyMoodEnergyTimeline(TimeframeOption timeframe) async {
    return await SupabaseClinicalService.getRealDailyMoodEnergyTimeline(timeframe);
  }

  /// Các cặp triệu chứng đồng xuất hiện thật từ Supabase
  static Future<List<CoOccurrenceInsight>> getDynamicCoOccurrenceInsights(TimeframeOption timeframe) async {
    return await SupabaseClinicalService.getRealCoOccurrences(timeframe);
  }
}
