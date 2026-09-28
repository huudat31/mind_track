import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_track/core/constants/app_colors.dart';
import '../../../models/evidence_card_model.dart';

class ScalePlateTarget extends StatelessWidget {
  final EvidenceSide side;
  final String title;
  final List<EvidenceCardModel> placedCards;
  final Function(EvidenceCardModel card) onCardAccepted;
  final VoidCallback? onTapPlate;
  final bool isSelectedTarget;

  const ScalePlateTarget({
    super.key,
    required this.side,
    required this.title,
    required this.placedCards,
    required this.onCardAccepted,
    this.onTapPlate,
    this.isSelectedTarget = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSupport = side == EvidenceSide.support;
    final accentColor = isSupport ? AppColors.accentAmber : AppColors.primary;
    final badgeBg = isSupport ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7);
    final badgeTextColor = isSupport ? const Color(0xFF92400E) : const Color(0xFF166534);

    return DragTarget<EvidenceCardModel>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) => onCardAccepted(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Semantics(
          label: 'Đĩa cân $title, hiện có ${placedCards.length} thẻ',
          button: true,
          child: GestureDetector(
            onTap: onTapPlate,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isHovered || isSelectedTarget
                    ? accentColor.withValues(alpha: 0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isHovered || isSelectedTarget ? accentColor : AppColors.border,
                  width: isHovered || isSelectedTarget ? 2.0 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Đĩa cân icon + tiêu đề
                  Icon(
                    isSupport ? Icons.thumb_down_alt_outlined : Icons.verified_outlined,
                    size: 22,
                    color: accentColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Huy hiệu số lượng thẻ đã đặt
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${placedCards.length} thẻ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
