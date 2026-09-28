import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum SootMood {
  calm,
  worried,
  thinking,
  happy;

  String get semanticLabel {
    switch (this) {
      case SootMood.calm:
        return 'Muội Đen đang bình tĩnh, thư thái';
      case SootMood.worried:
        return 'Muội Đen đang lo âu, bối rối';
      case SootMood.thinking:
        return 'Muội Đen đang trầm ngâm suy nghĩ';
      case SootMood.happy:
        return 'Muội Đen đang vui vẻ, nhẹ nhõm';
    }
  }
}

/// Widget vẽ nhân vật đồng hành Muội Đen thuần vector bằng CustomPainter.
/// Hỗ trợ 4 biểu cảm, chuyển trạng thái mượt ~300ms và nhấp nhô nhẹ (idle floating).
class MuoiDenWidget extends StatefulWidget {
  final SootMood mood;
  final double size;
  final Color? bodyColor;

  const MuoiDenWidget({
    super.key,
    this.mood = SootMood.calm,
    this.size = 90,
    this.bodyColor,
  });

  @override
  State<MuoiDenWidget> createState() => _MuoiDenWidgetState();
}

class _MuoiDenWidgetState extends State<MuoiDenWidget>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _moodTransitionController;
  SootMood _prevMood = SootMood.calm;
  SootMood _targetMood = SootMood.calm;

  @override
  void initState() {
    super.initState();
    _targetMood = widget.mood;
    _prevMood = widget.mood;

    // Nhấp nhô thở nhẹ nhàng chu kỳ 2.4s
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Chuyển biểu cảm mượt mà 300ms
    _moodTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnim) {
      if (_idleController.isAnimating) {
        _idleController.stop();
      }
    } else {
      if (!_idleController.isAnimating) {
        _idleController.repeat(reverse: true);
      }
    }
  }

  @override
  void didUpdateWidget(covariant MuoiDenWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      _prevMood = oldWidget.mood;
      _targetMood = widget.mood;
      _moodTransitionController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _moodTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final bodyColor = widget.bodyColor ?? const Color(0xFF243431);

    return Semantics(
      label: widget.mood.semanticLabel,
      image: true,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleController, _moodTransitionController]),
        builder: (context, child) {
          final idleProgress = disableAnim ? 0.0 : _idleController.value;
          final floatOffset = math.sin(idleProgress * math.pi * 2) * (widget.size * 0.04);
          final t = disableAnim ? 1.0 : _moodTransitionController.value;

          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _SootPainter(
                  prevMood: _prevMood,
                  targetMood: _targetMood,
                  transitionProgress: t,
                  bodyColor: bodyColor,
                  idleProgress: idleProgress,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SootPainter extends CustomPainter {
  final SootMood prevMood;
  final SootMood targetMood;
  final double transitionProgress;
  final Color bodyColor;
  final double idleProgress;

  _SootPainter({
    required this.prevMood,
    required this.targetMood,
    required this.transitionProgress,
    required this.bodyColor,
    required this.idleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.38;

    // 1. Vẽ thân muội than xù lông mềm mại (Puffy Soot Body)
    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;

    final puffPaint = Paint()
      ..color = bodyColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    // Vòng xù lông ngoài rìa
    const int puffCount = 14;
    for (int i = 0; i < puffCount; i++) {
      final angle = (i * 2 * math.pi) / puffCount;
      final puffWave = math.sin((idleProgress + i / puffCount) * math.pi * 2) * 1.5;
      final puffRadius = radius * 0.28 + puffWave;
      final px = center.dx + math.cos(angle) * (radius * 0.88);
      final py = center.dy + math.sin(angle) * (radius * 0.88);
      canvas.drawCircle(Offset(px, py), puffRadius, puffPaint);
    }

    // Thân tròn trung tâm
    canvas.drawCircle(center, radius, bodyPaint);

    // 2. Hai má hồng nhẹ
    final blushAlpha = _lerpDouble(
      _blushAlphaFor(prevMood),
      _blushAlphaFor(targetMood),
      transitionProgress,
    );
    final blushPaint = Paint()
      ..color = AppColors.accentCoral.withValues(alpha: blushAlpha)
      ..style = PaintingStyle.fill;

    final leftBlushCenter = Offset(center.dx - radius * 0.52, center.dy + radius * 0.22);
    final rightBlushCenter = Offset(center.dx + radius * 0.52, center.dy + radius * 0.22);
    canvas.drawOval(
      Rect.fromCenter(center: leftBlushCenter, width: radius * 0.26, height: radius * 0.16),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: rightBlushCenter, width: radius * 0.26, height: radius * 0.16),
      blushPaint,
    );

    // 3. Đôi mắt và biểu cảm khuôn mặt
    _drawEyesAndMouth(canvas, center, radius);
  }

  double _blushAlphaFor(SootMood mood) {
    switch (mood) {
      case SootMood.happy:
        return 0.70;
      case SootMood.calm:
        return 0.40;
      case SootMood.worried:
        return 0.25;
      case SootMood.thinking:
        return 0.35;
    }
  }

  void _drawEyesAndMouth(Canvas canvas, Offset center, double radius) {
    final eyeWhitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pupilPaint = Paint()
      ..color = const Color(0xFF161F1D)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, radius * 0.08)
      ..strokeCap = StrokeCap.round;

    final leftEyePos = Offset(center.dx - radius * 0.32, center.dy - radius * 0.08);
    final rightEyePos = Offset(center.dx + radius * 0.32, center.dy - radius * 0.08);
    final eyeRadius = radius * 0.24;

    // Chuyển biến theo targetMood (nếu progress > 0.5 thì vẽ theo targetMood)
    final activeMood = transitionProgress >= 0.5 ? targetMood : prevMood;

    switch (activeMood) {
      case SootMood.happy:
        // Đôi mắt cười hình trăng khuyết (^ ^)
        _drawArchEye(canvas, leftEyePos, eyeRadius * 0.9, strokePaint);
        _drawArchEye(canvas, rightEyePos, eyeRadius * 0.9, strokePaint);

        // Miệng cười tươi mở rộng
        final mouthRect = Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.25),
          width: radius * 0.38,
          height: radius * 0.28,
        );
        final mouthPath = Path()
          ..arcTo(mouthRect, 0, math.pi, true)
          ..close();
        canvas.drawPath(mouthPath, Paint()..color = const Color(0xFFFF8A50));
        canvas.drawPath(mouthPath, strokePaint);
        break;

      case SootMood.worried:
        // Mắt tròn to lo lắng kèm con ngươi nhỏ hơn
        canvas.drawCircle(leftEyePos, eyeRadius, eyeWhitePaint);
        canvas.drawCircle(rightEyePos, eyeRadius, eyeWhitePaint);

        // Con ngươi co lại nhìn chếch xuống/bối rối
        canvas.drawCircle(
          Offset(leftEyePos.dx + eyeRadius * 0.1, leftEyePos.dy + eyeRadius * 0.1),
          eyeRadius * 0.45,
          pupilPaint,
        );
        canvas.drawCircle(
          Offset(rightEyePos.dx - eyeRadius * 0.1, rightEyePos.dy + eyeRadius * 0.1),
          eyeRadius * 0.45,
          pupilPaint,
        );

        // Lông mày lo lắng nghiêng
        canvas.drawLine(
          Offset(leftEyePos.dx - eyeRadius * 0.8, leftEyePos.dy - eyeRadius * 1.1),
          Offset(leftEyePos.dx + eyeRadius * 0.5, leftEyePos.dy - eyeRadius * 0.7),
          strokePaint,
        );
        canvas.drawLine(
          Offset(rightEyePos.dx + eyeRadius * 0.8, rightEyePos.dy - eyeRadius * 1.1),
          Offset(rightEyePos.dx - eyeRadius * 0.5, rightEyePos.dy - eyeRadius * 0.7),
          strokePaint,
        );

        // Miệng lượn sóng lo âu
        final worryPath = Path()
          ..moveTo(center.dx - radius * 0.20, center.dy + radius * 0.30)
          ..quadraticBezierTo(
            center.dx - radius * 0.08,
            center.dy + radius * 0.24,
            center.dx,
            center.dy + radius * 0.30,
          )
          ..quadraticBezierTo(
            center.dx + radius * 0.08,
            center.dy + radius * 0.36,
            center.dx + radius * 0.20,
            center.dy + radius * 0.30,
          );
        canvas.drawPath(worryPath, strokePaint);
        break;

      case SootMood.thinking:
        // Một mắt to, một mắt nhíu lại suy ngẫm
        canvas.drawCircle(leftEyePos, eyeRadius * 1.05, eyeWhitePaint);
        canvas.drawCircle(
          Offset(leftEyePos.dx + eyeRadius * 0.15, leftEyePos.dy - eyeRadius * 0.1),
          eyeRadius * 0.50,
          pupilPaint,
        );
        canvas.drawCircle(
          Offset(leftEyePos.dx + eyeRadius * 0.25, leftEyePos.dy - eyeRadius * 0.2),
          eyeRadius * 0.18,
          eyeWhitePaint,
        );

        // Mắt phải nhíu
        canvas.drawLine(
          Offset(rightEyePos.dx - eyeRadius * 0.6, rightEyePos.dy),
          Offset(rightEyePos.dx + eyeRadius * 0.6, rightEyePos.dy),
          strokePaint,
        );

        // Miệng chúm chím lệch nhẹ
        final thinkMouthPath = Path()
          ..moveTo(center.dx - radius * 0.08, center.dy + radius * 0.28)
          ..quadraticBezierTo(
            center.dx + radius * 0.10,
            center.dy + radius * 0.24,
            center.dx + radius * 0.15,
            center.dy + radius * 0.32,
          );
        canvas.drawPath(thinkMouthPath, strokePaint);
        break;

      case SootMood.calm:
        // Đôi mắt to tròn long lanh dịu dàng
        canvas.drawCircle(leftEyePos, eyeRadius, eyeWhitePaint);
        canvas.drawCircle(rightEyePos, eyeRadius, eyeWhitePaint);

        // Con ngươi to đen láy
        canvas.drawCircle(leftEyePos, eyeRadius * 0.62, pupilPaint);
        canvas.drawCircle(rightEyePos, eyeRadius * 0.62, pupilPaint);

        // Điểm bắt sáng trắng (catchlight)
        final catchlightRadius = eyeRadius * 0.24;
        canvas.drawCircle(
          Offset(leftEyePos.dx - eyeRadius * 0.22, leftEyePos.dy - eyeRadius * 0.22),
          catchlightRadius,
          eyeWhitePaint,
        );
        canvas.drawCircle(
          Offset(rightEyePos.dx - eyeRadius * 0.22, rightEyePos.dy - eyeRadius * 0.22),
          catchlightRadius,
          eyeWhitePaint,
        );

        // Miệng cười mỉm hiền từ
        final smilePath = Path()
          ..moveTo(center.dx - radius * 0.16, center.dy + radius * 0.26)
          ..quadraticBezierTo(
            center.dx,
            center.dy + radius * 0.35,
            center.dx + radius * 0.16,
            center.dy + radius * 0.26,
          );
        canvas.drawPath(smilePath, strokePaint);
        break;
    }
  }

  void _drawArchEye(Canvas canvas, Offset pos, double r, Paint paint) {
    final path = Path()
      ..moveTo(pos.dx - r, pos.dy + r * 0.2)
      ..quadraticBezierTo(pos.dx, pos.dy - r * 0.8, pos.dx + r, pos.dy + r * 0.2);
    canvas.drawPath(path, paint);
  }

  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  bool shouldRepaint(covariant _SootPainter oldDelegate) {
    return oldDelegate.prevMood != prevMood ||
        oldDelegate.targetMood != targetMood ||
        oldDelegate.transitionProgress != transitionProgress ||
        oldDelegate.bodyColor != bodyColor ||
        oldDelegate.idleProgress != idleProgress;
  }
}
