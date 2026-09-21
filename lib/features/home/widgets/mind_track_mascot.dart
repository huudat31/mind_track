import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';

/// Linh vật đồng hành của MindTrack (được vẽ bằng vector CustomPainter)
/// Tạo cảm giác ấm áp, chữa lành và hướng dẫn người dùng như trong thiết kế mẫu.
class MindTrackMascot extends StatelessWidget {
  final double size;

  const MindTrackMascot({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: CustomPaint(
        painter: _MascotPainter(),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Các bút vẽ
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF334E49)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final sageCapPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final sageVestPaint = Paint()
      ..color = const Color(0xFF6A908A)
      ..style = PaintingStyle.fill;

    final vestLightPaint = Paint()
      ..color = const Color(0xFF7FA7A1)
      ..style = PaintingStyle.fill;

    final blushPaint = Paint()
      ..color = const Color(0xFFFF9AA2).withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final earInnerPaint = Paint()
      ..color = const Color(0xFFFFD1DC)
      ..style = PaintingStyle.fill;

    final wandPaint = Paint()
      ..color = const Color(0xFF4A6B66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final starPaint = Paint()
      ..color = const Color(0xFFF9C74F)
      ..style = PaintingStyle.fill;

    // 1. Vẽ áo / thân người
    final bodyPath = Path()
      ..moveTo(w * 0.28, h * 0.68)
      ..cubicTo(w * 0.15, h * 0.85, w * 0.15, h * 0.98, w * 0.20, h * 1.0)
      ..lineTo(w * 0.80, h * 1.0)
      ..cubicTo(w * 0.85, h * 0.98, w * 0.85, h * 0.85, w * 0.72, h * 0.68)
      ..close();

    canvas.drawPath(bodyPath, sageVestPaint);
    canvas.drawPath(bodyPath, outlinePaint);

    // Cổ áo / vạt áo
    final collarPath = Path()
      ..moveTo(w * 0.40, h * 0.68)
      ..lineTo(w * 0.50, h * 0.82)
      ..lineTo(w * 0.60, h * 0.68)
      ..close();
    canvas.drawPath(collarPath, vestLightPaint);
    canvas.drawPath(collarPath, outlinePaint);

    // Cúc áo nhỏ
    final buttonPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.50, h * 0.89), 2.2, buttonPaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.89), 2.2, outlinePaint);

    // 2. Hai tai thỏ / gấu nhỏ xinh
    // Tai trái
    final leftEarPath = Path()
      ..moveTo(w * 0.32, h * 0.35)
      ..cubicTo(w * 0.22, h * 0.15, w * 0.36, h * 0.08, w * 0.42, h * 0.26)
      ..close();
    canvas.drawPath(leftEarPath, bodyPaint);
    canvas.drawPath(leftEarPath, outlinePaint);

    final leftEarInner = Path()
      ..moveTo(w * 0.33, h * 0.32)
      ..cubicTo(w * 0.26, h * 0.18, w * 0.36, h * 0.14, w * 0.39, h * 0.27)
      ..close();
    canvas.drawPath(leftEarInner, earInnerPaint);

    // Tai phải
    final rightEarPath = Path()
      ..moveTo(w * 0.58, h * 0.26)
      ..cubicTo(w * 0.64, h * 0.08, w * 0.78, h * 0.15, w * 0.68, h * 0.35)
      ..close();
    canvas.drawPath(rightEarPath, bodyPaint);
    canvas.drawPath(rightEarPath, outlinePaint);

    final rightEarInner = Path()
      ..moveTo(w * 0.61, h * 0.27)
      ..cubicTo(w * 0.64, h * 0.14, w * 0.74, h * 0.18, w * 0.67, h * 0.32)
      ..close();
    canvas.drawPath(rightEarInner, earInnerPaint);

