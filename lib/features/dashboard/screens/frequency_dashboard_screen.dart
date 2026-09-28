import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/hotline_dialog.dart';
import '../../report/screens/pdf_report_screen.dart';
import '../models/frequency_analytics_model.dart';
import '../data/clinical_data_repository.dart';
import '../widgets/dass_trend_chart.dart';
import '../widgets/symptom_frequency_tracker.dart';
import '../widgets/co_occurrence_card.dart';
import '../widgets/energy_mood_rhythm_card.dart';

class FrequencyDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToReport;

  const FrequencyDashboardScreen({
    super.key,
    this.onNavigateToReport,
  });

  @override
  State<FrequencyDashboardScreen> createState() => _FrequencyDashboardScreenState();
}

class _FrequencyDashboardScreenState extends State<FrequencyDashboardScreen> {
  TimeframeOption _selectedTimeframe = TimeframeOption.fourteenDays;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildHeader(context),

            // Timeframe Selector Tabs
            _buildTimeframeSelector(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. DASS-21 Longitudinal Trend Chart from Supabase
                    FutureBuilder<List<DassHistoryPoint>>(
                      future: ClinicalDataRepository.getDynamicDassTrend(_selectedTimeframe),
                      builder: (context, snapshot) {
                        return DassTrendChart(
                          history: snapshot.data ?? [],
                          timeframe: _selectedTimeframe,
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // 2. Clinical Flag Frequency Tracker
                    SymptomFrequencyTracker(timeframe: _selectedTimeframe),

                    const SizedBox(height: 18),

                    // 3. Clinical Co-Occurrence Card
                    CoOccurrenceCard(timeframe: _selectedTimeframe),

                    const SizedBox(height: 18),

                    // 4. Energy & Mood Rhythm
                    EnergyMoodRhythmCard(timeframe: _selectedTimeframe),

                    const SizedBox(height: 22),

                    // 5. Hero PDF Export Bridge CTA
                    _buildPdfBridgeCta(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thống Kê Tần Suất',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Phân tích dữ liệu chu kỳ trước trị liệu',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => HotlineDialog.show(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE07A5F).withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE07A5F).withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.phone_in_talk_rounded,
                color: Color(0xFFE07A5F),
                size: 18,
              ),
            ),
            tooltip: 'Đường dây hỗ trợ khẩn cấp',
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: TimeframeOption.values.map((option) {
          final isSelected = _selectedTimeframe == option;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeframe = option;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPdfBridgeCta(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFDDD6FE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
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
                  color: const Color(0xFFB388FF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFF7C4DFF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Cầu Nối Trước Trị Liệu (Pre-Therapy Bridge)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5B21B6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Chuẩn bị cho phiên tham vấn đầu tiên? Chuyển hóa toàn bộ biểu đồ tần suất cờ đỏ, tiến trình DASS-21 và các trích đoạn nhật ký được chọn lọc thành Báo cáo PDF chuyên nghiệp gửi nhà tâm lý.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6D28D9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (widget.onNavigateToReport != null) {
                  widget.onNavigateToReport!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PdfReportScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_stories_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Tạo Báo Cáo PDF Cho Chuyên Gia',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
