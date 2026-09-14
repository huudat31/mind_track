import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/hotline_dialog.dart';
import '../models/report_config_model.dart';
import '../widgets/report_config_bottom_sheet.dart';
import '../services/pre_therapy_pdf_builder.dart';

class PdfReportScreen extends StatefulWidget {
  const PdfReportScreen({super.key});

  @override
  State<PdfReportScreen> createState() => _PdfReportScreenState();
}

class _PdfReportScreenState extends State<PdfReportScreen> {
  ReportPrivacyConfig _config = const ReportPrivacyConfig();

  void _openPrivacySettings() {
    ReportConfigBottomSheet.show(
      context: context,
      initialConfig: _config,
      onSave: (newConfig) {
        setState(() {
          _config = newConfig;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Interactive Summary & Config Banner (Opens Pop-up on tap)
            _buildConfigSummaryBanner(context),

            // Direct PDF Preview & Native Export Tools
            Expanded(
              child: _buildPreview(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Báo Cáo Trước Trị Liệu',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tài liệu định lượng cho phiên gặp đầu tiên',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút Tóm Tắt & Cấu Hình
              InkWell(
                onTap: _openPrivacySettings,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primaryLight.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: AppColors.primaryLight,
                        size: 15,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Cấu hình',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Nút SOS Hỗ trợ khẩn cấp
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
                    size: 16,
                  ),
                ),
                tooltip: 'Đường dây hỗ trợ khẩn cấp',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSummaryBanner(BuildContext context) {
    final displayName = _config.isAnonymous
        ? 'Hồ sơ ẩn danh (${_config.anonymousCode})'
        : _config.clientDisplayName;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openPrivacySettings,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.primaryLight,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _config.timeframe.label,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chạm để xem tóm tắt lâm sàng & tùy chỉnh nội dung',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryLight.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: PdfPreview(
          build: (format) => PreTherapyPdfBuilder.buildPdf(_config, format: format),
          allowPrinting: true,
          allowSharing: true,
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          maxPageWidth: 700,
          pdfFileName: 'MindTrack_PreTherapy_${_config.isAnonymous ? _config.anonymousCode : "Report"}.pdf',
          loadingWidget: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryLight),
                const SizedBox(height: 14),
                Text(
                  'Đang tạo báo cáo lâm sàng...',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          onError: (context, error) {
            return Container(
              color: AppColors.darkCard,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4A261).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sync_problem_rounded,
                        color: Color(0xFFF4A261),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cần khởi động lại ứng dụng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thư viện xuất PDF vừa được thêm mới cần được nạp qua việc khởi động lại ứng dụng trên thiết bị.\n\nChi tiết kỹ thuật: $error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final bytes = await PreTherapyPdfBuilder.buildPdf(_config);
                          await Printing.sharePdf(
                            bytes: bytes,
                            filename: 'MindTrack_Report_${_config.isAnonymous ? _config.anonymousCode : "PreTherapy"}.pdf',
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Không thể chia sẻ: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Thử Xuất / Chia Sẻ File PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: AppColors.darkBg,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          actions: [
            PdfPreviewAction(
              icon: const Icon(Icons.tune_rounded),
              onPressed: (context, build, pageFormat) => _openPrivacySettings(),
            ),
          ],
        ),
      ),
    );
  }
}
