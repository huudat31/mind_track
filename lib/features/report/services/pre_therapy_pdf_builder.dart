import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/services/supabase_clinical_service.dart';
import '../../assessment/models/dass21_model.dart';
import '../../dashboard/data/clinical_data_repository.dart';
import '../../dashboard/models/frequency_analytics_model.dart';
import '../models/report_config_model.dart';

class PreTherapyPdfBuilder {
  static Future<Uint8List> buildPdf(
    ReportPrivacyConfig config, {
    PdfPageFormat? format,
  }) async {
    final pdf = pw.Document();

    // Load Unicode fonts supporting Vietnamese with fallback
    pw.Font fontRegular;
    pw.Font fontBold;
    pw.Font fontItalic;

    try {
      fontRegular = await PdfGoogleFonts.robotoRegular();
      fontBold = await PdfGoogleFonts.robotoBold();
      fontItalic = await PdfGoogleFonts.robotoItalic();
    } catch (_) {
      // Offline fallback to standard fonts
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
      fontItalic = pw.Font.helveticaOblique();
    }

    final theme = pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
      italic: fontItalic,
      fontFallback: [fontRegular],
    );

    // Get clinical data based on timeframe from Supabase
    final dassTrend = await ClinicalDataRepository.getDynamicDassTrend(config.timeframe);
    final flagFrequencies = await ClinicalDataRepository.getDynamicFlagFrequencies(config.timeframe);
    final coOccurrences = await ClinicalDataRepository.getDynamicCoOccurrenceInsights(config.timeframe);

    // Filter selected journals from Supabase
    final realJournals = await SupabaseClinicalService.getRealCbtJournals();
    final selectedJournals = realJournals.isNotEmpty
        ? realJournals.where((j) => config.selectedJournalIds.contains(j.id) || config.selectedJournalIds.isEmpty).toList()
        : <CbtJournalExcerpt>[];

