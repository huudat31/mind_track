import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/dashboard/data/clinical_data_repository.dart';
import 'package:mind_track/features/dashboard/models/frequency_analytics_model.dart';
import 'package:mind_track/features/assessment/models/dass21_model.dart';

void main() {
  group('Module 3: Frequency Dashboard Analytics Tests', () {
    test('DASS-21 longitudinal trend data is consistent', () {
      final trend7 = ClinicalDataRepository.getDassTrend(TimeframeOption.sevenDays);
      final trend14 = ClinicalDataRepository.getDassTrend(TimeframeOption.fourteenDays);
      final trend28 = ClinicalDataRepository.getDassTrend(TimeframeOption.twentyEightDays);

      expect(trend7.length, 2);
      expect(trend14.length, 3);
      expect(trend28.length, 5);

      for (final pt in trend28) {
        expect(pt.depression, inInclusiveRange(0, 42));
        expect(pt.anxiety, inInclusiveRange(0, 42));
        expect(pt.stress, inInclusiveRange(0, 42));
        expect(pt.getSeverity(DassCategory.depression), isNotEmpty);
      }
    });

    test('Clinical flag frequencies sort descending and calculate percentages correctly', () {
      final flags14 = ClinicalDataRepository.getFlagFrequencies(TimeframeOption.fourteenDays);

      expect(flags14.isNotEmpty, true);
      // Verify descending sort
      for (int i = 0; i < flags14.length - 1; i++) {
        expect(flags14[i].count >= flags14[i + 1].count, true);
      }

      // Check percentage calculation
      final topFlag = flags14.first;
      expect(topFlag.percentage, closeTo((topFlag.count / 14) * 100, 0.01));
    });

    test('Co-occurrence insights comply with non-causal requirements', () {
      final insights = ClinicalDataRepository.getCoOccurrenceInsights(TimeframeOption.fourteenDays);

      expect(insights.length, greaterThanOrEqualTo(3));
      for (final item in insights) {
        expect(item.percentage, inInclusiveRange(1, 100));
        expect(item.observation.isNotEmpty, true);
        expect(item.factorA.isNotEmpty, true);
        expect(item.factorB.isNotEmpty, true);
      }
    });
  });
}
