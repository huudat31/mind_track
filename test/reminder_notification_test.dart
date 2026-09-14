import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/core/services/reminder_preferences_service.dart';
import 'package:mind_track/features/home/widgets/reminder_settings_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Reminder Notification & Settings Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ReminderSettings model copyWith works properly', () {
      const initial = ReminderSettings(
        isEnabled: true,
        morningTime: TimeOfDay(hour: 8, minute: 30),
        eveningTime: TimeOfDay(hour: 21, minute: 0),
      );

      final modified = initial.copyWith(
        isEnabled: false,
        morningTime: const TimeOfDay(hour: 7, minute: 45),
      );

      expect(modified.isEnabled, false);
      expect(modified.morningTime.hour, 7);
      expect(modified.morningTime.minute, 45);
      expect(modified.eveningTime.hour, 21);
      expect(modified.eveningTime.minute, 0);
    });

    test('ReminderPreferencesService saves and loads settings', () async {
      SharedPreferences.setMockInitialValues({});

      // Default load
      final defaultSettings = await ReminderPreferencesService.getSettings();
      expect(defaultSettings.isEnabled, true);
      expect(defaultSettings.morningTime.hour, 8);
      expect(defaultSettings.morningTime.minute, 30);
      expect(defaultSettings.eveningTime.hour, 21);
      expect(defaultSettings.eveningTime.minute, 0);

      // Save new settings
      const newSettings = ReminderSettings(
        isEnabled: true,
        morningTime: TimeOfDay(hour: 9, minute: 15),
        eveningTime: TimeOfDay(hour: 22, minute: 30),
      );

      final success = await ReminderPreferencesService.saveSettings(
        newSettings,
      );
      expect(success, true);

      final loaded = await ReminderPreferencesService.getSettings();
      expect(loaded.isEnabled, true);
      expect(loaded.morningTime.hour, 9);
      expect(loaded.morningTime.minute, 15);
      expect(loaded.eveningTime.hour, 22);
      expect(loaded.eveningTime.minute, 30);
    });

    testWidgets('ReminderSettingsBottomSheet renders controls properly', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ReminderSettingsBottomSheet())),
      );

      await tester.pumpAndSettle();

      expect(find.text('Cài Đặt Lịch Nhắc Cảm Xúc'), findsOneWidget);
      expect(find.text('Nhắc nhở hàng ngày'), findsOneWidget);

      expect(find.text('Khởi đầu ngày mới (Sáng)'), findsOneWidget);
      expect(find.text('Tổng kết cuối ngày (Tối)'), findsOneWidget);

      expect(find.text('Gửi thử thông báo ngay bây giờ'), findsOneWidget);
      expect(find.text('Lưu & Kích Hoạt Lịch Nhắc'), findsOneWidget);
    });
  });
}
