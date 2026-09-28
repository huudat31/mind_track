import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/hotline_dialog.dart';
import '../../home/main_navigation_screen.dart';
import '../models/dass21_model.dart';

class AssessmentResultScreen extends StatelessWidget {
  final int depressionScore;
  final int anxietyScore;
  final int stressScore;
  final Map<int, int> answers;

  const AssessmentResultScreen({
    super.key,
    required this.depressionScore,
    required this.anxietyScore,
    required this.stressScore,
    required this.answers,
  });

  void _returnHome(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
    MainNavigationScreen.switchTab(0);
  }

  bool get _hasSevereScore {
    final depSev = Dass21Data.getSeverity(
      DassCategory.depression,
      depressionScore,
    );
    final anxSev = Dass21Data.getSeverity(DassCategory.anxiety, anxietyScore);
    final strSev = Dass21Data.getSeverity(DassCategory.stress, stressScore);
    return depSev == 'Nặng' ||
        depSev == 'Rất nặng' ||
        anxSev == 'Nặng' ||
        anxSev == 'Rất nặng' ||
        strSev == 'Nặng' ||
        strSev == 'Rất nặng';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Top Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kết Quả Tự Đánh Giá',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => HotlineDialog.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentCoral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accentCoral.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.support_agent_rounded,
                            color: AppColors.accentCoral,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Hotline',
                            style: TextStyle(
                              color: AppColors.accentCoral,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.assignment_turned_in_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Điểm mốc (Baseline) DASS-21',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Kết quả này phản ánh mức độ cảm nhận của bạn trong 7 ngày qua và đã được lưu trữ để đưa vào Bản báo cáo trước trị liệu.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Severe warning if needed
              if (_hasSevereScore) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentCoral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.accentCoral.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.accentCoral,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gợi ý trao đổi sớm với chuyên gia',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentCoral,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Một số chỉ số đang ở mức cần lưu tâm. Bạn có thể cân nhắc đặt lịch với chuyên viên tâm lý hoặc liên hệ đường dây hỗ trợ.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary.withValues(alpha: 0.9),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              _buildMetricCard(
                category: DassCategory.depression,
                title: 'Trầm cảm (Depression)',
                subtitle:
                    'Mức độ sụt giảm năng lượng, hứng thú và tiêu cực tương lai',
                score: depressionScore,
                accentColor: AppColors.accentLavender,
              ),
              const SizedBox(height: 12),

              _buildMetricCard(
                category: DassCategory.anxiety,
                title: 'Lo âu (Anxiety)',
                subtitle:
                    'Phản ứng cơ thể (khó thở, run rẩy) và nỗi sợ hãi mơ hồ',
                score: anxietyScore,
                accentColor: AppColors.accentAmber,
              ),
              const SizedBox(height: 12),

              _buildMetricCard(
                category: DassCategory.stress,
                title: 'Căng thẳng (Stress)',
                subtitle: 'Mức độ bồn chồn, khó thả lỏng và phản ứng nhạy cảm',
                score: stressScore,
                accentColor: AppColors.accentCoral,
              ),
              const SizedBox(height: 20),

              // Clinical disclaimer box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.gavel_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.clinicalDisclaimer,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _returnHome(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Hoàn thành & Về Trang Chủ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => HotlineDialog.show(context),
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                  label: const Text(
                    'Xem danh bạ Hotline hỗ trợ',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentCoral,
                    side: BorderSide(
                      color: AppColors.accentCoral.withValues(alpha: 0.35),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required DassCategory category,
    required String title,
    required String subtitle,
    required int score,
    required Color accentColor,
  }) {
    final severity = Dass21Data.getSeverity(category, score);
    final fraction = Dass21Data.getSeverityFraction(category, score);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  severity,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: fraction,
                    backgroundColor: AppColors.surfaceMuted,
                    valueColor: AlwaysStoppedAnimation(accentColor),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '$score / 42 đ',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
