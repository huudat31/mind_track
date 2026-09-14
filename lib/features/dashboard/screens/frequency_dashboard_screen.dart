import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_clinical_service.dart';
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
      backgroundColor: AppColors.darkBg,
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
                    // Cycle progress status card from Supabase
                    _buildCycleStatusCard(),

                    const SizedBox(height: 18),

                    // 1. DASS-21 Longitudinal Trend Chart from Supabase
                    FutureBuilder<List<DassHistoryPoint>>(
                      future: ClinicalDataRepository.getDynamicDassTrend(_selectedTimeframe),
                      builder: (context, snapshot) {
                        return DassTrendChart(history: snapshot.data ?? []);
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thống Kê Tần Suất',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Phân tích dữ liệu chu kỳ trước trị liệu',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => HotlineDialog.show(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE07A5F).withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE07A5F).withValues(alpha: 0.4),
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
        color: AppColors.darkCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
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
                      ? AppColors.primary.withValues(alpha: 0.45)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.6),
                          width: 1,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCycleStatusCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: SupabaseClinicalService.getStreakStats(),
      builder: (context, snapshot) {
        final totalDays = (snapshot.data?['totalDaysRecorded'] as int?) ?? 0;
        final progress = (totalDays / 28).clamp(0.0, 1.0);
        final pct = (progress * 100).toInt();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1B3B36).withValues(alpha: 0.6),
                AppColors.darkCard.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.25), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: AppColors.primaryLight,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chu kỳ quan sát',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryLight,
                          ),
                        ),
                        Text(
                          'Ngày $totalDays / 28',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      totalDays == 0
                          ? 'Bắt đầu check-in hôm nay để tích lũy dữ liệu lâm sàng cho phiên tham vấn.'
                          : 'Đã hoàn thành $pct% chu kỳ. Dữ liệu đang được đồng bộ bảo mật cho buổi trị liệu.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPdfBridgeCta(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A2E44).withValues(alpha: 0.75),
            AppColors.darkCard.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFB388FF).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
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
                  color: Color(0xFFB388FF),
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
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Chuẩn bị cho phiên tham vấn đầu tiên? Chuyển hóa toàn bộ biểu đồ tần suất cờ đỏ, tiến trình DASS-21 và các trích đoạn nhật ký được chọn lọc thành Báo cáo PDF chuyên nghiệp gửi nhà tâm lý.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.75),
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
