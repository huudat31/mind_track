import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_track/core/constants/app_colors.dart';
import '../../../constants/game_strings.dart';
import '../../../widgets/muoi_den_widget.dart';

class BreathingTutorialDialog extends StatelessWidget {
  final VoidCallback onStart;

  const BreathingTutorialDialog({super.key, required this.onStart});

  static Future<void> show(BuildContext context, {required VoidCallback onStart}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BreathingTutorialDialog(
        onStart: () {
          Navigator.pop(ctx);
          onStart();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MuoiDenWidget(mood: SootMood.thinking, size: 70),
            const SizedBox(height: 12),
            Text(
              GameStrings.breathingTutorialTitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                GameStrings.breathingTutorialContent,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  height: 1.45,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onStart,
                child: Text(
                  GameStrings.breathingStart,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
