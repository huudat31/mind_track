import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../constants/game_strings.dart';
import 'muoi_den_widget.dart';
import 'star_rating.dart';

class ResultDialog extends StatelessWidget {
  final int stars; // 0 - 3
  final int score;
  final VoidCallback onReplay;
  final VoidCallback onContinue;
  final String? customMessage;

  const ResultDialog({
    super.key,
    required this.stars,
    required this.score,
    required this.onReplay,
    required this.onContinue,
    this.customMessage,
  });

  static Future<void> show({
    required BuildContext context,
    required int stars,
    required int score,
    required VoidCallback onReplay,
    required VoidCallback onContinue,
    String? customMessage,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ResultDialog(
        stars: stars,
        score: score,
        onReplay: onReplay,
        onContinue: onContinue,
        customMessage: customMessage,
      ),
    );
  }

  String get _motivationText {
    if (customMessage != null && customMessage!.isNotEmpty) {
      return customMessage!;
    }
    if (stars >= 3) {
      return GameStrings.motivationThreeStars;
    } else if (stars == 2) {
      return GameStrings.motivationTwoStars;
    } else {
      return GameStrings.motivationOneStar;
    }
  }

  SootMood get _sootMood {
    if (stars >= 3) return SootMood.happy;
    if (stars >= 1) return SootMood.calm;
    return SootMood.thinking;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Muội Đen chúc mừng
              MuoiDenWidget(
                mood: _sootMood,
                size: 84,
              ),
              const SizedBox(height: 12),

              // Tiêu đề
              Text(
                stars > 0 ? GameStrings.resultTitleSuccess : GameStrings.resultTitleKeepGoing,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Đánh giá sao
              StarRating(stars: stars, size: 36, animate: true),
              const SizedBox(height: 6),

              Text(
                '${GameStrings.bestScore}: $score%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),

              // Lời động viên CBT xoa dịu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  _motivationText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    height: 1.45,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Nút hành động: Chơi lại & Tiếp tục
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.primary, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onReplay();
                      },
                      child: Text(
                        GameStrings.replay,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onContinue();
                      },
                      child: Text(
                        GameStrings.continueText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
