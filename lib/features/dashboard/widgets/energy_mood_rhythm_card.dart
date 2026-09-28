import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/frequency_analytics_model.dart';
import '../data/clinical_data_repository.dart';

class EnergyMoodRhythmCard extends StatelessWidget {
  final TimeframeOption timeframe;

  const EnergyMoodRhythmCard({
    super.key,
    required this.timeframe,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DailyMoodEnergyPoint>>(
      future: ClinicalDataRepository.getDynamicDailyMoodEnergyTimeline(timeframe),
      builder: (context, snapshot) {
        final timeline = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        final hasData = timeline.isNotEmpty;
        final avgMood = hasData
            ? timeline.map((e) => e.moodScore).reduce((a, b) => a + b) / timeline.length
            : 0.0;
        final avgEnergy = hasData
            ? timeline.map((e) => e.energyLevel).reduce((a, b) => a + b) / timeline.length
            : 0.0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
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
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nhịp điệu Năng lượng & Cảm xúc',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Xu hướng biến thiên năng lượng và trạng thái tâm lý',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  ),
                )
              else if (!hasData)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      'Chưa có dữ liệu cảm xúc & năng lượng trong ${timeframe.label}.\nHãy ghi nhận cảm xúc hôm nay để bắt đầu hình thành nhịp điệu.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                )
              else ...[
                // Averages Summary Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricBadge(
                        label: 'Năng lượng TB',
                        value: '${avgEnergy.toStringAsFixed(1)} / 5.0',
                        icon: Icons.battery_charging_full_rounded,
                        color: const Color(0xFFF4A261),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricBadge(
                        label: 'Tâm trạng TB',
                        value: '${avgMood.toStringAsFixed(1)} / 5.0',
                        icon: Icons.mood_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Daily rhythm spark horizontal scroll
                Text(
                  'Chi tiết từng ngày (${timeline.length} ngày ghi nhận)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    itemCount: timeline.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = timeline[timeline.length - 1 - index];
                      return _buildDayColumn(item);
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricBadge({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(DailyMoodEnergyPoint item) {
    final moodColor = switch (item.moodScore) {
      1 => const Color(0xFFE07A5F),
      2 => const Color(0xFFF4A261),
      3 => const Color(0xFF818AA3),
      4 => const Color(0xFF7E9F9B),
      5 => AppColors.primary,
      _ => const Color(0xFF818AA3),
    };

    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.energyLevel <= 2
              ? const Color(0xFFE07A5F).withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Day label
          Text(
            item.dayLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),

          // Mood Circle
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: moodColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: moodColor, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              '${item.moodScore}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: moodColor,
              ),
            ),
          ),

          // Energy Level bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final isFilled = i < item.energyLevel;
              return Container(
                width: 4,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isFilled
                      ? const Color(0xFFF4A261)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
