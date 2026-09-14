enum DassCategory { depression, anxiety, stress }

class DassQuestion {
  final int id;
  final String text;
  final DassCategory category;

  const DassQuestion({
    required this.id,
    required this.text,
    required this.category,
  });
}

class Dass21Data {
  static const List<DassQuestion> questions = [
    // 1. Stress
    DassQuestion(id: 1, text: 'Tôi cảm thấy khó mà thư giãn hoặc lấy lại bình tĩnh', category: DassCategory.stress),
    // 2. Anxiety
    DassQuestion(id: 2, text: 'Tôi cảm thấy bị khô cổ họng hoặc khó nuốt', category: DassCategory.anxiety),
    // 3. Depression
    DassQuestion(id: 3, text: 'Tôi dường như không còn cảm thấy hứng thú với bất cứ điều gì', category: DassCategory.depression),
    // 4. Anxiety
    DassQuestion(id: 4, text: 'Tôi bị khó thở (thở gấp, hụt hơi dù không vận động nặng)', category: DassCategory.anxiety),
    // 5. Depression
    DassQuestion(id: 5, text: 'Tôi thấy khó bắt đầu làm việc gì đó', category: DassCategory.depression),
    // 6. Stress
    DassQuestion(id: 6, text: 'Tôi có xu hướng phản ứng thái quá trước các tình huống', category: DassCategory.stress),
    // 7. Anxiety
    DassQuestion(id: 7, text: 'Tôi cảm thấy run rẩy (ví dụ như ở tay)', category: DassCategory.anxiety),
    // 8. Stress
    DassQuestion(id: 8, text: 'Tôi cảm thấy tiêu tốn nhiều năng lượng cho sự bồn chồn', category: DassCategory.stress),
    // 9. Anxiety
    DassQuestion(id: 9, text: 'Tôi lo lắng về những tình huống có thể làm tôi hoảng sợ', category: DassCategory.anxiety),
    // 10. Depression
    DassQuestion(id: 10, text: 'Tôi cảm thấy mình không có gì đáng để mong đợi ở tương lai', category: DassCategory.depression),
    // 11. Stress
    DassQuestion(id: 11, text: 'Tôi thấy mình dễ bị bực mình, kích động', category: DassCategory.stress),
    // 12. Stress
    DassQuestion(id: 12, text: 'Tôi thấy khó thư giãn đầu óc', category: DassCategory.stress),
    // 13. Depression
    DassQuestion(id: 13, text: 'Tôi cảm thấy buồn bã, ủ rũ', category: DassCategory.depression),
    // 14. Stress
    DassQuestion(id: 14, text: 'Tôi không thể chịu đựng được bất cứ điều gì cản trở việc tôi đang làm', category: DassCategory.stress),
    // 15. Anxiety
    DassQuestion(id: 15, text: 'Tôi cảm thấy gần như hoảng loạn', category: DassCategory.anxiety),
    // 16. Depression
    DassQuestion(id: 16, text: 'Tôi không thể hăng hái với bất kỳ việc gì', category: DassCategory.depression),
    // 17. Depression
    DassQuestion(id: 17, text: 'Tôi cảm thấy mình không có nhiều giá trị như một con người', category: DassCategory.depression),
    // 18. Stress
    DassQuestion(id: 18, text: 'Tôi thấy mình khá nhạy cảm, dễ phật ý', category: DassCategory.stress),
    // 19. Anxiety
    DassQuestion(id: 19, text: 'Tôi nghe thấy rõ tiếng tim đập dù không tập thể dục', category: DassCategory.anxiety),
    // 20. Anxiety
    DassQuestion(id: 20, text: 'Tôi cảm thấy sợ hãi vô cớ', category: DassCategory.anxiety),
    // 21. Depression
    DassQuestion(id: 21, text: 'Tôi cảm thấy cuộc sống không có nhiều ý nghĩa', category: DassCategory.depression),
  ];

  static const List<String> optionLabels = [
    'Không đúng chút nào',
    'Đúng một phần / Thỉnh thoảng',
    'Đúng khá nhiều / Thường xuyên',
    'Rất đúng / Hầu hết thời gian',
  ];

  // Ngưỡng phân loại chuẩn của DASS-21 (nhân hệ số 2)
  static String getSeverity(DassCategory category, int score) {
    switch (category) {
      case DassCategory.depression:
        if (score <= 9) return 'Bình thường';
        if (score <= 13) return 'Nhẹ';
        if (score <= 20) return 'Vừa phải';
        if (score <= 27) return 'Nặng';
        return 'Rất nặng';
      case DassCategory.anxiety:
        if (score <= 7) return 'Bình thường';
        if (score <= 9) return 'Nhẹ';
        if (score <= 14) return 'Vừa phải';
        if (score <= 19) return 'Nặng';
        return 'Rất nặng';
      case DassCategory.stress:
        if (score <= 14) return 'Bình thường';
        if (score <= 18) return 'Nhẹ';
        if (score <= 25) return 'Vừa phải';
        if (score <= 33) return 'Nặng';
        return 'Rất nặng';
    }
  }

  static double getSeverityFraction(DassCategory category, int score) {
    // Tối đa 42 điểm (7 câu * 3 điểm tối đa * hệ số 2)
    return (score / 42.0).clamp(0.0, 1.0);
  }
}

