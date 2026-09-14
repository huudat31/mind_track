import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_clinical_service.dart';
import '../../dashboard/models/frequency_analytics_model.dart';
import '../models/report_config_model.dart';

class ReportConfigBottomSheet extends StatefulWidget {
  final ReportPrivacyConfig initialConfig;
  final ValueChanged<ReportPrivacyConfig> onSave;

  const ReportConfigBottomSheet({
    super.key,
    required this.initialConfig,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required ReportPrivacyConfig initialConfig,
    required ValueChanged<ReportPrivacyConfig> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportConfigBottomSheet(
        initialConfig: initialConfig,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ReportConfigBottomSheet> createState() => _ReportConfigBottomSheetState();
}

class _ReportConfigBottomSheetState extends State<ReportConfigBottomSheet> {
  late bool _isAnonymous;
  late TimeframeOption _timeframe;
  late bool _includeDass21;
  late bool _includeSymptomFrequency;
  late bool _includeCoOccurrence;
  late Set<String> _selectedJournals;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _isAnonymous = widget.initialConfig.isAnonymous;
    _timeframe = widget.initialConfig.timeframe;
    _includeDass21 = widget.initialConfig.includeDass21;
    _includeSymptomFrequency = widget.initialConfig.includeSymptomFrequency;
    _includeCoOccurrence = widget.initialConfig.includeCoOccurrence;
    _selectedJournals = Set.from(widget.initialConfig.selectedJournalIds);
    _noteController = TextEditingController(text: widget.initialConfig.therapistNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.initialConfig.copyWith(
      isAnonymous: _isAnonymous,
      timeframe: _timeframe,
      includeDass21: _includeDass21,
      includeSymptomFrequency: _includeSymptomFrequency,
      includeCoOccurrence: _includeCoOccurrence,
      selectedJournalIds: _selectedJournals,
      therapistNote: _noteController.text,
    );
    widget.onSave(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + keyboardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF142026),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 36,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bộ Lọc Quyền Riêng Tư & Nội Dung',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bạn hoàn toàn kiểm soát dữ liệu xuất hiện trên báo cáo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white60),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Scrollable Settings List
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Anonymous Mode
                  _buildSectionCard(
                    title: 'Bảo mật danh tính (Ẩn danh)',
                    subtitle: 'Mã hóa tên của bạn thành mã hồ sơ tham vấn y tế',
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isAnonymous,
                      onChanged: (val) => setState(() => _isAnonymous = val),
                      activeColor: AppColors.primaryLight,
                      title: Text(
                        _isAnonymous ? 'Đang bật: Hồ sơ ẩn danh (MT-89421)' : 'Tắt: Hiển thị tên đầy đủ',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      subtitle: Text(
                        _isAnonymous
                            ? 'Thông tin danh tính cá nhân sẽ được ẩn hoàn toàn trên file PDF.'
                            : 'Họ tên tài khoản sẽ được in trên phần đầu trang báo cáo.',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2. Timeframe Selection
                  _buildSectionCard(
                    title: 'Chu kỳ dữ liệu quan sát',
                    subtitle: 'Chọn khoảng thời gian tự ghi nhận đưa vào báo cáo',
                    child: Row(
                      children: TimeframeOption.values.map((opt) {
                        final isSel = _timeframe == opt;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _timeframe = opt),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primary.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSel ? AppColors.primaryLight : Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                opt.days == 28 ? '28 ngày' : '${opt.days} ngày',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel ? Colors.white : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 3. Clinical Sections Inclusion
                  _buildSectionCard(
                    title: 'Các phân mục lâm sàng đưa vào PDF',
                    subtitle: 'Bật/tắt các biểu đồ và chỉ số theo ý muốn',
                    child: Column(
                      children: [
                        _buildSwitchRow('Chỉ số DASS-21 (T0 vs Hiện tại)', _includeDass21, (v) => setState(() => _includeDass21 = v)),
                        _buildSwitchRow('Tần suất cờ đỏ thể chất & giấc ngủ', _includeSymptomFrequency, (v) => setState(() => _includeSymptomFrequency = v)),
                        _buildSwitchRow('Phân tích đồng xuất hiện (Co-occurrence)', _includeCoOccurrence, (v) => setState(() => _includeCoOccurrence = v)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4. CBT Journal Selection Checklist
                  _buildSectionCard(
                    title: 'Chọn lọc Trích đoạn Nhật ký CBT',
                    subtitle: 'Chỉ chia sẻ những dòng suy nghĩ bạn cảm thấy thoải mái',
                    child: FutureBuilder<List<CbtJournalExcerpt>>(
                      future: SupabaseClinicalService.getRealCbtJournals(),
                      builder: (context, snapshot) {
                        final journals = snapshot.data ?? [];
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight),
                              ),
                            ),
                          );
                        }

                        if (journals.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Center(
                              child: Text(
                                'Chưa có trích đoạn nhật ký CBT nào được ghi nhận.\nBạn có thể hoàn thành form CBT 3 bước ở màn hình "Cảm xúc".',
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

                        return Column(
                          children: journals.map((journal) {
                            final isChecked = _selectedJournals.contains(journal.id);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isChecked ? AppColors.primaryLight.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    activeColor: AppColors.primaryLight,
                                    checkColor: AppColors.darkBg,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedJournals.add(journal.id);
                                        } else {
                                          _selectedJournals.remove(journal.id);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                journal.contextTag,
                                                style: const TextStyle(fontSize: 10, color: Colors.white70),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              journal.dateLabel,
                                              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          journal.situation,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Suy nghĩ: ${journal.automaticThought}',
                                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 5. Personal Note to Therapist
                  _buildSectionCard(
                    title: 'Ghi chú gửi chuyên gia tham vấn',
                    subtitle: 'Những điều bạn muốn ưu tiên làm rõ trong buổi đầu tiên',
                    child: TextField(
                      controller: _noteController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Nhập ghi chú hoặc câu hỏi muốn gửi chuyên gia...',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryLight),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.darkBg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: const Text(
                'Lưu Cấu Hình & Cập Nhật Báo Cáo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.55)),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}
