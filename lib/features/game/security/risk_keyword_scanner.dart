/// Mức độ rủi ro tâm lý phát hiện được từ văn bản
enum RiskLevel {
  none,
  warning,
  critical;

  bool get isHighRisk => this == RiskLevel.critical;
}

/// Kết quả phân tích rủi ro an toàn tâm lý
class RiskScanResult {
  final RiskLevel level;
  final List<String> matchedKeywords;
  final String recommendation;

  const RiskScanResult({
    required this.level,
    this.matchedKeywords = const [],
    this.recommendation = '',
  });

  bool get requiresImmediateIntervention => level == RiskLevel.critical;

  static const RiskScanResult safe = RiskScanResult(
    level: RiskLevel.none,
    matchedKeywords: [],
    recommendation: 'Không phát hiện rủi ro khẩn cấp.',
  );
}

/// Bộ quét và phát hiện từ khóa nguy cơ tự hại hoặc khủng hoảng tâm lý
/// Thiết kế sẵn cho tương lai nếu ứng dụng bổ sung ô nhập suy nghĩ tự do (Free-text journaling)
class RiskKeywordScanner {
  // Danh sách từ khóa nguy cơ khẩn cấp (Cần can thiệp hotline ngay lập tức)
  static const List<String> _criticalKeywords = [
    'tự tử',
    'tự sát',
    'muốn chết',
    'kết liễu',
    'rạch tay',
    'kết thúc cuộc sống',
    'không muốn sống',
    'uống thuốc ngủ',
    'nhảy lầu',
    'nhảy cầu',
    'chết đi cho xong',
    'giải thoát bản thân',
  ];

  // Danh sách từ khóa cảnh báo căng thẳng sâu sắc
  static const List<String> _warningKeywords = [
    'tuyệt vọng',
    'quá bế tắc',
    'muốn biến mất',
    'gánh nặng cho gia đình',
    'gánh nặng cho mọi người',
    'không còn lối thoát',
    'không ai cần mình',
    'vô dụng hoàn toàn',
  ];

  /// Quét văn bản đầu vào để phát hiện nguy cơ
  static RiskScanResult scan(String text) {
    if (text.trim().isEmpty) return RiskScanResult.safe;

    final normalized = text.toLowerCase();

    // 1. Kiểm tra nguy cơ khẩn cấp (Critical)
    final matchedCritical = <String>[];
    for (final keyword in _criticalKeywords) {
      if (normalized.contains(keyword)) {
        matchedCritical.add(keyword);
      }
    }

    if (matchedCritical.isNotEmpty) {
      return RiskScanResult(
        level: RiskLevel.critical,
        matchedKeywords: matchedCritical,
        recommendation:
            'Phát hiện dấu hiệu khủng hoảng nghiêm trọng. Cần ưu tiên kết nối Đường dây nóng khẩn cấp (111 / 1900 599 958) ngay lập tức.',
      );
    }

    // 2. Kiểm tra nguy cơ cảnh báo (Warning)
    final matchedWarning = <String>[];
    for (final keyword in _warningKeywords) {
      if (normalized.contains(keyword)) {
        matchedWarning.add(keyword);
      }
    }

    if (matchedWarning.isNotEmpty) {
      return RiskScanResult(
        level: RiskLevel.warning,
        matchedKeywords: matchedWarning,
        recommendation:
            'Phát hiện tâm trạng bế tắc hoặc cảm xúc tiêu cực kéo dài. Khuyến khích người dùng thực hiện bài tập điều hòa nhịp thở và chia sẻ với người đáng tin cậy.',
      );
    }

    return RiskScanResult.safe;
  }
}
