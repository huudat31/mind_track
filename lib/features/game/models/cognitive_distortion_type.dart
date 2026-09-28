/// 6 dạng méo mó nhận thức (Cognitive Distortions) CBT cốt lõi
enum DistortionType {
  labeling('labeling'),
  catastrophizing('catastrophizing'),
  allOrNothing('all_or_nothing'),
  personalization('personalization'),
  mindReading('mind_reading'),
  emotionalReasoning('emotional_reasoning');

  final String id;
  const DistortionType(this.id);

  static DistortionType fromId(String id) {
    return values.firstWhere(
      (t) => t.id == id,
      orElse: () => throw FormatException('DistortionType không hợp lệ trong dữ liệu: "$id"'),
    );
  }

  static DistortionType? fromString(String key) {
    final clean = key.trim().toLowerCase();
    for (final v in values) {
      if (v.id == clean || v.name.toLowerCase() == clean) return v;
    }
    // Mapping alias
    switch (clean) {
      case 'suy_dien_tieu_cuc':
      case 'arbitrary_inference':
        return DistortionType.mindReading;
      case 'tham_hoa_hoa':
        return DistortionType.catastrophizing;
      case 'trang_den':
      case 'black_and_white':
        return DistortionType.allOrNothing;
      case 'gan_nhan':
        return DistortionType.labeling;
      case 'tu_do_loi':
      case 'over_personalization':
        return DistortionType.personalization;
      case 'cam_tinh':
      case 'emotional':
        return DistortionType.emotionalReasoning;
      default:
        return null;
    }
  }

  String get displayName {
    switch (this) {
      case DistortionType.labeling:
        return 'Dán nhãn';
      case DistortionType.catastrophizing:
        return 'Thảm họa hóa';
      case DistortionType.allOrNothing:
        return 'Nghĩ trắng - đen';
      case DistortionType.personalization:
        return 'Cá nhân hóa';
      case DistortionType.mindReading:
        return 'Đọc suy nghĩ';
      case DistortionType.emotionalReasoning:
        return 'Lý luận cảm tính';
    }
  }

  String get shortDescription {
    switch (this) {
      case DistortionType.labeling:
        return 'Dùng một sai sót cụ thể để định nghĩa toàn bộ giá trị con người mình.';
      case DistortionType.catastrophizing:
        return 'Phóng đại một lỗi nhỏ thành thảm họa sụp đổ không thể cứu vãn.';
      case DistortionType.allOrNothing:
        return 'Chỉ nhìn mọi việc ở hai thái cực: hoàn hảo hoặc thất bại hoàn toàn.';
      case DistortionType.personalization:
        return 'Tự nhận toàn bộ trách nhiệm về những sự việc nằm ngoài tầm kiểm soát của bản thân.';
      case DistortionType.mindReading:
        return 'Tự cho rằng người khác đang nghĩ xấu hoặc ghét bỏ mình mà không có bằng chứng.';
      case DistortionType.emotionalReasoning:
        return 'Đánh đồng cảm xúc tạm thời với sự thật khách quan (Tôi cảm thấy thế nào thì sự thật là thế đó).';
    }
  }
}

/// Type alias đảm bảo tính tương thích ngược hoàn toàn
typedef CognitiveDistortionType = DistortionType;
