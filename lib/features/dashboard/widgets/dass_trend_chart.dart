import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../assessment/models/dass21_model.dart';
import '../models/frequency_analytics_model.dart';

class DassTrendChart extends StatefulWidget {
  final List<DassHistoryPoint> history;
  final TimeframeOption timeframe;

  const DassTrendChart({
    super.key,
    required this.history,
    this.timeframe = TimeframeOption.fourteenDays,
  });

  @override
  State<DassTrendChart> createState() => _DassTrendChartState();
}

class _DassTrendChartState extends State<DassTrendChart> {
  // null means show all 3, otherwise show specific category
  DassCategory? _selectedCategory;

  int get _stepDays {
    switch (widget.timeframe) {
      case TimeframeOption.sevenDays:
        return 1; // 7 ngày: cứ 1 ngày 1 điểm
      case TimeframeOption.fourteenDays:
        return 2; // 14 ngày: cách 2 ngày vẽ 1 điểm
      case TimeframeOption.twentyEightDays:
        return 4; // 28 ngày: cách 4 ngày hiển thị 1 lần
    }
  }

  int get _totalPoints {
    switch (widget.timeframe) {
      case TimeframeOption.sevenDays:
        return 7;
      case TimeframeOption.fourteenDays:
        return 8;
      case TimeframeOption.twentyEightDays:
        return 8;
    }
  }

  DateTime _getDateForIndex(int index) {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final daysAgo = (_totalPoints - 1 - index) * _stepDays;
    return todayMidnight.subtract(Duration(days: daysAgo));
  }

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

  List<FlSpot> _buildCategorySpots(int Function(DassHistoryPoint) getScore) {
    if (widget.history.isEmpty) return [];

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final sorted = List<DassHistoryPoint>.from(widget.history)
      ..sort((a, b) => a.date.compareTo(b.date));

    final maxX = (_totalPoints - 1).toDouble();
    final List<FlSpot> rawSpots = [];

    for (final p in sorted) {
      final pMidnight = DateTime(p.date.year, p.date.month, p.date.day);
      final daysAgo = todayMidnight.difference(pMidnight).inDays;
      final x = maxX - (daysAgo / _stepDays);
      final clampedX = x.clamp(0.0, maxX);
      rawSpots.add(FlSpot(clampedX, getScore(p).toDouble()));
    }

    if (rawSpots.isEmpty) {
      final latest = sorted.last;
      rawSpots.add(FlSpot(maxX, getScore(latest).toDouble()));
    }

    // Sắp xếp tăng dần theo X
    rawSpots.sort((a, b) => a.x.compareTo(b.x));

    // Loại bỏ các điểm trùng X để đảm bảo tính đơn điệu nghiêm ngặt cho fl_chart
    final List<FlSpot> uniqueSpots = [];
    for (final s in rawSpots) {
      if (uniqueSpots.isNotEmpty && s.x <= uniqueSpots.last.x) {
        uniqueSpots.removeLast();
      }
      uniqueSpots.add(s);
    }

    return uniqueSpots;
  }

  LineChartData _buildChartData() {
    final maxX = (_totalPoints - 1).toDouble();

    List<LineChartBarData> lineBars = [];

    if (_selectedCategory == null || _selectedCategory == DassCategory.depression) {
      lineBars.add(_createLineBarData(
        points: _buildCategorySpots((p) => p.depression),
        color: depressionColor,
      ));
    }

    if (_selectedCategory == null || _selectedCategory == DassCategory.anxiety) {
      lineBars.add(_createLineBarData(
        points: _buildCategorySpots((p) => p.anxiety),
        color: anxietyColor,
      ));
    }

    if (_selectedCategory == null || _selectedCategory == DassCategory.stress) {
      lineBars.add(_createLineBarData(
        points: _buildCategorySpots((p) => p.stress),
        color: stressColor,
      ));
    }

    return LineChartData(
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: 35, // Thang điểm DASS-21 tối đa 42, dải chuẩn 0-35
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
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final index = value.round();
              if (index < 0 || index >= _totalPoints) {
                return const SizedBox.shrink();
              }
              if ((value - index).abs() > 0.15) {
                return const SizedBox.shrink();
              }

              final isToday = (index == _totalPoints - 1);
              final date = _getDateForIndex(index);
              final label = isToday ? 'Hôm nay' : '${date.day}/${date.month}';

              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isToday
                        ? AppColors.primaryLight
                        : Colors.white.withValues(alpha: 0.65),
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          // Clinical Reference Line: Ngưỡng Vừa Phải / Nặng (~20 điểm)
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
              final score = spot.y.toInt();
              final index = spot.x.round().clamp(0, _totalPoints - 1);
              final isToday = (index == _totalPoints - 1);
              final date = _getDateForIndex(index);
              final dateLabel = isToday ? 'Hôm nay' : '${date.day}/${date.month}';

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
                '$subscaleName: $score đ\n($dateLabel)',
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
      isCurved: points.length > 1,
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
        show: points.length > 1,
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
