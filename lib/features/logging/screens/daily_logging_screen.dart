import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/hotline_dialog.dart';
import '../models/daily_log_model.dart';

class DailyLoggingScreen extends StatefulWidget {
  const DailyLoggingScreen({super.key});

  @override
  State<DailyLoggingScreen> createState() => _DailyLoggingScreenState();
}

class _DailyLoggingScreenState extends State<DailyLoggingScreen> {
  MoodType _selectedMood = MoodType.neutral;
  double _energyLevel = 3.0;
  final Set<String> _selectedTags = {'Công việc'};
  final Set<String> _selectedFlags = {};

  final TextEditingController _eventController = TextEditingController();
  final TextEditingController _thoughtController = TextEditingController();
  final TextEditingController _balancedController = TextEditingController();

  bool _showCrisisBanner = false;

  final List<String> _availableTags = [
    'Công việc',
    'Học tập',
    'Gia đình',
    'Tình cảm',
    'Bạn bè',
    'Sức khỏe',
    'Tài chính',
    'Một mình',
  ];

  // Danh sách từ khóa nhạy cảm quét hoàn toàn OFFLINE trên máy
  final List<String> _crisisKeywords = [
    'tự tử',
    'tự hại',
    'muốn chết',
    'chết đi',
    'kết thúc cuộc sống',
    'không muốn sống',
    'hết hy vọng',
  ];

  void _checkCrisisKeywords(String text) {
    final lower = text.toLowerCase();
    bool detected = false;
    for (final kw in _crisisKeywords) {
      if (lower.contains(kw)) {
        detected = true;
        break;
      }
    }
    if (detected != _showCrisisBanner) {
      setState(() {
        _showCrisisBanner = detected;
      });
    }
  }

  void _saveLog() {
    // Hiển thị thông báo lưu thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Đã lưu ghi nhận hôm nay vào hồ sơ!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );

    // Reset controllers or pop
    _eventController.clear();
    _thoughtController.clear();
    _balancedController.clear();
    setState(() {
      _selectedFlags.clear();
      _showCrisisBanner = false;
    });
  }

  @override
  void dispose() {
    _eventController.dispose();
    _thoughtController.dispose();
    _balancedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi Nhận Hôm Nay'),
        actions: [
          IconButton(
            onPressed: () => HotlineDialog.show(context),
            icon: const Icon(Icons.support_agent_rounded, color: AppColors.accentCoral),
            tooltip: 'Đường dây nóng hỗ trợ',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 1. Mood Selection
            const Text(
              '1. Cảm xúc chủ đạo lúc này',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: MoodType.values.map((mood) {
                final isSelected = _selectedMood == mood;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? mood.color.withValues(alpha: 0.15) : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? mood.color : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(mood.icon, color: mood.color, size: 28),
                          const SizedBox(height: 6),
                          Text(
                            mood.quickName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 2. Energy Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '2. Mức năng lượng cơ thể',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  '${_energyLevel.toInt()} / 5',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            Slider(
              value: _energyLevel,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.surfaceMuted,
              label: '${_energyLevel.toInt()}',
              onChanged: (val) => setState(() => _energyLevel = val),
            ),
            const SizedBox(height: 20),

            // 3. Quick Clinical Flags (Cờ đỏ triệu chứng)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '3. Cờ đỏ triệu chứng lâm sàng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  '${_selectedFlags.length} đã chọn',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Chạm nhanh các dấu hiệu cơ thể/hành vi bạn gặp hôm nay để đưa vào báo cáo cho chuyên gia.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ClinicalFlagsCatalog.allFlags.map((flag) {
                final isSelected = _selectedFlags.contains(flag.id);
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(flag.icon, size: 14, color: isSelected ? Colors.white : AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(flag.name),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.accentCoral,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: isSelected ? AppColors.accentCoral : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFlags.add(flag.id);
                      } else {
                        _selectedFlags.remove(flag.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 4. Context tags
            const Text(
              '4. Ngữ cảnh liên quan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return ChoiceChip(
                  label: Text(tag),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 5. Balanced Trigger Journaling (3 Steps)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.accentLavender.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.psychology_rounded, color: AppColors.accentLavender, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Nhật ký cân bằng (CBT 3 bước)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ghi nhận sự việc và tập nhìn đa chiều, tránh bẫy nghiền ngẫm tiêu cực.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Step 1: Event
                  const Text('Bước 1: Sự việc gì vừa xảy ra?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _eventController,
                    onChanged: _checkCrisisKeywords,
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Bị sếp phê bình trước nhóm...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Step 2: Automatic thought
                  const Text('Bước 2: Suy nghĩ đầu tiên nảy ra?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _thoughtController,
                    onChanged: _checkCrisisKeywords,
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Mình là kẻ vô dụng, mọi người đang chê cười...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Step 3: Balanced perspective (Required for anti-rumination)
                  const Row(
                    children: [
                      Text('Bước 3: Góc nhìn cân bằng hoặc điều kiểm soát được?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Icon(Icons.star_rounded, size: 14, color: AppColors.accentAmber),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _balancedController,
                    onChanged: _checkCrisisKeywords,
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Lần này mình làm chưa tốt, nhưng không có nghĩa mình vô dụng. Mình có thể hỏi lại sếp phần cần sửa...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.primary.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),

                  // Client-side crisis warning banner
                  if (_showCrisisBanner) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentCoral.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: AppColors.accentCoral, size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Có vẻ bạn đang chịu áp lực rất lớn. Bạn có muốn kết nối với ai đó lắng nghe không?',
                              style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                            ),
                          ),
                          TextButton(
                            onPressed: () => HotlineDialog.show(context),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.accentCoral,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text('Xem Hotline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton.icon(
              onPressed: _saveLog,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Lưu Ghi Nhận Hôm Nay'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
