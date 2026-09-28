enum CognitiveDistortionType {
  arbitraryInference, // Suy diễn tiêu cực (Đọc suy nghĩ / Đoán trước tương lai)
  catastrophizing, // Thảm họa hóa
  blackAndWhite, // Nghĩ trắng - đen (Tất cả hoặc không có gì)
  labeling, // Gán nhãn bản thân
  overPersonalization, // Tự đổ lỗi quá mức
  rigidShoulds; // Phải / Nên cứng nhắc

  String get displayName {
    switch (this) {
      case CognitiveDistortionType.arbitraryInference:
        return 'Suy diễn tiêu cực';
      case CognitiveDistortionType.catastrophizing:
        return 'Thảm họa hóa';
      case CognitiveDistortionType.blackAndWhite:
        return 'Nghĩ trắng - đen';
      case CognitiveDistortionType.labeling:
        return 'Gán nhãn bản thân';
      case CognitiveDistortionType.overPersonalization:
        return 'Tự đổ lỗi quá mức';
      case CognitiveDistortionType.rigidShoulds:
        return 'Phải / Nên cứng nhắc';
    }
  }

  String get shortDescription {
    switch (this) {
      case CognitiveDistortionType.arbitraryInference:
        return 'Tự cho rằng người khác nghĩ xấu về mình hoặc đoán chắc điều tồi tệ sắp xảy ra mà không có bằng chứng.';
      case CognitiveDistortionType.catastrophizing:
        return 'Phóng đại một lỗi nhỏ thành thảm họa không thể cứu vãn.';
      case CognitiveDistortionType.blackAndWhite:
        return 'Chỉ nhìn mọi việc ở hai thái cực: hoàn hảo hoặc thất bại hoàn toàn.';
      case CognitiveDistortionType.labeling:
        return 'Dùng một sai sót cụ thể để định nghĩa toàn bộ giá trị con người mình.';
      case CognitiveDistortionType.overPersonalization:
        return 'Tự nhận trách nhiệm về những sự việc nằm ngoài tầm kiểm soát của bản thân.';
      case CognitiveDistortionType.rigidShoulds:
        return 'Tự áp đặt những tiêu chuẩn quá khắt khe khiến bản thân luôn cảm thấy tội lỗi hoặc bức bối.';
    }
  }

  static CognitiveDistortionType? fromString(String key) {
    switch (key.trim().toLowerCase()) {
      case 'arbitrary_inference':
      case 'arbitraryinference':
      case 'suy_dien_tieu_cuc':
        return CognitiveDistortionType.arbitraryInference;
      case 'catastrophizing':
      case 'tham_hoa_hoa':
        return CognitiveDistortionType.catastrophizing;
      case 'black_and_white':
      case 'blackandwhite':
      case 'trang_den':
        return CognitiveDistortionType.blackAndWhite;
      case 'labeling':
      case 'gan_nhan':
        return CognitiveDistortionType.labeling;
      case 'over_personalization':
      case 'overpersonalization':
      case 'tu_do_loi':
        return CognitiveDistortionType.overPersonalization;
      case 'rigid_shoulds':
      case 'rigidshoulds':
      case 'phai_nen':
        return CognitiveDistortionType.rigidShoulds;
      default:
        return null;
    }
  }
}
