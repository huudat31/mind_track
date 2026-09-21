import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../assessment/screens/assessment_screen.dart';
import '../logging/screens/state_of_mind_screen.dart';
import '../dashboard/screens/frequency_dashboard_screen.dart';
import '../report/screens/pdf_report_screen.dart';
import 'widgets/today_companion_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  static final GlobalKey<MainNavigationScreenState> navKey =
      GlobalKey<MainNavigationScreenState>();

  static final ValueNotifier<int> selectedTabNotifier = ValueNotifier<int>(0);

  static void switchTab(int index) {
    debugPrint('🔄 MainNavigationScreen.switchTab($index) called');
    selectedTabNotifier.value = index;
    navKey.currentState?._switchTab(index);
  }

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    if (MainNavigationScreen.selectedTabNotifier.value != 0) {
      _currentIndex = MainNavigationScreen.selectedTabNotifier.value;
    } else {
      _currentIndex = widget.initialIndex;
      MainNavigationScreen.selectedTabNotifier.value = widget.initialIndex;
    }

    MainNavigationScreen.selectedTabNotifier.addListener(_onSelectedTabChanged);
  }

  @override
  void didUpdateWidget(covariant MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex &&
        _currentIndex != widget.initialIndex) {
      _switchTab(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    MainNavigationScreen.selectedTabNotifier.removeListener(
      _onSelectedTabChanged,
    );
    super.dispose();
  }

  void _onSelectedTabChanged() {
    final target = MainNavigationScreen.selectedTabNotifier.value;
    if (mounted && _currentIndex != target) {
      debugPrint('📲 Nhận tín hiệu đổi tab sang index: $target');
      setState(() {
        _currentIndex = target;
      });
    }
  }

  void _switchTab(int index) {
    if (mounted) {
      MainNavigationScreen.selectedTabNotifier.value = index;
      setState(() {
        _currentIndex = index;
      });
    }
  }

  List<Widget> get _screens => [
    TodayCompanionTab(onSelectTab: _switchTab),
    const AssessmentScreen(),
    StateOfMindScreen(
      onBack: () => _switchTab(0),
      onClose: () => _switchTab(0),
    ),
    FrequencyDashboardScreen(onNavigateToReport: () => _switchTab(4)),
    const PdfReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isHome = _currentIndex == 0;

    return Scaffold(
      backgroundColor: isHome ? AppColors.background : AppColors.darkBg,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),

          // Floating Glass Bottom Navigation Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: _buildFloatingGlassNav(isHome: isHome),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingGlassNav({required bool isHome}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isHome
            ? Colors.white.withValues(alpha: 0.96)
            : const Color(0xFF141F25).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isHome
              ? AppColors.border
              : Colors.white.withValues(alpha: 0.14),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isHome ? 0.08 : 0.55),
            blurRadius: isHome ? 20 : 28,
            offset: Offset(0, isHome ? 6 : 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            0,
            Icons.today_outlined,
            Icons.today_rounded,
            'Trang chủ',
            isHome: isHome,
          ),
          _buildNavItem(
            1,
            Icons.quiz_outlined,
            Icons.quiz_rounded,
            'DASS-21',
            isHome: isHome,
          ),
          _buildNavItem(
            2,
            Icons.spa_outlined,
            Icons.spa_rounded,
            'Cảm xúc',
            isSpecial: true,
            isHome: isHome,
          ),
          _buildNavItem(
            3,
            Icons.insert_chart_outlined_rounded,
            Icons.insert_chart_rounded,
            'Tần suất',
            isHome: isHome,
          ),
          _buildNavItem(
            4,
            Icons.picture_as_pdf_outlined,
            Icons.picture_as_pdf_rounded,
            'Báo cáo',
            isHome: isHome,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    bool isSpecial = false,
    required bool isHome,
  }) {
    final isSelected = _currentIndex == index;

    Color activeBg;
    Color activeTextColor;
    Color inactiveIconColor;

    if (isHome) {
      activeBg = isSpecial
          ? const Color(0xFFEB6834)
          : AppColors.primary;
      activeTextColor = Colors.white;
      inactiveIconColor = AppColors.textSecondary;
    } else {
      activeBg = isSpecial
          ? const Color(0xFFEB6834).withValues(alpha: 0.28)
          : AppColors.primary.withValues(alpha: 0.35);
      activeTextColor = isSpecial ? const Color(0xFFFF8A50) : Colors.white;
      inactiveIconColor = Colors.white54;
    }

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
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: isSelected
              ? Border.all(
                  color: isHome
                      ? Colors.transparent
                      : (isSpecial
                          ? const Color(0xFFEB6834).withValues(alpha: 0.6)
                          : AppColors.primaryLight.withValues(alpha: 0.5)),
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
              color: isSelected ? activeTextColor : inactiveIconColor,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: activeTextColor,
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
