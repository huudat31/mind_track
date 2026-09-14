import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/reminder_preferences_service.dart';

class ReminderSettingsBottomSheet extends StatefulWidget {
  const ReminderSettingsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReminderSettingsBottomSheet(),
    );
  }

  @override
  State<ReminderSettingsBottomSheet> createState() =>
      _ReminderSettingsBottomSheetState();
}

class _ReminderSettingsBottomSheetState
    extends State<ReminderSettingsBottomSheet> {
  bool _isLoading = true;
  bool _isEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ReminderPreferencesService.getSettings();
    if (mounted) {
      setState(() {
        _isEnabled = settings.isEnabled;
        _morningTime = settings.morningTime;
        _eveningTime = settings.eveningTime;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickTime({required bool isMorning}) async {
    final initial = isMorning ? _morningTime : _eveningTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryLight,
              onPrimary: Colors.black,
              surface: Color(0xFF16252C),
              onSurface: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF16252C),
              hourMinuteTextColor: Colors.white,
              dayPeriodTextColor: Colors.white,
              dialBackgroundColor: const Color(0xFF0E1418),
              dialHandColor: AppColors.primaryLight,
              dialTextColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (isMorning) {
          _morningTime = picked;
        } else {
          _eveningTime = picked;
        }
      });
    }
  }

  Future<void> _sendTestNotification() async {
    await NotificationService.sendTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryLight,
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Đã gửi thông báo thử! Hãy kiểm tra thanh thông báo điện thoại.',
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF16252C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _saveAndApply() async {
    final newSettings = ReminderSettings(
      isEnabled: _isEnabled,
      morningTime: _morningTime,
      eveningTime: _eveningTime,
    );

    await ReminderPreferencesService.saveSettings(newSettings);
    await NotificationService.applySchedule(newSettings);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.alarm_on_rounded,
                color: AppColors.primaryLight,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isEnabled
                      ? 'Đã bật lịch nhắc: Sáng ${_morningTime.formatLocal()} - Tối ${_eveningTime.formatLocal()}'
                      : 'Đã tắt lịch nhắc nhở hàng ngày',
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF16252C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF141F25),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 32,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: _isLoading
          ? const SizedBox(
              height: 250,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryLight),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.primaryLight,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cài Đặt Lịch Nhắc Cảm Xúc',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tự động nhắc bạn lắng nghe tâm trí định kỳ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Master Toggle Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _isEnabled
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nhắc nhở hàng ngày',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isEnabled
                                  ? 'Đang bật nhắc nhở đúng giờ'
                                  : 'Đang tạm dừng thông báo',
                              style: TextStyle(
                                fontSize: 12,
                                color: _isEnabled
                                    ? AppColors.primaryLight
                                    : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _isEnabled,
                        activeColor: AppColors.primaryLight,
                        activeTrackColor: AppColors.primary.withValues(
                          alpha: 0.5,
                        ),
                        onChanged: (val) => setState(() => _isEnabled = val),
                      ),
                    ],
                  ),
                ),

                if (_isEnabled) ...[
                  const SizedBox(height: 14),

                  // Morning Slot
                  _buildTimeSlotCard(
                    title: 'Khởi đầu ngày mới (Sáng)',
                    subtitle: 'Lắng nghe mức năng lượng đầu ngày',
                    icon: Icons.wb_sunny_rounded,
                    iconColor: const Color(0xFFF4A261),
                    time: _morningTime,
                    onTap: () => _pickTime(isMorning: true),
                  ),

                  const SizedBox(height: 10),

                  // Evening Slot
                  _buildTimeSlotCard(
                    title: 'Tổng kết cuối ngày (Tối)',
                    subtitle: 'Giải tỏa căng thẳng trước khi ngủ',
                    icon: Icons.nights_stay_rounded,
                    iconColor: const Color(0xFF9D4EDD),
                    time: _eveningTime,
                    onTap: () => _pickTime(isMorning: false),
                  ),
                ],

                const SizedBox(height: 20),

                // Test Notification Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _sendTestNotification,
                    icon: const Icon(
                      Icons.ring_volume_rounded,
                      size: 18,
                      color: AppColors.primaryLight,
                    ),
                    label: const Text(
                      'Gửi thử thông báo ngay bây giờ',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: AppColors.primaryLight.withValues(alpha: 0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.02),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Save & Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveAndApply,
                    icon: const Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Lưu & Kích Hoạt Lịch Nhắc',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTimeSlotCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time.formatLocal(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: AppColors.primaryLight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
