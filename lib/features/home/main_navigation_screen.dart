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

  final List<Widget> _screens = const [
    _HomeDashboardTab(),
    AssessmentScreen(),
    StateOfMindScreen(),
    FrequencyDashboardScreen(),
    PdfReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz_rounded, color: AppColors.primary),
            label: 'DASS-21',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_calendar_outlined),
            selectedIcon: Icon(Icons.edit_calendar_rounded, color: AppColors.primary),
            label: 'Ghi nhận',
          ),
          NavigationDestination(
            icon: Icon(Icons.insert_chart_outlined),
            selectedIcon: Icon(Icons.insert_chart_rounded, color: AppColors.primary),
            label: 'Tần suất',
          ),
          NavigationDestination(
            icon: Icon(Icons.picture_as_pdf_outlined),
            selectedIcon: Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
            label: 'Báo cáo',
          ),
        ],
      ),
    );
  }
}

class _HomeDashboardTab extends StatelessWidget {
  const _HomeDashboardTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MindTrack', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text(
              'Cầu nối trước trị liệu',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => HotlineDialog.show(context),
            icon: const Icon(Icons.support_agent_rounded, color: AppColors.accentCoral),
            tooltip: 'Đường dây nóng hỗ trợ',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner Welcome / Goal
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Không gian an toàn & Tự ghi nhận',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Chuẩn bị sẵn sàng cho buổi gặp chuyên gia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Dữ liệu 2-4 tuần tự ghi nhận sẽ giúp buổi trao đổi đầu tiên rõ ràng và trọng tâm hơn.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Các hoạt động chính',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            context,
            icon: Icons.spa_rounded,
            color: const Color(0xFFEB6834),
            title: 'Ghi nhận cảm xúc ngay lúc này',
            subtitle: 'Trạng thái tâm trí (State of Mind) với hoạt họa bông hoa biến đổi cảm xúc',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StateOfMindScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            context,
            icon: Icons.quiz_rounded,
            color: AppColors.primary,
            title: 'Làm bài kiểm tra DASS-21',
            subtitle: 'Đo lường mức độ Trầm cảm, Lo âu, Căng thẳng (định kỳ 14 ngày)',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AssessmentScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            context,
            icon: Icons.air_rounded,
            color: AppColors.accentTeal,
            title: 'Thở vuông (Box Breathing 4-4-4-4)',
            subtitle: 'Sơ cứu tâm lý, cắt cơn căng thẳng và điều hòa nhịp thở tức thời',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BoxBreathingScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            context,
            icon: Icons.picture_as_pdf_rounded,
            color: AppColors.accentLavender,
            title: 'Xuất Báo Cáo PDF Trước Trị Liệu',
            subtitle: 'Tự chọn nội dung nhật ký & in bảng tổng kết triệu chứng cho chuyên gia',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PdfReportScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
