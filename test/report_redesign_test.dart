import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/report/models/report_config_model.dart';
import 'package:mind_track/features/report/widgets/report_config_bottom_sheet.dart';

void main() {
  group('Module 4: PDF Report Screen & Pop-up Redesign Tests', () {
    testWidgets('ReportConfigBottomSheet renders clinical summary and action button', (tester) async {
      ReportPrivacyConfig savedConfig = const ReportPrivacyConfig();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ReportConfigBottomSheet.show(
                    context: context,
                    initialConfig: savedConfig,
                    onSave: (cfg) => savedConfig = cfg,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Tóm Tắt & Cấu Hình Báo Cáo'), findsOneWidget);

      // Verify Clinical Value Card
      expect(find.text('Giá Trị Của Báo Cáo Trước Trị Liệu'), findsOneWidget);

      // Verify Action Button
      expect(find.text('Đã Hiểu & Xem Báo Cáo'), findsOneWidget);

      // Tap Action Button to dismiss and save
      await tester.tap(find.text('Đã Hiểu & Xem Báo Cáo'));
      await tester.pumpAndSettle();

      // Pop-up dismissed
      expect(find.text('Tóm Tắt & Cấu Hình Báo Cáo'), findsNothing);
    });
  });
}
