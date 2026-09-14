import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderSettings {
  final bool isEnabled;
  final TimeOfDay morningTime;
  final TimeOfDay eveningTime;

  const ReminderSettings({
    required this.isEnabled,
    required this.morningTime,
    required this.eveningTime,
  });

  ReminderSettings copyWith({
    bool? isEnabled,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
  }) {
    return ReminderSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      morningTime: morningTime ?? this.morningTime,
      eveningTime: eveningTime ?? this.eveningTime,
    );
  }
}

class ReminderPreferencesService {
  static const String _keyEnabled = 'reminder_enabled';
  static const String _keyMorningHour = 'reminder_morning_hour';
  static const String _keyMorningMinute = 'reminder_morning_minute';
  static const String _keyEveningHour = 'reminder_evening_hour';
  static const String _keyEveningMinute = 'reminder_evening_minute';

  /// Nạp cài đặt nhắc nhở từ SharedPreferences (mặc định: Bật, Sáng 08:30, Tối 21:00)
  static Future<ReminderSettings> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_keyEnabled) ?? true;
      final morningHour = prefs.getInt(_keyMorningHour) ?? 8;
      final morningMinute = prefs.getInt(_keyMorningMinute) ?? 30;
      final eveningHour = prefs.getInt(_keyEveningHour) ?? 21;
      final eveningMinute = prefs.getInt(_keyEveningMinute) ?? 0;

      return ReminderSettings(
        isEnabled: isEnabled,
        morningTime: TimeOfDay(hour: morningHour, minute: morningMinute),
        eveningTime: TimeOfDay(hour: eveningHour, minute: eveningMinute),
      );
    } catch (e) {
      debugPrint('Lỗi đọc ReminderSettings: $e');
      return const ReminderSettings(
        isEnabled: true,
        morningTime: TimeOfDay(hour: 8, minute: 30),
        eveningTime: TimeOfDay(hour: 21, minute: 0),
      );
    }
  }

  /// Lưu cài đặt nhắc nhở vào SharedPreferences
  static Future<bool> saveSettings(ReminderSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyEnabled, settings.isEnabled);
      await prefs.setInt(_keyMorningHour, settings.morningTime.hour);
      await prefs.setInt(_keyMorningMinute, settings.morningTime.minute);
      await prefs.setInt(_keyEveningHour, settings.eveningTime.hour);
      await prefs.setInt(_keyEveningMinute, settings.eveningTime.minute);
      return true;
    } catch (e) {
      debugPrint('Lỗi lưu ReminderSettings: $e');
      return false;
    }
  }
}
