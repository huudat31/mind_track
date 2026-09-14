import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/dashboard/models/frequency_analytics_model.dart';
import 'package:mind_track/features/assessment/models/dass21_model.dart';
import 'package:mind_track/features/logging/models/daily_log_model.dart';

void main() {
  group('Module 3: Frequency Dashboard Analytics Model Tests', () {
    test('DASS-21 longitudinal point scoring and severity calculation', () {
      final point = DassHistoryPoint(
        date: DateTime.now(),
        label: 'T0',
        depression: 16,
        anxiety: 14,
        stress: 22,
      );

      expect(point.depression, 16);
      expect(point.anxiety, 14);
      expect(point.stress, 22);

      expect(point.getSeverity(DassCategory.depression), isNotEmpty);
      expect(point.getSeverity(DassCategory.anxiety), isNotEmpty);
      expect(point.getSeverity(DassCategory.stress), isNotEmpty);
    });

    test('Clinical flag frequencies percentage and ordering calculation', () {
      final flagItem = ClinicalFlagItem(
        id: 'insomnia',
        name: 'Khó vào giấc',
        category: 'Giấc ngủ',
        icon: ClinicalFlagsCatalog.allFlags.first.icon,
      );

      final stat = FlagFrequencyStat(
        flag: flagItem,
        count: 7,
        totalDays: 14,
      );

      expect(stat.count, 7);
      expect(stat.totalDays, 14);
      expect(stat.percentage, closeTo(50.0, 0.01));
      expect(stat.fraction, closeTo(0.5, 0.01));
    });

    test('ClinicalFlagsCatalog item lookup by id', () {
      final item = ClinicalFlagsCatalog.getFlagById('insomnia');
      expect(item, isNotNull);
      expect(item!.name, 'Khó vào giấc');
      expect(item.category, 'Giấc ngủ');

      final unknown = ClinicalFlagsCatalog.getFlagById('non_existent');
      expect(unknown, isNull);
    });

    test('TimeframeOption days calculation', () {
      expect(TimeframeOption.fourteenDays.days, 14);
      expect(TimeframeOption.twoMonths.days, 60);
      expect(TimeframeOption.all.days, 3650);
      expect(TimeframeOption.all.isAll, isTrue);
    });
  });
}
