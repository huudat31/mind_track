import 'package:flutter/material.dart';
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
    setState(() {
      _answers[_currentIndex] = value;
      if (_currentIndex < Dass21Data.questions.length - 1) {
        _currentIndex++;
      } else {
        _navigateToResult();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final question = Dass21Data.questions[_currentIndex];
    final progress = (_currentIndex + 1) / Dass21Data.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá DASS-21'),
        actions: [
          IconButton(
            onPressed: () => HotlineDialog.show(context),
            icon: const Icon(Icons.support_agent_rounded, color: AppColors.accentCoral),
            tooltip: 'Đường dây nóng hỗ trợ',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Câu ${_currentIndex + 1}/${Dass21Data.questions.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 32),

              // Question card
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Trong 7 ngày qua:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      question.text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),

                    // 4 Options
                    ...List.generate(4, (index) {
                      final isSelected = _answers[_currentIndex] == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => _selectOption(index),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? AppColors.primary : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                                    ),
                                  ),
                                  child: Text(
                                    '$index',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    Dass21Data.optionLabels[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