    // 3. Khuôn mặt tròn đầy đặn
    final faceRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.50),
      width: w * 0.54,
      height: h * 0.44,
    );
    canvas.drawOval(faceRect, bodyPaint);
    canvas.drawOval(faceRect, outlinePaint);

    // Hai má hồng
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.33, h * 0.55),
        width: w * 0.10,
        height: h * 0.06,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.67, h * 0.55),
        width: w * 0.10,
        height: h * 0.06,
      ),
      blushPaint,
    );

    // Hai mắt đen long lanh (nhìn dịu dàng)
    final eyePaint = Paint()
      ..color = const Color(0xFF263734)
      ..style = PaintingStyle.fill;

    // Mắt trái
    canvas.drawCircle(Offset(w * 0.39, h * 0.48), w * 0.032, eyePaint);
    canvas.drawCircle(Offset(w * 0.38, h * 0.47), w * 0.012, Paint()..color = Colors.white);

    // Mắt phải
    canvas.drawCircle(Offset(w * 0.61, h * 0.48), w * 0.032, eyePaint);
    canvas.drawCircle(Offset(w * 0.60, h * 0.47), w * 0.012, Paint()..color = Colors.white);

    // Mũi nhỏ & miệng cười hiền
    final nosePath = Path()
      ..moveTo(w * 0.48, h * 0.53)
      ..quadraticBezierTo(w * 0.50, h * 0.52, w * 0.52, h * 0.53)
      ..quadraticBezierTo(w * 0.50, h * 0.55, w * 0.48, h * 0.53);
    canvas.drawPath(nosePath, eyePaint);

    // Nụ cười
    final smilePath = Path()
      ..moveTo(w * 0.44, h * 0.56)
      ..quadraticBezierTo(w * 0.47, h * 0.59, w * 0.50, h * 0.57)
      ..quadraticBezierTo(w * 0.53, h * 0.59, w * 0.56, h * 0.56);
    final smilePaint = Paint()
      ..color = const Color(0xFF263734)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(smilePath, smilePaint);

    // 4. Mũ cử nhân / chánh niệm màu xanh sage nghiêng nhẹ
    final capCenter = Offset(w * 0.65, h * 0.22);
    canvas.save();
    canvas.translate(capCenter.dx, capCenter.dy);
    canvas.rotate(12 * math.pi / 180);

    // Đáy mũ
    final capBaseRect = Rect.fromCenter(
      center: const Offset(0, 7),
      width: w * 0.22,
      height: 12,
    );
    canvas.drawOval(capBaseRect, Paint()..color = const Color(0xFF385551));
    canvas.drawOval(capBaseRect, outlinePaint);

    // Mặt nón tứ giác
    final mortarPath = Path()
      ..moveTo(0, -12)
      ..lineTo(w * 0.24, 0)
      ..lineTo(0, 12)
      ..lineTo(-w * 0.24, 0)
      ..close();
    canvas.drawPath(mortarPath, sageCapPaint);
    canvas.drawPath(mortarPath, outlinePaint);

    // Nút giữa mũ
    canvas.drawCircle(Offset.zero, 3.2, Paint()..color = const Color(0xFFF9C74F));

    // Dây tua rua mũ
    final tasselPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(w * 0.16, 6, w * 0.20, 18);
    final tasselPaint = Paint()
      ..color = const Color(0xFFF9C74F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(tasselPath, tasselPaint);
    canvas.drawCircle(Offset(w * 0.20, 18), 2.5, starPaint);

    canvas.restore();

    // 5. Tay cầm gậy chỉ dẫn (Pointer Wand) chỉ về phía trước/dưới
    // Gậy chỉ
    canvas.drawLine(
      Offset(w * 0.20, h * 0.40),
      Offset(w * 0.38, h * 0.78),
      wandPaint,
    );
    // Đầu que phát sáng nhỏ
    canvas.drawCircle(Offset(w * 0.20, h * 0.40), 3.5, starPaint);
    canvas.drawCircle(
      Offset(w * 0.20, h * 0.40),
      3.5,
      Paint()
        ..color = const Color(0xFF334E49)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Bàn tay nhỏ ôm que
    final handRect = Rect.fromCenter(
      center: Offset(w * 0.32, h * 0.72),
      width: w * 0.11,
      height: h * 0.08,
    );
    canvas.drawOval(handRect, bodyPaint);
    canvas.drawOval(handRect, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
