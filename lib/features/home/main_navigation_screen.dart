import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/hotline_dialog.dart';
import '../assessment/screens/assessment_screen.dart';
import '../logging/screens/state_of_mind_screen.dart';
import '../dashboard/screens/frequency_dashboard_screen.dart';
import '../report/screens/pdf_report_screen.dart';
import '../breathing/screens/box_breathing_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _screens => [
    _HomeDashboardTab(onSelectTab: _switchTab),
    const AssessmentScreen(),
    StateOfMindScreen(
      onBack: () => _switchTab(0),
      onClose: () => _switchTab(0),
    ),
    const FrequencyDashboardScreen(),
    const PdfReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Floating Glass Bottom Navigation Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: _buildFloatingGlassNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingGlassNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141F25).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Tổng quan'),
          _buildNavItem(1, Icons.quiz_outlined, Icons.quiz_rounded, 'DASS-21'),
          _buildNavItem(2, Icons.spa_outlined, Icons.spa_rounded, 'Cảm xúc', isSpecial: true),
          _buildNavItem(3, Icons.insert_chart_outlined_rounded, Icons.insert_chart_rounded, 'Tần suất'),
          _buildNavItem(4, Icons.picture_as_pdf_outlined, Icons.picture_as_pdf_rounded, 'Báo cáo'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, {bool isSpecial = false}) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _switchTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isSpecial
                  ? const Color(0xFFEB6834).withValues(alpha: 0.28)
                  : AppColors.primary.withValues(alpha: 0.35))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: isSelected
              ? Border.all(
                  color: isSpecial
                      ? const Color(0xFFEB6834).withValues(alpha: 0.6)
                      : AppColors.primaryLight.withValues(alpha: 0.5),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected
                  ? (isSpecial ? const Color(0xFFFF8A50) : Colors.white)
                  : Colors.white54,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSpecial ? const Color(0xFFFF8A50) : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeDashboardTab extends StatelessWidget {
  final Function(int)? onSelectTab;

  const _HomeDashboardTab({this.onSelectTab});

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
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          children: [
            // Top App Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào bạn 👋',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'MindTrack',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => HotlineDialog.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentCoral.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.35)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.support_agent_rounded, color: AppColors.accentCoral, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Hotline',
                          style: TextStyle(
                            color: AppColors.accentCoral,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 1. Hero Card: State of Mind Mood Check-in
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StateOfMindScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF263F3C),
                      const Color(0xFF1E3230),
                      const Color(0xFF172424),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEB6834).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.spa_rounded, color: Color(0xFFFF8A50), size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'CẢM XÚC HÔM NAY',
                                  style: TextStyle(color: Color(0xFFFF8A50), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Bạn đang cảm thấy thế nào ngay lúc này?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ghi nhận bằng hoạt họa bông hoa biến đổi cảm xúc',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Bắt đầu check-in',
                                style: TextStyle(
                                  color: AppColors.primaryLight,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, color: AppColors.primaryLight, size: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Mini glowing bloom icon
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFEB6834).withValues(alpha: 0.4),
                            AppColors.primary.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.spa_rounded,
                          size: 38,
                          color: Color(0xFFFF9E73),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Pre-Therapy Bridge Status Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.medical_services_outlined, color: AppColors.accentTeal, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Cầu Nối Trước Trị Liệu',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentTeal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '2-4 tuần',
                          style: TextStyle(color: AppColors.accentTeal, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tự theo dõi cảm xúc và triệu chứng cơ thể để buổi gặp chuyên gia đầu tiên rõ ràng và trọng tâm hơn.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.28,
                            backgroundColor: Color(0xFF223038),
                            valueColor: AlwaysStoppedAnimation(AppColors.accentTeal),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '8 / 28 ngày',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Bento Grid of Key Modules
            const Text(
              'Hoạt Động Chữa Lành',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                // DASS-21 Card
                Expanded(
                  child: _buildBentoCard(
                    context,
                    title: 'Thang đo DASS-21',
                    subtitle: 'Đo Trầm cảm, Lo âu, Căng thẳng',
                    badge: '14 ngày/lần',
                    icon: Icons.quiz_rounded,
                    accentColor: AppColors.primaryLight,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AssessmentScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Breathing Card
                Expanded(
                  child: _buildBentoCard(
                    context,
                    title: 'Thở Vuông 4-4',
                    subtitle: 'Cắt cơn lo âu cấp tức thời',
                    badge: 'Thư giãn',
                    icon: Icons.air_rounded,
                    accentColor: AppColors.accentTeal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BoxBreathingScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                // Frequency Dashboard Card
                Expanded(
                  child: _buildBentoCard(
                    context,
                    title: 'Tần Suất Cờ Đỏ',
                    subtitle: 'Thống kê dấu hiệu thực thể',
                    badge: 'Dữ liệu',
                    icon: Icons.insert_chart_rounded,
                    accentColor: AppColors.accentAmber,
                    onTap: () {
                      onSelectTab?.call(3);
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // PDF Report Card
                Expanded(
                  child: _buildBentoCard(
                    context,
                    title: 'Báo Cáo PDF',
                    subtitle: 'Xuất bản tóm tắt lâm sàng',
                    badge: 'Chuyên gia',
                    icon: Icons.picture_as_pdf_rounded,
                    accentColor: AppColors.accentLavender,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PdfReportScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Mindful Quote of the Day
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote_rounded, color: Colors.white30, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '“Cảm xúc là những vị khách ghé thăm tâm trí bạn. Hãy chào đón, quan sát và lắng nghe mà không phán xét.”',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '— Chánh niệm ứng dụng',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
