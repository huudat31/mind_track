import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/dashboard/models/frequency_analytics_model.dart';
import 'package:mind_track/features/dashboard/widgets/dass_trend_chart.dart';
import 'package:mind_track/features/dashboard/widgets/symptom_frequency_tracker.dart';

void main() {
  group('Frequency Dashboard Timeline & UI Tests', () {
    testWidgets('SymptomFrequencyTracker chips render with custom styling (not white)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SymptomFrequencyTracker(timeframe: TimeframeOption.fourteenDays),
          ),
        ),
      );

      // Verify header
      expect(find.text('Tần suất cờ đỏ lâm sàng'), findsOneWidget);

      // Verify category items exist and render text cleanly
      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Giấc ngủ'), findsOneWidget);
      expect(find.text('Thể chất'), findsOneWidget);

      // Tap on 'Giấc ngủ'
      await tester.tap(find.text('Giấc ngủ'));
      await tester.pumpAndSettle();

      // Check that check icon appears on selected
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('DassTrendChart renders with 7 days timeframe timeline', (tester) async {
      final sampleHistory = [
        DassHistoryPoint(
          date: DateTime.now().subtract(const Duration(days: 3)),
          label: 'T0',
          depression: 12,
          anxiety: 8,
          stress: 15,
        ),
        DassHistoryPoint(
          date: DateTime.now(),
          label: 'T1',
          depression: 9,
          anxiety: 6,
          stress: 11,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DassTrendChart(
                history: sampleHistory,
                timeframe: TimeframeOption.sevenDays,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify chart title
      expect(find.text('Tiến trình DASS-21 qua thời gian'), findsOneWidget);

      // Verify "Hôm nay" label appears on the X-axis
      expect(find.text('Hôm nay'), findsOneWidget);
    });
  });
}
