import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/hotline_dialog.dart';
import '../models/dass21_model.dart';
import 'assessment_result_screen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

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

  void _navigateToResult() {
    int dep = 0, anx = 0, str = 0;
    for (int i = 0; i < Dass21Data.questions.length; i++) {
      final score = _answers[i] ?? 0;
      final q = Dass21Data.questions[i];
      if (q.category == DassCategory.depression) dep += score;
      if (q.category == DassCategory.anxiety) anx += score;
      if (q.category == DassCategory.stress) str += score;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentResultScreen(
          depressionScore: dep * 2,
          anxietyScore: anx * 2,
          stressScore: str * 2,
          answers: Map.from(_answers),
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

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else if (_currentIndex > 0) {
                          _previousQuestion();
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    Column(
                      children: [
                        const Text(
                          'Đánh giá DASS-21',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Câu ${_currentIndex + 1} / ${Dass21Data.questions.length}',
                          style: const TextStyle(
                            color: AppColors.primaryLight,
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
                          color: AppColors.accentCoral.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.35)),
                        ),
                        child: const Icon(Icons.support_agent_rounded, color: AppColors.accentCoral, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Sleek glowing progress indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến trình đánh giá',
                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryLight),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 24),

                // Question Plate Card (Dark Frosted Glass)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: catColor.withValues(alpha: 0.4)),
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
                          Text(
                            'Trong 7 ngày qua',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.4),
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
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            height: 1.45,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.35)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryLight
                                : Colors.white.withValues(alpha: 0.12),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
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
                                    ? AppColors.primaryLight
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                  : Text(
                                      '$index',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withValues(alpha: 0.6),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                Dass21Data.optionLabels[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),

                // Back to previous question link
                if (_currentIndex > 0)
                  Center(
                    child: TextButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back_rounded, size: 14, color: Colors.white54),
                      label: const Text(
                        'Quay lại câu trước',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
