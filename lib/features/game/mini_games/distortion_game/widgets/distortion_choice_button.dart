import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_track/core/constants/app_colors.dart';
import '../../../models/cognitive_distortion_type.dart';

enum ChoiceFeedbackState { idle, correct, wrong }

class DistortionChoiceButton extends StatelessWidget {
  final CognitiveDistortionType type;
  final VoidCallback? onTap;
  final ChoiceFeedbackState feedbackState;
  final bool isSelected;

  const DistortionChoiceButton({
    super.key,
    required this.type,
    required this.onTap,
    this.feedbackState = ChoiceFeedbackState.idle,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = AppColors.border;
    Color textColor = AppColors.textPrimary;
    Widget? trailingIcon;

    switch (feedbackState) {
      case ChoiceFeedbackState.correct:
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFF4ADE80);
        textColor = const Color(0xFF166534);
        trailingIcon = const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20);
        break;
      case ChoiceFeedbackState.wrong:
        bgColor = const Color(0xFFFFF1F2);
        borderColor = const Color(0xFFF87171);
        textColor = const Color(0xFF991B1B);
        trailingIcon = const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 20);
        break;
      case ChoiceFeedbackState.idle:
        if (isSelected) {
          bgColor = AppColors.primary.withValues(alpha: 0.08);
          borderColor = AppColors.primary;
          textColor = AppColors.primaryDark;
        }
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        label: 'Lựa chọn: ${type.displayName}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: feedbackState == ChoiceFeedbackState.idle ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      type.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  ?trailingIcon,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
