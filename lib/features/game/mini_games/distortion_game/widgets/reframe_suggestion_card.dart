import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_track/core/constants/app_colors.dart';
import '../../../constants/game_strings.dart';
import '../../../models/distortion_question.dart';

class ReframeSuggestionCard extends StatelessWidget {
  final DistortionQuestion question;
  final bool isCorrect;
  final VoidCallback onNext;

  const ReframeSuggestionCard({
    super.key,
    required this.question,
    required this.isCorrect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header phản hồi
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCorrect
                      ? GameStrings.distortionCorrectFeedback
                      : GameStrings.distortionWrongFeedback,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? const Color(0xFF166534) : const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Lời giải thích bản chất bẫy tư duy
          Text(
            question.explanation,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Gợi ý đổi góc nhìn (Reframe)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GameStrings.reframeTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.reframeSuggestion,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Nút đi tiếp
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onNext,
              child: Text(
                GameStrings.nextQuestion,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
