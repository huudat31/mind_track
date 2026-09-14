import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../logging/models/daily_log_model.dart';
import '../models/frequency_analytics_model.dart';
import '../data/clinical_data_repository.dart';

class SymptomFrequencyTracker extends StatefulWidget {
  final TimeframeOption timeframe;

  const SymptomFrequencyTracker({
    super.key,
    required this.timeframe,
  });

  @override
  State<SymptomFrequencyTracker> createState() => _SymptomFrequencyTrackerState();
}

class _SymptomFrequencyTrackerState extends State<SymptomFrequencyTracker> {
  String _selectedCategory = 'Tất cả';

  final List<String> _categories = [
    'Tất cả',
    ...ClinicalFlagsCatalog.categories,
  ];

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
                  color: const Color(0xFFF4A261).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Color(0xFFF4A261),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tần suất cờ đỏ lâm sàng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Xếp hạng triệu chứng theo tỷ lệ ngày xuất hiện',
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

          // Category Chips Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryLight.withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Flag Stats List from Supabase
          FutureBuilder<List<FlagFrequencyStat>>(
            future: ClinicalDataRepository.getDynamicFlagFrequencies(
              widget.timeframe,
              categoryFilter: _selectedCategory,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight),
                    ),
                  ),
                );
              }

              final flagStats = snapshot.data ?? [];
              if (flagStats.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      'Chưa có cờ đỏ nào được ghi nhận trong ${_selectedCategory == 'Tất cả' ? 'thời gian này' : 'danh mục "$_selectedCategory"'}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: flagStats.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = flagStats[index];
                  return _buildFlagRow(item, index + 1);
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // Clinical Note Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Triệu chứng xuất hiện >50% số ngày được khuyến nghị ưu tiên trao đổi ở phiên đầu.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.55),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagRow(FlagFrequencyStat item, int rank) {
    final pct = item.percentage.round();

    // Color gradient according to clinical frequency
    final Color barColor;
    if (pct >= 65) {
      barColor = const Color(0xFFE07A5F); // High severity coral
    } else if (pct >= 40) {
      barColor = const Color(0xFFF4A261); // Moderate amber
    } else {
      barColor = const Color(0xFF7E9F9B); // Mild sage
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Rank badge
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? barColor.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: rank <= 3
                      ? barColor.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: rank <= 3 ? barColor : Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Icon
            Icon(
              item.flag.icon,
              size: 18,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),

            // Name
            Expanded(
              child: Text(
                item.flag.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            // Category tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.flag.category,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Count & Percentage
            Text(
              '${item.count}/${item.totalDays} ngày',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: barColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Progress bar
        Stack(
          children: [
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: item.fraction.clamp(0.0, 1.0),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      barColor.withValues(alpha: 0.7),
                      barColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
