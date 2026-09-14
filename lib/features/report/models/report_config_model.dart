import '../../dashboard/models/frequency_analytics_model.dart';

class CbtJournalExcerpt {
  final String id;
  final DateTime date;
  final String dateLabel;
  final String contextTag;
  final String situation;
  final String automaticThought;
  final String balancedResponse;

  const CbtJournalExcerpt({
    required this.id,
    required this.date,
    required this.dateLabel,
    required this.contextTag,
    required this.situation,
    required this.automaticThought,
    required this.balancedResponse,
  });
}

class ReportPrivacyConfig {
  final bool isAnonymous;
  final String anonymousCode;
  final String userName;
  final TimeframeOption timeframe;
  final bool includeDass21;
  final bool includeSymptomFrequency;
  final bool includeCoOccurrence;
  final Set<String> selectedJournalIds;
  final String therapistNote;

  const ReportPrivacyConfig({
    this.isAnonymous = true,
    this.anonymousCode = 'MT-89421',
    this.userName = 'Nguyễn Văn A',
    this.timeframe = TimeframeOption.fourteenDays,
    this.includeDass21 = true,
    this.includeSymptomFrequency = true,
    this.includeCoOccurrence = true,
    this.selectedJournalIds = const {'journal_1', 'journal_2'},
    this.therapistNote = 'Tôi muốn tìm hiểu sâu hơn về tình trạng mất ngủ kéo dài và cảm giác căng cơ mỗi khi đối diện với deadline công việc.',
  });

  ReportPrivacyConfig copyWith({
    bool? isAnonymous,
    String? anonymousCode,
    String? userName,
    TimeframeOption? timeframe,
    bool? includeDass21,
    bool? includeSymptomFrequency,
    bool? includeCoOccurrence,
    Set<String>? selectedJournalIds,
    String? therapistNote,
  }) {
    return ReportPrivacyConfig(
      isAnonymous: isAnonymous ?? this.isAnonymous,
      anonymousCode: anonymousCode ?? this.anonymousCode,
      userName: userName ?? this.userName,
      timeframe: timeframe ?? this.timeframe,
      includeDass21: includeDass21 ?? this.includeDass21,
      includeSymptomFrequency: includeSymptomFrequency ?? this.includeSymptomFrequency,
      includeCoOccurrence: includeCoOccurrence ?? this.includeCoOccurrence,
      selectedJournalIds: selectedJournalIds ?? this.selectedJournalIds,
      therapistNote: therapistNote ?? this.therapistNote,
    );
  }

  String get clientDisplayName => isAnonymous ? 'Hồ sơ ẩn danh ($anonymousCode)' : userName;
}
