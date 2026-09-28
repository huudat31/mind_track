import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_track/core/services/supabase_clinical_service.dart';

/// Service phân tích và cá nhân hóa trải nghiệm trò chơi dựa trên ngữ cảnh người dùng
class GamePersonalizationService {
  /// Chuẩn hóa tag từ nhiều định dạng khác nhau về 4 nhóm CBT cốt lõi
  static String normalizeContextTag(String rawTag) {
    final lower = rawTag.toLowerCase().trim();
    if (lower.contains('học') || lower.contains('thi') || lower.contains('study') || lower.contains('hoc_tap')) {
      return 'hoc_tap';
    }
    if (lower.contains('nhà') || lower.contains('mẹ') || lower.contains('bố') || lower.contains('gia_dinh') || lower.contains('family')) {
      return 'gia_dinh';
    }
    if (lower.contains('yêu') || lower.contains('người yêu') || lower.contains('crush') || lower.contains('tinh_cam') || lower.contains('love')) {
      return 'tinh_cam';
    }
    if (lower.contains('mạng') || lower.contains('bạn bè') || lower.contains('facebook') || lower.contains('mang_xa_hoi') || lower.contains('social')) {
      return 'mang_xa_hoi';
    }
    return 'hoc_tap'; // Mặc định là học tập
  }

  /// Trích xuất context tag xuất hiện nhiều nhất gần đây từ lịch sử nhật ký
  static String findMostFrequentContextTag(List<Map<String, dynamic>> logs) {
    if (logs.isEmpty) return 'hoc_tap';

    final counts = <String, int>{
      'hoc_tap': 0,
      'gia_dinh': 0,
      'tinh_cam': 0,
      'mang_xa_hoi': 0,
    };

    for (final log in logs) {
      final tags = log['context_tags'];
      if (tags is List) {
        for (final tag in tags) {
          final normalized = normalizeContextTag(tag.toString());
          counts[normalized] = (counts[normalized] ?? 0) + 1;
        }
      }
    }

    String topTag = 'hoc_tap';
    int maxCount = 0;
    counts.forEach((tag, count) {
      if (count > maxCount) {
        maxCount = count;
        topTag = tag;
      }
    });

    return maxCount > 0 ? topTag : 'hoc_tap';
  }

  /// Lấy ngữ cảnh đề xuất bất đồng bộ từ dịch vụ lâm sàng
  Future<String> getRecommendedContextTag() async {
    try {
      final logs = await SupabaseClinicalService.getDailyLogs(14);
      return findMostFrequentContextTag(logs);
    } catch (_) {
      // Fallback an toàn về học tập khi offline hoặc chưa có dữ liệu
      return 'hoc_tap';
    }
  }

  /// Trả về tiêu đề hiển thị thân thiện bằng tiếng Việt của context tag
  static String getContextTagDisplayName(String tag) {
    switch (normalizeContextTag(tag)) {
      case 'hoc_tap':
        return 'Học tập & Mùa thi';
      case 'gia_dinh':
        return 'Gia đình & Kỳ vọng';
      case 'tinh_cam':
        return 'Tình cảm & Mối quan hệ';
      case 'mang_xa_hoi':
        return 'Mạng xã hội & Áp lực đồng trang lứa';
      default:
        return 'Học tập & Áp lực';
    }
  }
}

/// Provider cho dịch vụ cá nhân hóa
final gamePersonalizationServiceProvider =
    Provider<GamePersonalizationService>((ref) => GamePersonalizationService());

/// FutureProvider cung cấp context tag được cá nhân hóa cho người dùng hiện tại
final recommendedContextTagProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(gamePersonalizationServiceProvider);
  return await service.getRecommendedContextTag();
});
