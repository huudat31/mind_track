import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/hotline_dialog.dart';
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

  bool get _hasSevereScore {
    final depSev = Dass21Data.getSeverity(DassCategory.depression, depressionScore);
    final anxSev = Dass21Data.getSeverity(DassCategory.anxiety, anxietyScore);
    final strSev = Dass21Data.getSeverity(DassCategory.stress, stressScore);
    return depSev == 'Nặng' || depSev == 'Rất nặng' ||
           anxSev == 'Nặng' || anxSev == 'Rất nặng' ||
           strSev == 'Nặng' || strSev == 'Rất nặng';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết Quả Tự Đánh Giá'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => HotlineDialog.show(context),
            icon: const Icon(Icons.support_agent_rounded, color: AppColors.accentCoral),
            tooltip: 'Đường dây nóng hỗ trợ',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header summary
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
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
                        child: const Icon(Icons.assignment_turned_in_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Điểm mốc (Baseline) DASS-21',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Kết quả này phản ánh mức độ cảm nhận của bạn trong 7 ngày qua và đã được lưu lại để đưa vào Bản báo cáo trước trị liệu.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Severe warning if needed (delicate, non-alarming)
            if (_hasSevereScore) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentCoral.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.accentCoral, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gợi ý chia sẻ sớm với chuyên gia',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.accentCoral),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Một số chỉ số đang ở mức cần lưu tâm. Bạn có thể cân nhắc đặt lịch với chuyên viên tâm lý hoặc liên hệ đường dây hỗ trợ.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 3 Indicator Cards
            _buildMetricCard(
              category: DassCategory.depression,
              title: 'Trầm cảm (Depression)',
              subtitle: 'Mức độ sụt giảm năng lượng, hứng thú và cảm giác tiêu cực về tương lai',
              score: depressionScore,
              accentColor: AppColors.accentLavender,
            ),
            const SizedBox(height: 14),

            _buildMetricCard(
              category: DassCategory.anxiety,
              title: 'Lo âu (Anxiety)',
              subtitle: 'Phản ứng cơ thể (khó thở, run rẩy) và nỗi sợ hãi mơ hồ',
              score: anxietyScore,
              accentColor: AppColors.accentAmber,
            ),
            const SizedBox(height: 14),

            _buildMetricCard(
              category: DassCategory.stress,
              title: 'Căng thẳng (Stress)',
              subtitle: 'Mức độ bồn chồn, khó thả lỏng và phản ứng nhạy cảm trước áp lực',
              score: stressScore,
              accentColor: AppColors.accentCoral,
            ),
            const SizedBox(height: 24),

            // Clinical disclaimer box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.gavel_rounded, size: 16, color: AppColors.textMuted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.clinicalDisclaimer,
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hoàn thành & Về Trang Chủ'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => HotlineDialog.show(context),
              icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
              label: const Text('Xem danh bạ Hotline khẩn cấp'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentCoral,
                side: BorderSide(color: AppColors.accentCoral.withValues(alpha: 0.3)),
              ),
            ),
          ],
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  severity,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
          const SizedBox(height: 14),

          // Progress bar & Score
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
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
