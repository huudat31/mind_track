import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'reminder_preferences_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int morningReminderId = 101;
  static const int eveningReminderId = 102;
  static const int testNotificationId = 999;

  static const String channelId = 'daily_checkin_channel';
  static const String channelName = 'Nhắc nhở cập nhật cảm xúc';
  static const String channelDescription =
      'Thông báo nhắc nhở kiểm tra cảm xúc và năng lượng định kỳ';

  static bool _isInitialized = false;

  /// Khởi tạo Notification Plugin và thiết lập timezone
  static Future<void> init({
    Function(NotificationResponse)? onNotificationTap,
  }) async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      // Đặt múi giờ mặc định nếu chưa xác định
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
      } catch (_) {
        // Fallback sang local timezone nếu không tìm thấy chuỗi
      }

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
      );

      _isInitialized = true;
      debugPrint('✅ NotificationService initialized successfully!');
    } catch (e) {
      debugPrint('❌ Lỗi khởi tạo NotificationService: $e');
    }
  }

  /// Yêu cầu cấp quyền gửi thông báo từ người dùng
  static Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final androidGranted =
          await androidImplementation?.requestNotificationsPermission() ?? true;

      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final iosGranted =
          await iosImplementation?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;

      return androidGranted && iosGranted;
    } catch (e) {
      debugPrint('Lỗi xin quyền thông báo: $e');
      return false;
    }
  }

  /// Gửi thông báo thử nghiệm ngay lập tức để người dùng kiểm tra âm thanh/giao diện
  static Future<void> sendTestNotification() async {
    await requestPermissions();

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2A9D8F),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      testNotificationId,
      'MindTrack Thử Nghiệm 🔔',
      'Thông báo nhắc nhở đã sẵn sàng! Chúc bạn một ngày bình an và vững vàng tâm trí 🌱',
      details,
    );
  }

  /// Áp dụng lịch nhắc nhở từ cài đặt đã lưu
  static Future<void> applySchedule(ReminderSettings settings) async {
    if (!settings.isEnabled) {
      await cancelDailyReminders();
      return;
    }

    await requestPermissions();

    // 1. Hẹn giờ buổi sáng
    await _scheduleDaily(
      id: morningReminderId,
      time: settings.morningTime,
      title: 'Khởi đầu ngày mới cùng MindTrack ☀️',
      body:
          'Dành 1 phút lắng nghe năng lượng và cảm xúc đầu ngày của bạn nhé 🌱',
    );

    // 2. Hẹn giờ buổi tối
    await _scheduleDaily(
      id: eveningReminderId,
      time: settings.eveningTime,
      title: 'Nhìn lại một ngày trôi qua 🌙',
      body:
          'Ghi lại cảm xúc và giải tỏa những băn khoăn trước khi đi ngủ nhé ✨',
    );

    debugPrint(
      '🔔 Đã lên lịch nhắc nhở: Sáng ${settings.morningTime.formatLocal()} - Tối ${settings.eveningTime.formatLocal()}',
    );
  }

  /// Lên lịch thông báo lặp lại hàng ngày theo giờ chỉ định
  static Future<void> _scheduleDaily({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    try {
      final scheduledDate = _nextInstanceOfTime(time.hour, time.minute);

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF2A9D8F),
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Lỗi đặt lịch thông báo id=$id: $e');
    }
  }

  /// Tính toán mốc thời gian tiếp theo theo giờ và phút
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Hủy các thông báo định kỳ hàng ngày
  static Future<void> cancelDailyReminders() async {
    try {
      await _notificationsPlugin.cancel(morningReminderId);
      await _notificationsPlugin.cancel(eveningReminderId);
      debugPrint('🔕 Đã hủy toàn bộ lịch nhắc nhở hàng ngày.');
    } catch (e) {
      debugPrint('Lỗi khi hủy thông báo: $e');
    }
  }
}

extension TimeOfDayFormatExtension on TimeOfDay {
  String formatLocal() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
