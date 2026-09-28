import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/hotline_dialog.dart';
import '../../home/main_navigation_screen.dart';
import '../models/dass21_model.dart';
import '../../../core/services/supabase_clinical_service.dart';
import 'assessment_result_screen.dart';

class AssessmentScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const AssessmentScreen({super.key, this.onBack});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _currentIndex = 0;
  final Map<int, int> _answers = {};

  void _selectOption(int value) {
    HapticFeedback.selectionClick();
    setState(() {
      _answers[_currentIndex] = value;
    });

    // Small delay to let the user see the selected state before moving
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      if (_currentIndex < Dass21Data.questions.length - 1) {
        setState(() {
          _currentIndex++;
        });
      } else {
        _navigateToResult();
      }
    });
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _handleBack() {
    if (_currentIndex > 0) {
      _previousQuestion();
    } else {
      _exitAssessment();
    }
  }

  void _exitAssessment() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = 0;
      _answers.clear();
    });
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      MainNavigationScreen.switchTab(0);
    }
  }

  Future<void> _confirmExit() async {
    if (_answers.isEmpty && _currentIndex == 0) {
      _exitAssessment();
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Dừng làm bài đánh giá?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Tiến trình làm bài hiện tại sẽ không được lưu nếu bạn quay lại trang chủ.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Tiếp tục làm',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Thoát về trang chủ',
              style: TextStyle(color: AppColors.accentCoral, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      _exitAssessment();
    }
  }

  void _navigateToResult() {
    int dep = 0, anx = 0, str = 0;
    for (int i = 0; i < Dass21Data.questions.length; i++) {
      final score = _answers[i] ?? 0;
      final q = Dass21Data.questions[i];
      if (q.category == DassCategory.depression) dep += score;
      if (q.category == DassCategory.anxiety) anx += score;
      if (q.category == DassCategory.stress) str += score;
    }

    final answersCopy = Map<int, int>.from(_answers);
    final finalDep = dep * 2;
    final finalAnx = anx * 2;
    final finalStr = str * 2;

    // Lưu kết quả bài đánh giá lên Supabase
    SupabaseClinicalService.saveDass21(
      depressionScore: finalDep,
      anxietyScore: finalAnx,
      stressScore: finalStr,
      answers: answersCopy,
    ).then((success) {
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lưu ý: Chưa thể đồng bộ DASS-21 lên Supabase do chưa kích hoạt Anonymous Auth hoặc chưa đăng nhập.',
            ),
            backgroundColor: Color(0xFFE07A5F),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    setState(() {
      _currentIndex = 0;
      _answers.clear();
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentResultScreen(
          depressionScore: finalDep,
          anxietyScore: finalAnx,
          stressScore: finalStr,
          answers: answersCopy,
        ),
      ),
    );
  }

  String _getCategoryLabel(DassCategory category) {
    switch (category) {
      case DassCategory.depression:
        return 'Trầm cảm (Depression)';
      case DassCategory.anxiety:
        return 'Lo âu (Anxiety)';
      case DassCategory.stress:
        return 'Căng thẳng (Stress)';
    }
  }

  Color _getCategoryColor(DassCategory category) {
    switch (category) {
      case DassCategory.depression:
        return AppColors.accentLavender;
      case DassCategory.anxiety:
        return AppColors.accentAmber;
      case DassCategory.stress:
        return AppColors.accentCoral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = Dass21Data.questions[_currentIndex];
    final progress = (_currentIndex + 1) / Dass21Data.questions.length;
    final catColor = _getCategoryColor(question.category);
    final catLabel = _getCategoryLabel(question.category);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _handleBack,
                        onLongPress: _confirmExit,
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          const Text(
                            'Đánh giá DASS-21',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Câu ${_currentIndex + 1} / ${Dass21Data.questions.length}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => HotlineDialog.show(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.accentCoral.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accentCoral.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: AppColors.accentCoral,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Sleek glowing progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tiến trình đánh giá',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.surfaceMuted,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary,
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Scrollable Question & Options with bottom clearance for floating bar
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question Plate Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: catColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: catColor.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      catLabel,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: catColor,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Trong 7 ngày qua',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  question.text,
                                  key: ValueKey(question.id),
                                  style: const TextStyle(
                                    fontSize: 18.5,
                                    fontWeight: FontWeight.bold,
                                    height: 1.45,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4 Glass Options (0 to 3)
                        ...List.generate(4, (index) {
                          final isSelected = _answers[_currentIndex] == index;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _selectOption(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: isSelected ? 1.8 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? AppColors.primary.withValues(alpha: 0.15)
                                          : Colors.black.withValues(alpha: 0.03),
                                      blurRadius: isSelected ? 10 : 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.surfaceMuted,
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : Text(
                                              '$index',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        Dass21Data.optionLabels[index],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? AppColors.primaryDark
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        // Back to previous question link
                        if (_currentIndex > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 6),
                            child: Center(
                              child: TextButton.icon(
                                onPressed: _previousQuestion,
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                label: const Text(
                                  'Quay lại câu trước',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
