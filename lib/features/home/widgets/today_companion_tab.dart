import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../core/widgets/hotline_dialog.dart';
import '../../auth/widgets/auth_modal_sheet.dart';
import '../../breathing/screens/box_breathing_screen.dart';
import 'mind_track_mascot.dart';
import 'reminder_settings_bottom_sheet.dart';

class TodayCompanionTab extends StatefulWidget {
  final Function(int)? onSelectTab;

  const TodayCompanionTab({super.key, this.onSelectTab});

  @override
  State<TodayCompanionTab> createState() => _TodayCompanionTabState();
}

class _TodayCompanionTabState extends State<TodayCompanionTab> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Chào buổi sáng!';
    } else if (hour >= 12 && hour < 18) {
      return 'Chào buổi chiều!';
    } else {
      return 'Chào buổi tối!';
    }
  }

  void _showSettingsMenu() {
    final isSynced =
        SupabaseAuthService.currentUser != null &&
        !SupabaseAuthService.isAnonymous;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh kéo
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Cài đặt & Tiện ích',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildSettingsOption(
                icon: Icons.alarm_rounded,
                iconColor: AppColors.primary,
                title: 'Lịch nhắc check-in hàng ngày',
                subtitle: 'Đặt thông báo nhắc nhở ghi nhận cảm xúc',
                onTap: () {
                  Navigator.pop(ctx);
                  ReminderSettingsBottomSheet.show(context);
                },
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildSettingsOption(
                icon: isSynced
                    ? Icons.cloud_done_rounded
                    : Icons.account_circle_outlined,
                iconColor: isSynced
                    ? const Color(0xFF2A9D8F)
                    : AppColors.primaryLight,
                title: isSynced
                    ? 'Tài khoản đã đồng bộ'
                    : 'Tài khoản & Đăng nhập',
                subtitle: isSynced
                    ? 'Dữ liệu đã được lưu trữ trên đám mây'
                    : 'Đăng nhập để đồng bộ và lưu trữ lịch sử',
                onTap: () {
                  Navigator.pop(ctx);
                  AuthModalSheet.show(
                    context,
                    onAuthChanged: () {
                      setState(() {});
                    },
                  );
                },
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildSettingsOption(
                icon: Icons.support_agent_rounded,
                iconColor: AppColors.accentCoral,
                title: 'Đường dây nóng khẩn cấp (SOS)',
                subtitle: 'Liên hệ chuyên gia & trung tâm khủng hoảng tâm lý',
                onTap: () {
                  Navigator.pop(ctx);
                  HotlineDialog.show(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  void _showReportOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Thống kê & Báo cáo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Lựa chọn mục bạn muốn theo dõi hoặc xuất dữ liệu',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4A261).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.insert_chart_rounded,
                    color: Color(0xFFE76F51),
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Biểu đồ Tần suất & Xu hướng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Phân tích nhịp sinh học, cờ đỏ và xu hướng cảm xúc',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onSelectTab?.call(3);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C6FA0).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Color(0xFF7C6FA0),
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Báo cáo Lâm sàng PDF',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Xuất hồ sơ tiến trình chuẩn gửi cho Bác sĩ / Nhà trị liệu',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onSelectTab?.call(4);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTall = constraints.maxHeight >= 640;

            final Widget gridSection = isTall
                ? Expanded(child: _buildFeatureGrid(isExpanded: true))
                : _buildFeatureGrid(isExpanded: false);

            final content = Column(
              children: [
                _buildTopBar(),

                const SizedBox(height: 10),

                // 2. Banner chào mừng (Sage pastel + Lời chào + Linh vật Mascot + Thanh chọn pill)
                _buildHeaderBanner(),

                const SizedBox(height: 14),

                // 3. Lưới 2x2 gồm 4 module thẻ tính năng chính chia đều không gian
                gridSection,
              ],
            );

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 95),
              child: isTall
                  ? content
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: content,
                    ),
            );
          },
        ),
      ),
    );
  }

  /// 1. Top Bar: Căn giữa tiêu đề chính xác bằng Row đối xứng, nút cài đặt nằm độc lập bên phải
  Widget _buildTopBar() {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: Row(
        children: [
          // Khoảng trống cân bằng bên trái (bằng đúng kích thước icon bên phải)
          const SizedBox(width: 48),

          // Tiêu đề Trang chủ căn chính giữa
          const Expanded(
            child: Center(
              child: Text(
                'Trang chủ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),

          // Nút bánh răng cài đặt nằm gọn ở mép phải
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textPrimary,
                size: 24,
              ),
              tooltip: 'Cài đặt & Tiện ích',
              onPressed: _showSettingsMenu,
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Header Banner: Nền Sage Mint pastel, Lời chào, Mascot và Thanh hướng dẫn
  Widget _buildHeaderBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2EDE9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCEE0D9), width: 1.2),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lời chào bên trái
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hôm nay cùng lắng nghe và chăm sóc tâm trí nhé!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF42635E),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              // Linh vật bên phải
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: MindTrackMascot(size: 88),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Thanh hướng dẫn bo tròn (Pill selection guide)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Chọn tính năng bạn muốn thực hiện bên dưới',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334E4A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Lưới 2x2 gồm 4 module được chia đều và cân đối không gian
  Widget _buildFeatureGrid({required bool isExpanded}) {
    final row1 = Row(
      children: [
        // Thẻ 1 (Góc trên - Trái): Ghi nhận Cảm xúc (Sage / Teal)
        Expanded(
          child: _buildMenuCard(
            backgroundColor: const Color(0xFFEBF5F3),
            borderColor: const Color(0xFFCBE5DE),
            accentColor: const Color(0xFF2A9D8F),
            icon: Icons.edit_note_rounded,
            title: 'Ghi nhận Cảm xúc',
            description: 'Lắng nghe tâm trạng\nvà giải tỏa cảm xúc',
            isExpanded: isExpanded,
            onTap: () {
              widget.onSelectTab?.call(2); // Chuyển sang Tab Cảm xúc
            },
          ),
        ),
        const SizedBox(width: 14),
        // Thẻ 2 (Góc trên - Phải): Đánh giá DASS-21 (Sky Blue)
        Expanded(
          child: _buildMenuCard(
            backgroundColor: const Color(0xFFEDF5FD),
            borderColor: const Color(0xFFCCE2FA),
            accentColor: const Color(0xFF2B6CB0),
            icon: Icons.assignment_outlined,
            title: 'Đánh giá DASS-21',
            description: 'Trắc nghiệm chuẩn\nlâm sàng 21 câu',
            isExpanded: isExpanded,
            onTap: () {
              widget.onSelectTab?.call(1); // Chuyển sang Tab DASS-21
            },
          ),
        ),
      ],
    );

    final row2 = Row(
      children: [
        // Thẻ 3 (Góc dưới - Trái): Thở 4-4-4-4 (Coral / Peach)
        Expanded(
          child: _buildMenuCard(
            backgroundColor: const Color(0xFFFEF3EC),
            borderColor: const Color(0xFFFBD7C4),
            accentColor: const Color(0xFFE07A5F),
            icon: Icons.self_improvement_rounded,
            title: 'Luyện thở 4-4-4-4',
            description: 'Điều hòa nhịp tim\nvà xoa dịu thần kinh',
            isExpanded: isExpanded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BoxBreathingScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 14),
        // Thẻ 4 (Góc dưới - Phải): Báo cáo & Hồ sơ (Lavender)
        Expanded(
          child: _buildMenuCard(
            backgroundColor: const Color(0xFFF4EFF9),
            borderColor: const Color(0xFFDECFF1),
            accentColor: const Color(0xFF7C6FA0),
            icon: Icons.person_rounded,
            title: 'Báo cáo & Hồ sơ',
            description: 'Biểu đồ tiến trình\nvà xuất file PDF',
            isExpanded: isExpanded,
            onTap: _showReportOptionsSheet,
          ),
        ),
      ],
    );

    if (isExpanded) {
      return Column(
        children: [
          Expanded(child: row1),
          const SizedBox(height: 14),
          Expanded(child: row2),
        ],
      );
    } else {
      return Column(children: [row1, const SizedBox(height: 14), row2]);
    }
  }

  /// Khung thẻ lớn bo tròn với huy hiệu tròn trắng và nút mũi tên góc phải
  Widget _buildMenuCard({
    required Color backgroundColor,
    required Color borderColor,
    required Color accentColor,
    required IconData icon,
    required String title,
    required String description,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            if (isExpanded)
              const Spacer(flex: 2)
            else
              const SizedBox(height: 6),

            // Huy hiệu tròn trắng chứa icon
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor.withValues(alpha: 0.7),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: accentColor, size: 30),
            ),

            if (isExpanded)
              const Spacer(flex: 2)
            else
              const SizedBox(height: 10),

            // Tiêu đề in đậm màu chủ đạo
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: accentColor,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 5),

            // Phụ đề 2 dòng
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),

            if (isExpanded)
              const Spacer(flex: 3)
            else
              const SizedBox(height: 10),

            // Nút tròn mũi tên ở góc phải dưới
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
