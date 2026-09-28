import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mind_track/core/constants/app_colors.dart';

class ScaleBeamPainter extends CustomPainter {
  final double tiltAngle; // góc nghiêng radians (âm: nghiêng trái, dương: nghiêng phải)

  ScaleBeamPainter({required this.tiltAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;
    final fulcrumY = h * 0.35; // Điểm tựa trung tâm

    final standPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final basePaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.fill;

    final beamPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    final chainPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final fulcrumPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    // 1. Đế trụ và trụ đứng
    canvas.drawLine(Offset(centerX, fulcrumY), Offset(centerX, h * 0.88), standPaint);

    final basePath = Path()
      ..moveTo(centerX - 36, h * 0.90)
      ..lineTo(centerX + 36, h * 0.90)
      ..lineTo(centerX + 24, h * 0.85)
      ..lineTo(centerX - 24, h * 0.85)
      ..close();
    canvas.drawPath(basePath, basePaint);

    // 2. Thanh xà ngang nghiêng theo tiltAngle
    final beamHalfLength = w * 0.38;
    final leftBeamX = centerX - math.cos(tiltAngle) * beamHalfLength;
    final leftBeamY = fulcrumY - math.sin(tiltAngle) * beamHalfLength;
    final rightBeamX = centerX + math.cos(tiltAngle) * beamHalfLength;
    final rightBeamY = fulcrumY + math.sin(tiltAngle) * beamHalfLength;

    canvas.drawLine(Offset(leftBeamX, leftBeamY), Offset(rightBeamX, rightBeamY), beamPaint);

    // 3. Khớp trục điểm tựa (Fulcrum point)
    canvas.drawCircle(Offset(centerX, fulcrumY), 6.5, fulcrumPaint);

    // 4. Dây treo 2 bên đĩa cân
    const chainLength = 50.0;
    // Dây đĩa trái
    canvas.drawLine(
      Offset(leftBeamX, leftBeamY),
      Offset(leftBeamX - 16, leftBeamY + chainLength),
      chainPaint,
    );
    canvas.drawLine(
      Offset(leftBeamX, leftBeamY),
      Offset(leftBeamX + 16, leftBeamY + chainLength),
      chainPaint,
    );

    // Dây đĩa phải
    canvas.drawLine(
      Offset(rightBeamX, rightBeamY),
      Offset(rightBeamX - 16, rightBeamY + chainLength),
      chainPaint,
    );
    canvas.drawLine(
      Offset(rightBeamX, rightBeamY),
      Offset(rightBeamX + 16, rightBeamY + chainLength),
      chainPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScaleBeamPainter oldDelegate) {
    return oldDelegate.tiltAngle != tiltAngle;
  }
}
