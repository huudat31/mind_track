import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_track/core/constants/app_colors.dart';
import '../../../models/evidence_card_model.dart';

class EvidenceCardWidget extends StatelessWidget {
  final EvidenceCardModel card;
  final bool isSelected;
  final VoidCallback? onTap;

  const EvidenceCardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.onTap,
  });

  Widget _buildCardContent(BuildContext context, {bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF3B82F6) : AppColors.border,
          width: isSelected ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDragging ? 0.15 : 0.04),
            blurRadius: isDragging ? 14 : 6,
            offset: Offset(0, isDragging ? 6 : 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.drag_indicator_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              card.text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Thẻ bằng chứng: ${card.text}',
      button: true,
      child: Draggable<EvidenceCardModel>(
        data: card,
        feedback: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: _buildCardContent(context, isDragging: true),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.35,
          child: _buildCardContent(context),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: _buildCardContent(context),
        ),
      ),
    );
  }
}
