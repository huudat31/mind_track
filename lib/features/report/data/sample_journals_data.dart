import '../models/report_config_model.dart';

class SampleJournalsData {
  static final List<CbtJournalExcerpt> allEntries = [
    CbtJournalExcerpt(
      id: 'journal_1',
      date: DateTime.now().subtract(const Duration(days: 3)),
      dateLabel: '3 ngày trước',
      contextTag: 'Công việc',
      situation: 'Trưởng phòng gửi email yêu cầu nộp báo cáo quý sớm hơn dự kiến 2 ngày.',
      automaticThought: 'Mình chắc chắn sẽ không kịp, mọi người sẽ nhìn nhận mình là kẻ kém cỏi và thiếu trách nhiệm.',
      balancedResponse: 'Khung giờ quả thực gấp gáp, nhưng mình đã hoàn tất 70% nội dung. Mình có thể ưu tiên số liệu chính và đề xuất sếp hỗ trợ nếu cần.',
    ),
    CbtJournalExcerpt(
      id: 'journal_2',
      date: DateTime.now().subtract(const Duration(days: 7)),
      dateLabel: '7 ngày trước',
      contextTag: 'Một mình',
      situation: 'Trằn trọc đến 1h30 sáng vẫn không thể chợp mắt, nghe rõ tiếng tim đập.',
      automaticThought: 'Nếu đêm nay không ngủ được, ngày mai đầu óc sẽ đờ đẫn và mình sẽ phá hỏng buổi thuyết trình.',
      balancedResponse: 'Cơ thể vẫn đang thả lỏng trên giường. Càng ép mình ngủ thì càng căng thẳng. Mình sẽ thở 4-4-4-4 và chấp nhận ngày mai có thể hơi mệt.',
    ),
    CbtJournalExcerpt(
      id: 'journal_3',
      date: DateTime.now().subtract(const Duration(days: 11)),
      dateLabel: '11 ngày trước',
      contextTag: 'Gia đình',
      situation: 'Bố mẹ hỏi thăm về kế hoạch tương lai và việc lập gia đình trong bữa tối.',
      automaticThought: 'Mình đang tụt lại phía sau so với bạn bè cùng trang lứa và khiến bố mẹ thất vọng.',
      balancedResponse: 'Mỗi người có nhịp sống riêng. Hiện tại ưu tiên số 1 của mình là phục hồi sức khỏe tinh thần và ổn định năng lượng cá nhân.',
    ),
  ];
}