    // Palette
    const primaryColor = PdfColor.fromInt(0xFF1B3B36);     // Dark Sage
    const accentColor = PdfColor.fromInt(0xFF2A9D8F);      // Teal
    const coralColor = PdfColor.fromInt(0xFFE07A5F);       // Coral warning
    const amberColor = PdfColor.fromInt(0xFFF4A261);       // Warm amber
    const lightBg = PdfColor.fromInt(0xFFF7F9F9);          // Card bg
    const borderSubtle = PdfColor.fromInt(0xFFE0E5E5);     // Thin border

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: format ?? PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (context) => pw.Container(
            decoration: const pw.BoxDecoration(
              color: PdfColors.white,
            ),
          ),
        ),
        header: (context) => _buildHeader(config, primaryColor, accentColor, borderSubtle),
        footer: (context) => _buildFooter(context, borderSubtle),
        build: (context) => [
          // Clinical Disclaimer Box
          _buildMedicalDisclaimer(amberColor),

          pw.SizedBox(height: 16),

          // Section 1: DASS-21 Longitudinal Comparison
          if (config.includeDass21) ...[
            _buildSectionTitle('1. TIẾN TRÌNH ĐÁNH GIÁ DASS-21 (SO SÁNH CÁC MỐC QUAN SÁT)', primaryColor),
            pw.SizedBox(height: 8),
            _buildDassTable(dassTrend, borderSubtle, lightBg),
            pw.SizedBox(height: 16),
          ],

          // Section 2: Clinical Flag Frequencies
          if (config.includeSymptomFrequency) ...[
            _buildSectionTitle('2. BẢNG TẦN SUẤT CỜ ĐỎ LÂM SÀNG & TRIỆU CHỨNG THỂ CHẤT', primaryColor),
            pw.SizedBox(height: 8),
            _buildFlagFrequencySection(flagFrequencies, coralColor, borderSubtle, lightBg),
            pw.SizedBox(height: 16),
          ],

          // Section 3: Co-Occurrence Patterns
          if (config.includeCoOccurrence) ...[
            _buildSectionTitle('3. THỐNG KÊ ĐỒNG XUẤT HIỆN (CO-OCCURRENCE PATTERNS)', primaryColor),
            pw.SizedBox(height: 8),
            _buildCoOccurrenceSection(coOccurrences, lightBg, borderSubtle),
            pw.SizedBox(height: 16),
          ],

          // Section 4: Selected CBT Journal Excerpts
          if (selectedJournals.isNotEmpty) ...[
            _buildSectionTitle('4. TRÍCH ĐOẠN NHẬT KÝ NHẬN THỨC - HÀNH VI (CBT EXCERPTS)', primaryColor),
            pw.SizedBox(height: 4),
            pw.Text(
              '* Thân chủ tự chọn lọc và cho phép chia sẻ các trích đoạn này.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 8),
            ...selectedJournals.map((j) => _buildJournalItem(j, lightBg, borderSubtle, accentColor)),
            pw.SizedBox(height: 16),
          ],

          // Section 5: Therapist Discussion Anchors
          _buildSectionTitle('5. GỢI Ý CHỦ ĐỀ KHAI THÁC MỞ ĐẦU CHO CHUYÊN GIA', primaryColor),
          pw.SizedBox(height: 8),
          _buildDiscussionAnchors(lightBg, borderSubtle, primaryColor, flagFrequencies, dassTrend, selectedJournals),
          pw.SizedBox(height: 16),

          // Section 6: Personal Client Note (Optional)
          if (config.therapistNote.trim().isNotEmpty) ...[
            _buildSectionTitle('6. GHI CHÚ CÁ NHÂN GỬI ĐẾN NHÀ THAM VẤN', primaryColor),
            pw.SizedBox(height: 8),
            _buildPersonalNote(config.therapistNote, lightBg, borderSubtle),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(
    ReportPrivacyConfig config,
    PdfColor primaryColor,
    PdfColor accentColor,
    PdfColor borderColor,
  ) {
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: borderColor, width: 1.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 10,
                    height: 10,
                    decoration: pw.BoxDecoration(
                      color: accentColor,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Text(
                    'MINDTRACK • CẦU NỐI TRƯỚC TRỊ LIỆU',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'BÁO CÁO TỔNG QUAN TRƯỚC TRỊ LIỆU',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Pre-Therapy Clinical Briefing & Quantitative Baseline',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: borderColor),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Thân chủ: ${config.clientDisplayName}',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Chu kỳ: ${config.timeframe.label}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
                pw.Text(
                  'Ngày lập: $dateStr',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMedicalDisclaimer(PdfColor amberColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: amberColor, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'LƯU Ý CHUYÊN MÔN & GIỚI HẠN TRÁCH NHIỆM Y TẾ:',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.deepOrange900,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            'Tài liệu này tổng hợp dữ liệu tự theo dõi (self-monitoring) trong sinh hoạt hàng ngày của thân chủ qua ứng dụng MindTrack. Báo cáo này KHÔNG PHẢI KẾT LUẬN CHẨN ĐOÁN Y KHOA và không thay thế buổi đánh giá lâm sàng trực tiếp của chuyên gia tâm lý hoặc bác sĩ chuyên khoa. Các mẫu hình thống kê phản ánh sự đồng xuất hiện (co-occurrence), không khẳng định quan hệ nhân quả. Báo cáo nhằm mục đích cung cấp dữ liệu cơ sở định lượng để tối ưu hóa thời gian phiên tham vấn.',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey800,
              lineSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: color, width: 1.2)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static pw.Widget _buildDassTable(
    List<DassHistoryPoint> history,
    PdfColor borderColor,
    PdfColor lightBg,
  ) {
    if (history.isEmpty) return pw.SizedBox.shrink();

    final baseline = history.first;
    final current = history.last;

    return pw.Table(
      border: pw.TableBorder.all(color: borderColor, width: 0.5),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableCell('Thang đo DASS-21', isHeader: true),
            _tableCell('Điểm Baseline (T0)', isHeader: true, align: pw.TextAlign.center),
            _tableCell('Điểm Hiện tại', isHeader: true, align: pw.TextAlign.center),
            _tableCell('Mức độ lâm sàng', isHeader: true, align: pw.TextAlign.center),
            _tableCell('Biến thiên', isHeader: true, align: pw.TextAlign.center),
          ],
        ),
        // Row: Trầm cảm
        _buildDassTableRow('Trầm cảm (Depression)', baseline.depression, current.depression, DassCategory.depression),
        // Row: Lo âu
        _buildDassTableRow('Lo âu (Anxiety)', baseline.anxiety, current.anxiety, DassCategory.anxiety),
        // Row: Căng thẳng
        _buildDassTableRow('Căng thẳng (Stress)', baseline.stress, current.stress, DassCategory.stress),
      ],
    );
  }

  static pw.TableRow _buildDassTableRow(
    String subscale,
    int t0,
    int current,
    DassCategory category,
  ) {
    final diff = current - t0;
    final diffStr = diff <= 0 ? '$diff đ' : '+$diff đ';
    final severity = Dass21Data.getSeverity(category, current);

    return pw.TableRow(
      children: [
        _tableCell(subscale, isBold: true),
        _tableCell('$t0 / 42', align: pw.TextAlign.center),
        _tableCell('$current / 42', align: pw.TextAlign.center, isBold: true),
        _tableCell(severity, align: pw.TextAlign.center),
        _tableCell(
          diffStr,
          align: pw.TextAlign.center,
          color: diff <= 0 ? PdfColors.teal700 : PdfColors.deepOrange700,
        ),
      ],
    );
  }

  static pw.Widget _tableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    pw.TextAlign align = pw.TextAlign.left,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 8.5 : 8.5,
          fontWeight: isHeader || isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? (isHeader ? PdfColors.black : PdfColors.grey900),
        ),
      ),
    );
  }

  static pw.Widget _buildFlagFrequencySection(
    List<FlagFrequencyStat> flags,
    PdfColor accentColor,
    PdfColor borderColor,
    PdfColor lightBg,
  ) {
    // Show top 6 most prominent flags
    final topFlags = flags.take(6).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: borderColor, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableCell('Thứ tự', isHeader: true, align: pw.TextAlign.center),
            _tableCell('Cờ đỏ lâm sàng', isHeader: true),
            _tableCell('Phân loại', isHeader: true, align: pw.TextAlign.center),
            _tableCell('Tần suất (ngày xuất hiện)', isHeader: true, align: pw.TextAlign.center),
            _tableCell('Tỷ lệ %', isHeader: true, align: pw.TextAlign.center),
          ],
        ),
        ...topFlags.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final stat = entry.value;
          return pw.TableRow(
            children: [
              _tableCell('#$idx', align: pw.TextAlign.center),
              _tableCell(stat.flag.name, isBold: true),
              _tableCell(stat.flag.category, align: pw.TextAlign.center),
              _tableCell('${stat.count}/${stat.totalDays} ngày', align: pw.TextAlign.center),
              _tableCell(
                '${stat.percentage.round()}%',
                align: pw.TextAlign.center,
                isBold: true,
                color: stat.percentage >= 60 ? PdfColors.deepOrange700 : PdfColors.black,
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildCoOccurrenceSection(
    List<CoOccurrenceInsight> insights,
    PdfColor lightBg,
    PdfColor borderColor,
  ) {
    return pw.Column(
      children: insights.map((insight) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 6),
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: lightBg,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            border: pw.Border.all(color: borderColor, width: 0.5),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 6,
                height: 6,
                margin: const pw.EdgeInsets.only(top: 3, right: 8),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.teal,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          insight.title,
                          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          '${insight.percentage}% đồng xuất hiện',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal700,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      insight.observation,
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildJournalItem(
    CbtJournalExcerpt journal,
    PdfColor lightBg,
    PdfColor borderColor,
    PdfColor accentColor,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: lightBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: borderColor, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Ghi nhận: ${journal.dateLabel} • Bối cảnh: [${journal.contextTag}]',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.teal50,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                ),
                child: pw.Text(
                  'CBT 3 Bước',
                  style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          _journalRow('1. Sự kiện kích hoạt (Event):', journal.situation, PdfColors.grey800),
          pw.SizedBox(height: 2),
          _journalRow('2. Suy nghĩ tự động (Automatic Thought):', journal.automaticThought, PdfColors.red900),
          pw.SizedBox(height: 2),
          _journalRow('3. Phản hồi cân bằng (Balanced Response):', journal.balancedResponse, PdfColors.teal900),
        ],
      ),
    );
  }

  static pw.Widget _journalRow(String label, String content, PdfColor color) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label ',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
          ),
          pw.TextSpan(
            text: content,
            style: pw.TextStyle(fontSize: 8, color: color, fontStyle: pw.FontStyle.italic),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDiscussionAnchors(
    PdfColor lightBg,
    PdfColor borderColor,
    PdfColor primaryColor,
    List<FlagFrequencyStat> flagFrequencies,
    List<DassHistoryPoint> dassTrend,
    List<CbtJournalExcerpt> selectedJournals,
  ) {
    final List<String> prompts = [];
    if (flagFrequencies.isNotEmpty) {
      final topFlag = flagFrequencies.first;
      prompts.add('Triệu chứng thể chất & hành vi nổi bật: Cờ đỏ "${topFlag.flag.name}" xuất hiện ${topFlag.count}/${topFlag.totalDays} ngày theo dõi (${topFlag.percentage.toInt()}%). Đề xuất cùng nhà tham vấn tìm hiểu bối cảnh kích hoạt.');
    }
    if (dassTrend.isNotEmpty) {
      final latest = dassTrend.last;
      prompts.add('Mức độ ảnh hưởng tâm lý (DASS-21): Kết quả gần nhất ghi nhận Trầm cảm: ${latest.depression}đ (${latest.getSeverity(DassCategory.depression)}), Lo âu: ${latest.anxiety}đ (${latest.getSeverity(DassCategory.anxiety)}), Căng thẳng: ${latest.stress}đ (${latest.getSeverity(DassCategory.stress)}).');
    }
    if (selectedJournals.isNotEmpty) {
      prompts.add('Tái cấu trúc nhận thức (CBT): Người dùng đã ghi nhận ${selectedJournals.length} tình huống có suy nghĩ tự động và phản hồi cân bằng. Khuyến nghị cùng nhà tham vấn rà soát mô thức nhận thức.');
    }
    if (prompts.isEmpty) {
      prompts.add('Dữ liệu lâm sàng đang trong giai đoạn tích lũy ban đầu. Hãy tiếp tục check-in đều đặn trước phiên tham vấn đầu tiên.');
    }

    return pw.Column(
      children: prompts.asMap().entries.map((entry) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 6),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: lightBg,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            border: pw.Border.all(color: borderColor, width: 0.5),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '• ',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
              ),
              pw.Expanded(
                child: pw.Text(
                  entry.value,
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey900, lineSpacing: 1.2),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildPersonalNote(
    String note,
    PdfColor lightBg,
    PdfColor borderColor,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: lightBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: borderColor, width: 0.8),
      ),
      child: pw.Text(
        '“ $note ”',
        style: pw.TextStyle(
          fontSize: 8.5,
          fontStyle: pw.FontStyle.italic,
          color: PdfColors.grey900,
        ),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, PdfColor borderColor) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: borderColor, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'MindTrack • Pre-Therapy Clinical Bridge • Bản quyền thuộc về thân chủ',
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
          ),
          pw.Text(
            'Trang ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }
}
