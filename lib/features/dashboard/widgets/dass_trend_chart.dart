import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../assessment/models/dass21_model.dart';
import '../models/frequency_analytics_model.dart';

class DassTrendChart extends StatefulWidget {
  final List<DassHistoryPoint> history;

  const DassTrendChart({
    super.key,
    required this.history,
  });

  @override
  State<DassTrendChart> createState() => _DassTrendChartState();
}

class _DassTrendChartState extends State<DassTrendChart> {
  // null means show all 3, otherwise show specific category
  DassCategory? _selectedCategory;

  static const Color depressionColor = Color(0xFFB388FF); // Lavender purple
  static const Color anxietyColor = Color(0xFFFF9E80);    // Warm peach/coral
  static const Color stressColor = Color(0xFF4DB6AC);     // Sage teal

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.darkCard.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.quiz_outlined, color: AppColors.primaryLight, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tiến Trình Đánh Giá DASS-21',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.history_edu_rounded, color: AppColors.primaryLight, size: 32),
                  const SizedBox(height: 10),
                  const Text(
                    'Chưa có dữ liệu DASS-21',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bạn chưa lưu bài đánh giá DASS-21 nào trên tài khoản này. Hãy làm bài test ở tab "DASS-21" để bắt đầu theo dõi biểu đồ tiến triển lâm sàng.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
          // Header & Indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_down_rounded,
                  color: AppColors.primaryLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tiến trình DASS-21 qua thời gian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'So sánh điểm số giữa các mốc theo dõi',
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

          // Subscale Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Tất cả (3 thang đo)',
                  isSelected: _selectedCategory == null,
                  color: AppColors.primaryLight,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Trầm cảm',
                  isSelected: _selectedCategory == DassCategory.depression,
                  color: depressionColor,
                  onTap: () => setState(() => _selectedCategory = DassCategory.depression),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Lo âu',
                  isSelected: _selectedCategory == DassCategory.anxiety,
                  color: anxietyColor,
                  onTap: () => setState(() => _selectedCategory = DassCategory.anxiety),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Căng thẳng',
                  isSelected: _selectedCategory == DassCategory.stress,
                  color: stressColor,
                  onTap: () => setState(() => _selectedCategory = DassCategory.stress),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Chart Container
          SizedBox(
            height: 220,
            child: LineChart(
              _buildChartData(),
            ),
          ),

          const SizedBox(height: 16),

          // Clinical Cutoff Legend & Baseline Improvement badge
          _buildClinicalInsightBar(),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData() {
    final history = widget.history;
    final maxX = history.length > 1 ? (history.length - 1).toDouble() : 1.0;

    List<LineChartBarData> lineBars = [];

    if (_selectedCategory == null || _selectedCategory == DassCategory.depression) {
      lineBars.add(_createLineBarData(
        points: history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.depression.toDouble())).toList(),
        color: depressionColor,
      ));
    }

    if (_selectedCategory == null || _selectedCategory == DassCategory.anxiety) {
      lineBars.add(_createLineBarData(
        points: history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.anxiety.toDouble())).toList(),
        color: anxietyColor,
      ));
    }

    if (_selectedCategory == null || _selectedCategory == DassCategory.stress) {
      lineBars.add(_createLineBarData(
        points: history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.stress.toDouble())).toList(),
        color: stressColor,
      ));
    }

    return LineChartData(
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: 35, // DASS-21 subscale max score 42, typically 0-35
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 7,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.white.withValues(alpha: 0.06),
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 7,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 26,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < history.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    history[index].label.replaceAll(' (Bắt đầu)', '').replaceAll(' (Hiện tại)', ''),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          // Clinical Reference Line: Ngưỡng Vừa Phải / Nặng (~21 điểm)
          HorizontalLine(
            y: 20,
            color: const Color(0xFFE07A5F).withValues(alpha: 0.3),
            strokeWidth: 1,
            dashArray: [6, 4],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 6, bottom: 2),
              style: TextStyle(
                color: const Color(0xFFE07A5F).withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              labelResolver: (line) => 'Ngưỡng Nặng',
            ),
          ),
          // Clinical Reference Line: Ngưỡng Bình Thường (~9 điểm)
          HorizontalLine(
            y: 9,
            color: const Color(0xFF7E9F9B).withValues(alpha: 0.3),
            strokeWidth: 1,
            dashArray: [6, 4],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 6, bottom: 2),
              style: TextStyle(
                color: const Color(0xFF7E9F9B).withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              labelResolver: (line) => 'Ngưỡng Bình thường',
            ),
          ),
        ],
      ),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF142229).withValues(alpha: 0.95),
          tooltipBorder: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              final point = history[index];
              final score = spot.y.toInt();

              String subscaleName = '';
              Color textColor = Colors.white;

              if (spot.barIndex == 0) {
                if (_selectedCategory != null) {
                  subscaleName = _selectedCategory == DassCategory.depression
                      ? 'Trầm cảm'
                      : (_selectedCategory == DassCategory.anxiety ? 'Lo âu' : 'Căng thẳng');
                  textColor = spot.bar.color ?? Colors.white;
                } else {
                  subscaleName = 'Trầm cảm';
                  textColor = depressionColor;
                }
              } else if (spot.barIndex == 1) {
                subscaleName = 'Lo âu';
                textColor = anxietyColor;
              } else {
                subscaleName = 'Căng thẳng';
                textColor = stressColor;
              }

              return LineTooltipItem(
                '$subscaleName: $score đ\n(${point.label})',
                TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: lineBars,
    );
  }

  LineChartBarData _createLineBarData({
    required List<FlSpot> points,
    required Color color,
  }) {
    return LineChartBarData(
      spots: points,
      isCurved: true,
      curveSmoothness: 0.35,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4.5,
            color: color,
            strokeWidth: 2,
            strokeColor: AppColors.darkCard,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalInsightBar() {
    if (widget.history.length == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primaryLight, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Đã ghi nhận mốc đánh giá ban đầu (T0). Hãy làm thêm bài đánh giá sau 7 ngày để hệ thống đo lường mức độ tiến triển.',
                style: TextStyle(fontSize: 12, color: Colors.white, height: 1.3),
              ),
            ),
          ],
        ),
      );
    }

    final first = widget.history.first;
    final latest = widget.history.last;

    // Calculate score shifts
    final stressChange = latest.stress - first.stress;
    final anxietyChange = latest.anxiety - first.anxiety;
    final depressionChange = latest.depression - first.depression;

    final isImproving = (stressChange <= 0 && anxietyChange <= 0 && depressionChange <= 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isImproving
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isImproving ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
            color: isImproving ? AppColors.primaryLight : const Color(0xFFF4A261),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isImproving
                  ? 'Xu hướng tích cực: Căng thẳng giảm ${stressChange.abs()}đ, Lo âu giảm ${anxietyChange.abs()}đ so với mốc ban đầu.'
                  : 'Điểm số có sự dao động. Bạn nên ghi lại bối cảnh cụ thể để đối chiếu.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
