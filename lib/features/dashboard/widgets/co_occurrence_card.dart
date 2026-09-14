import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/frequency_analytics_model.dart';
import '../data/clinical_data_repository.dart';

class CoOccurrenceCard extends StatelessWidget {
  final TimeframeOption timeframe;

  const CoOccurrenceCard({
    super.key,
    required this.timeframe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  color: AppColors.accentTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thống kê Đồng Xuất Hiện (Co-occurrence)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mối liên hệ lặp lại giữa cảm xúc, bối cảnh & thể chất',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Clinical Ethics Disclaimer Banner (Crucial Requirement!)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4A261).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFF4A261).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFF4A261),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LƯU Ý CHUYÊN MÔN: KHÔNG SUY DIỄN NHÂN QUẢ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF4A261),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Số liệu phản ánh các sự kiện có xu hướng xuất hiện cùng lúc trong chu kỳ theo dõi của bạn, không khẳng định yếu tố này là nguyên nhân trực tiếp gây ra yếu tố kia. Hãy mang dữ liệu này đối thoại cùng nhà tham vấn.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Co-occurrence Cards List from Supabase
          FutureBuilder<List<CoOccurrenceInsight>>(
            future: ClinicalDataRepository.getDynamicCoOccurrenceInsights(timeframe),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentTeal),
                    ),
                  ),
                );
              }

              final insights = snapshot.data ?? [];
              if (insights.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      'Cần tối thiểu 3 ngày ghi nhận cảm xúc và cờ đỏ để hệ thống phân tích các quy luật đồng xuất hiện lâm sàng của bạn.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: insights.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final insight = insights[index];
                  return _buildInsightCard(insight);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(CoOccurrenceInsight insight) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: insight.accentColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: insight.accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  insight.icon,
                  size: 16,
                  color: insight.accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: insight.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: insight.accentColor.withValues(alpha: 0.45),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${insight.percentage}% đồng xuất hiện',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: insight.accentColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Two factors pill connector
          Row(
            children: [
              _buildFactorTag(insight.factorA),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Icon(
                  Icons.sync_alt_rounded,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
              _buildFactorTag(insight.factorB),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            insight.observation,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
