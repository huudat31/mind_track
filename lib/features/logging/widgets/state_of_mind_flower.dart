import 'dart:math' as math;
import 'package:flutter/material.dart';

class StateOfMindFlower extends StatelessWidget {
  final double moodValue; // 0.0 (Rất khó chịu) -> 1.0 (Rất dễ chịu)
  final Color accentColor;
  final double pulseAnimation; // 0.0 -> 1.0 for subtle breathing

  const StateOfMindFlower({
    super.key,
    required this.moodValue,
    required this.accentColor,
    this.pulseAnimation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(280, 280),
      painter: _FlowerPainter(
        moodValue: moodValue,
        accentColor: accentColor,
        pulse: pulseAnimation,
      ),
    );
  }
}

class _FlowerPainter extends CustomPainter {
  final double moodValue;
  final Color accentColor;
  final double pulse;

  _FlowerPainter({
    required this.moodValue,
    required this.accentColor,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width / 2) * 0.92;

    // Calculate dynamic geometry based on mood value:
    // 0.0: 10-12 sharp spiky star (Very unpleasant)
    // 0.33: 8 wavy ripple lobes (Slightly unpleasant)
    // 0.5: 6 soft lobes (Neutral)
    // 0.66: 5 soft rounded pentagon (Slightly pleasant)
    // 0.83: 5 golden star petals (Pleasant)
    // 1.0: 5 blooming rounded petals (Very pleasant)
    final double petals;
    final double sharpness; // indentation
    final double roundness; // sharpness factor

    if (moodValue < 0.25) {
      // Rất khó chịu: 10 sharp points
      final t = moodValue / 0.25;
      petals = 10.0;
      sharpness = 0.40 - (0.05 * t);
      roundness = 2.8;
    } else if (moodValue < 0.5) {
      // Hơi khó chịu: 8 wavy lobes
      final t = (moodValue - 0.25) / 0.25;
      petals = 10.0 - (2.0 * t);
      sharpness = 0.32 - (0.07 * t);
      roundness = 1.6;
    } else if (moodValue < 0.75) {
      // Hơi dễ chịu: 5 rounded lobes
      final t = (moodValue - 0.5) / 0.25;
      petals = 8.0 - (3.0 * t);
      sharpness = 0.25 - (0.05 * t);
      roundness = 1.2;
    } else {
      // Dễ chịu -> Rất dễ chịu: 5 blooming petals
      petals = 5.0;
      sharpness = 0.22 + (0.06 * (moodValue - 0.75) / 0.25);
      roundness = 1.0;
    }

    // Breathing pulse scale
    final pulseScale = 1.0 + (0.025 * math.sin(pulse * 2 * math.pi));

    // Layer 1: Outermost glowing aura
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: 0.28),
          accentColor.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.2, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 1.15));
    canvas.drawCircle(center, maxRadius * 1.15 * pulseScale, auraPaint);

    // Render 4 concentric translucent glassmorphic layers
    final layers = [
      _LayerConfig(scale: 1.00 * pulseScale, fillAlpha: 0.18, strokeAlpha: 0.85, strokeWidth: 2.0),
      _LayerConfig(scale: 0.82 * pulseScale, fillAlpha: 0.32, strokeAlpha: 0.75, strokeWidth: 1.8),
      _LayerConfig(scale: 0.62 * pulseScale, fillAlpha: 0.55, strokeAlpha: 0.85, strokeWidth: 1.6),
      _LayerConfig(scale: 0.40 * pulseScale, fillAlpha: 0.78, strokeAlpha: 0.95, strokeWidth: 1.4),
      _LayerConfig(scale: 0.20 * pulseScale, fillAlpha: 0.95, strokeAlpha: 1.00, strokeWidth: 1.2),
    ];

    for (final layer in layers) {
      final path = _createFlowerPath(
        center: center,
        radius: maxRadius * layer.scale,
        petals: petals,
        sharpness: sharpness,
        roundness: roundness,
      );

      // Layer fill with radial gradient
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            Color.lerp(Colors.white, accentColor, 0.25)!.withValues(alpha: layer.fillAlpha * 0.9),
            accentColor.withValues(alpha: layer.fillAlpha * 0.55),
            accentColor.withValues(alpha: layer.fillAlpha * 0.2),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: maxRadius * layer.scale));

      canvas.drawPath(path, fillPaint);

      // Glass rim stroke (lớp viền thủy tinh phát sáng)
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = layer.strokeWidth
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: layer.strokeAlpha),
            accentColor.withValues(alpha: layer.strokeAlpha * 0.7),
          ],
          stops: const [0.6, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: maxRadius * layer.scale));

      canvas.drawPath(path, strokePaint);
    }

    // Center core dot
    final corePaint = Paint()
      ..color = Color.lerp(Colors.white, accentColor, 0.3)!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5.5, corePaint);
  }

  Path _createFlowerPath({
    required Offset center,
    required double radius,
    required double petals,
    required double sharpness,
    required double roundness,
  }) {
    final path = Path();
    const steps = 180;

    for (int i = 0; i <= steps; i++) {
      final theta = (i / steps) * 2 * math.pi;
      // Superformula / Cosine harmonic variation
      final harmonic = math.cos(petals * theta);
      final rDelta = math.pow(harmonic.abs(), 1.0 / roundness) * harmonic.sign;
      final r = radius * (1.0 + (sharpness * rDelta));

      final x = center.dx + r * math.cos(theta - math.pi / 2);
      final y = center.dy + r * math.sin(theta - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _FlowerPainter oldDelegate) {
    return oldDelegate.moodValue != moodValue ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.pulse != pulse;
  }
}

class _LayerConfig {
  final double scale;
  final double fillAlpha;
  final double strokeAlpha;
  final double strokeWidth;

  const _LayerConfig({
    required this.scale,
    required this.fillAlpha,
    required this.strokeAlpha,
    required this.strokeWidth,
  });
}
