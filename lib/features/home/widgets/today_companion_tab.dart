import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/hotline_dialog.dart';
import '../../breathing/screens/box_breathing_screen.dart';

class TodayCompanionTab extends StatefulWidget {
  final Function(int)? onSelectTab;

  const TodayCompanionTab({super.key, this.onSelectTab});

  @override
  State<TodayCompanionTab> createState() => _TodayCompanionTabState();
}

class _TodayCompanionTabState extends State<TodayCompanionTab> {
  final bool _hasLoggedToday = true;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Chào buổi sáng ☀️';
    } else if (hour >= 12 && hour < 18) {
      return 'Chào buổi chiều 🌤️';
    } else {
      return 'Chào buổi tối 🌙';
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
    final weekday = weekdays[now.weekday - 1];
    return '$weekday, ${now.day}/${now.month}/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF16252C),
            Color(0xFF0E1418),
            Color(0xFF0A0E11),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
          children: [
            // Top App Bar
            _buildHeader(context),

            const SizedBox(height: 20),

            // 1. Hero Card: Today's Clinical Status
            _buildTodayStatusCard(),

            const SizedBox(height: 20),

            // 2. Pre-Therapy 28-Day Streak & Observation Progress
            _buildStreakCalendarCard(),

            const SizedBox(height: 20),

            // 3. Weekly Clinical Snapshot (Bento metrics)
            _buildWeeklySnapshotCard(),

            const SizedBox(height: 20),

            // 4. Quick Grounding Action: Box Breathing 4-4-4-4
            _buildQuickBreathingCard(context),

            const SizedBox(height: 20),

            // 5. Mindful Reflection Anchor
            _buildMindfulAnchorCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.65),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Hôm Nay Của Bạn',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _getFormattedDate(),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.primaryLight.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => HotlineDialog.show(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE07A5F).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE07A5F).withValues(alpha: 0.35)),
            ),
            child: const Row(
              children: [
                Icon(Icons.support_agent_rounded, color: Color(0xFFE07A5F), size: 18),
                SizedBox(width: 6),
                Text(
                  'Hotline',
                  style: TextStyle(
                    color: Color(0xFFE07A5F),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E3834).withValues(alpha: 0.85),
            const Color(0xFF15262B).withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _hasLoggedToday ? Icons.check_circle_rounded : Icons.access_time_rounded,
                      color: AppColors.primaryLight,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _hasLoggedToday ? 'ĐÃ CHECK-IN HÔM NAY' : 'CHƯA GHI NHẬN HÔM NAY',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Jump to Tab 2 (Cảm xúc)
                  widget.onSelectTab?.call(2);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _hasLoggedToday ? 'Ghi nhận thêm' : 'Bắt đầu ngay',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Mood and Energy row
          Row(
            children: [
              // Flower avatar badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2A9D8F).withValues(alpha: 0.4),
                      AppColors.primary.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5), width: 1.5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.spa_rounded,
                    size: 30,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tâm trạng: Hơi Dễ Chịu (+0.67)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 15, color: Color(0xFFF4A261)),
                        const SizedBox(width: 4),
                        Text(
                          'Mức năng lượng: 3.5 / 5.0 (Ổn định)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Logged Tags & Clinical flags today
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildMicroPill(Icons.work_outline_rounded, 'Bối cảnh: Công việc', Colors.white38),
              _buildMicroPill(Icons.bedtime_outlined, 'Cờ đỏ: Khó vào giấc', const Color(0xFFE07A5F)),
              _buildMicroPill(Icons.accessibility_new_outlined, 'Cơ thể: Căng cơ vai', const Color(0xFFF4A261)),
            ],
          ),

          const SizedBox(height: 14),

          // Micro CBT thought snippet
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.psychology_outlined, size: 16, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Suy nghĩ cân bằng hôm nay: “Thời hạn gấp gáp nhưng mình đã xong 70% nội dung. Mình có thể chia nhỏ việc để xử lý nhẹ nhàng.”',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroPill(IconData icon, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: AppColors.primaryLight, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Chu kỳ 28 ngày trước trị liệu',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Chuỗi 8 ngày 🔥',
                  style: TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Mỗi ngày check-in bổ sung thêm một mảnh ghép dữ liệu lâm sàng cho nhà trị liệu của bạn.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, height: 1.35),
          ),

          const SizedBox(height: 14),

          // 28-Day interactive dots track
          _build28DayGrid(),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến trình: 8 / 28 ngày (28%)',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600),
              ),
              Text(
                'Còn 20 ngày đến mốc phiên 1',
                style: TextStyle(color: AppColors.primaryLight.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build28DayGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalDays = 28;
        final currentDay = 8;
        final columns = 7;
        final rows = (totalDays / columns).ceil();

        return Column(
          children: List.generate(rows, (r) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(columns, (c) {
                  final dayIndex = r * columns + c + 1;
                  final isPast = dayIndex < currentDay;
                  final isToday = dayIndex == currentDay;

                  // Color sequence for past days to show emotional trajectory
                  final pastMoodColors = [
                    const Color(0xFFF4A261), // day 1 (bad)
                    const Color(0xFFE07A5F), // day 2 (very bad)
                    const Color(0xFFF4A261), // day 3 (bad)
                    const Color(0xFF818AA3), // day 4 (neutral)
                    const Color(0xFF7E9F9B), // day 5 (good)
                    const Color(0xFF7E9F9B), // day 6 (good)
                    const Color(0xFF2A9D8F), // day 7 (very good)
                  ];

                  Color dotColor;
                  if (isPast) {
                    dotColor = pastMoodColors[(dayIndex - 1) % pastMoodColors.length];
                  } else if (isToday) {
                    dotColor = AppColors.primaryLight;
                  } else {
                    dotColor = Colors.white.withValues(alpha: 0.08);
                  }

                  return Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary.withValues(alpha: 0.45)
                          : (isPast ? dotColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday
                            ? AppColors.primaryLight
                            : (isPast ? dotColor.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.1)),
                        width: isToday ? 2 : 1,
                      ),
                      boxShadow: isToday
                          ? [
                              BoxShadow(
                                color: AppColors.primaryLight.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: isPast
                        ? Icon(Icons.check, size: 14, color: dotColor)
                        : Text(
                            '$dayIndex',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                              color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildWeeklySnapshotCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.insights_rounded, color: Color(0xFFF4A261), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Tóm Tắt Tuần Này',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // Jump to Tab 3 (Tần suất)
                  widget.onSelectTab?.call(3);
                },
                child: Text(
                  'Xem chi tiết >',
                  style: TextStyle(
                    color: AppColors.primaryLight.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildBentoMetric(
                  label: 'Tâm trạng tuần',
                  value: 'Tạm ổn',
                  sub: '62% thời gian',
                  accent: const Color(0xFF7E9F9B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBentoMetric(
                  label: 'Năng lượng TB',
                  value: '2.9 / 5',
                  sub: 'Tụt nhẹ thứ 4-5',
                  accent: const Color(0xFFF4A261),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBentoMetric(
                  label: 'Cờ đỏ lặp lại',
                  value: 'Khó ngủ',
                  sub: '5/7 ngày ghi nhận',
                  accent: const Color(0xFFE07A5F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoMetric({
    required String label,
    required String value,
    required String sub,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.55)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: accent),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBreathingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B2F3D).withValues(alpha: 0.8),
            AppColors.darkCard.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.air_rounded, color: AppColors.accentTeal, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Điều Hòa Hệ Thần Kinh 4-4-4-4',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '2 phút thở vuông để hạ nhịp tim và giảm căng thẳng cơ thể.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BoxBreathingScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded, color: AppColors.accentTeal, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Bắt đầu thở 2 phút',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMindfulAnchorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded, color: Colors.white30, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '“Bạn không cần phải kiểm soát hay xua đuổi những suy nghĩ lo âu. Chỉ cần nhận diện chúng như những đám mây trôi qua bầu trời tâm trí.”',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '— MindTrack Clinical Grounding Anchor',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
