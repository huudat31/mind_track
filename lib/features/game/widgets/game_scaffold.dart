import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/hotline_dialog.dart';
import '../constants/game_strings.dart';

/// Khung Scaffold chuẩn cho tất cả các màn hình trong module Game.
/// Tích hợp nút quay lại, tiêu đề, nút khẩn cấp cố định và bọc SafeArea an toàn.
class GameScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool showEmergencyButton;
  final Color backgroundColor;

  const GameScaffold({
    super.key,
    required this.title,
    required this.body,
    this.trailing,
    this.onBack,
    this.showEmergencyButton = true,
    this.backgroundColor = AppColors.background,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: GameStrings.back,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      color: AppColors.textPrimary,
                      tooltip: GameStrings.back,
                      onPressed: () {
                        if (onBack != null) {
                          onBack!();
                        } else {
                          Navigator.maybePop(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showEmergencyButton)
                    Semantics(
                      button: true,
                      label: GameStrings.emergencySupportTooltip,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => HotlineDialog.show(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.accentCoral.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.accentCoral.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.phone_in_talk_rounded,
                                  color: AppColors.accentCoral,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 125),
                                  child: Text(
                                    GameStrings.emergencySupport,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accentCoral,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (trailing != null) ...[
                    const SizedBox(width: 6),
                    trailing!,
                  ],
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Content Area
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
