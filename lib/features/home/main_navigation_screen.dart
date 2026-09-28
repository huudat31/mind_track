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
    AssessmentScreen(onBack: () => _switchTab(0)),
    StateOfMindScreen(
      onBack: () => _switchTab(0),
      onClose: () => _switchTab(0),
    ),
    FrequencyDashboardScreen(onNavigateToReport: () => _switchTab(4)),
    const PdfReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),

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
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
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
          ),
          _buildNavItem(
            1,
            Icons.quiz_outlined,
            Icons.quiz_rounded,
            'DASS-21',
          ),
          _buildNavItem(
            2,
            Icons.spa_outlined,
            Icons.spa_rounded,
            'Cảm xúc',
            isSpecial: true,
          ),
          _buildNavItem(
            3,
            Icons.insert_chart_outlined_rounded,
            Icons.insert_chart_rounded,
            'Tần suất',
          ),
          _buildNavItem(
            4,
            Icons.picture_as_pdf_outlined,
            Icons.picture_as_pdf_rounded,
            'Báo cáo',
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
  }) {
    final isSelected = _currentIndex == index;

    final Color activeBg = isSpecial
        ? const Color(0xFFEB6834)
        : AppColors.primary;
    const Color activeIconColor = Colors.white;
    const Color inactiveIconColor = AppColors.textSecondary;

    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      child: Tooltip(
        message: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _switchTab(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 48,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: activeBg.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected ? activeIconColor : inactiveIconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
