import 'dart:math' as math;
import 'package:flutter/material.dart';

class StateOfMindFlower extends StatelessWidget {
  final double moodValue; // 0.0 (Rất khó chịu) -> 1.0 (Rất dễ chịu)
  final Color accentColor;
  final double pulseAnimation; // 0.0 -> 1.0 for subtle breathing pulse

  const StateOfMindFlower({
    super.key,
    required this.moodValue,
    required this.accentColor,
    this.pulseAnimation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(250, 250),
      painter: _AppleStateOfMindPainter(
        moodValue: moodValue.clamp(0.0, 1.0),
        accentColor: accentColor,
        pulse: pulseAnimation,
      ),
    );
  }
}

class _AppleStateOfMindPainter extends CustomPainter {
  final double moodValue;
  final Color accentColor;
  final double pulse;

  _AppleStateOfMindPainter({
    required this.moodValue,
    required this.accentColor,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (size.width / 2) * 0.88;

    // Subtle gentle breathing pulse (1.0 -> 1.03)
    final pulseScale = 1.0 + (0.025 * math.sin(pulse * 2 * math.pi));

    // Outer ambient glowing aura
    final auraRadius = baseRadius * 1.15 * pulseScale;
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: 0.35),
          accentColor.withValues(alpha: 0.12),
          Colors.transparent,
        ],
        stops: const [0.25, 0.70, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: auraRadius));
    canvas.drawCircle(center, auraRadius, auraPaint);

    // Apple Health shape layers (Concentric glass outlines & fills)
    // We draw 4 concentric layers from outside in:
    // Scale 1.0 (outermost rim)
    // Scale 0.80 (middle rim)
    // Scale 0.60 (inner rim)
    // Scale 0.40 (core glow)
    final layerConfigs = [
      _FlowerLayer(scale: 1.00 * pulseScale, fillAlpha: 0.14, strokeAlpha: 0.90, strokeWidth: 2.0),
      _FlowerLayer(scale: 0.80 * pulseScale, fillAlpha: 0.24, strokeAlpha: 0.85, strokeWidth: 1.8),
      _FlowerLayer(scale: 0.58 * pulseScale, fillAlpha: 0.42, strokeAlpha: 0.95, strokeWidth: 1.6),
      _FlowerLayer(scale: 0.38 * pulseScale, fillAlpha: 0.70, strokeAlpha: 1.00, strokeWidth: 1.4),
    ];

    for (final layer in layerConfigs) {
      final path = _computeClosedPath(
        center: center,
        radius: baseRadius * layer.scale,
        mood: moodValue,
      );

      // Layer 1: Translucent frosted glass fill with radial gradient
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            Color.lerp(Colors.white, accentColor, 0.35)!.withValues(alpha: layer.fillAlpha * 0.95),
            accentColor.withValues(alpha: layer.fillAlpha * 0.65),
            accentColor.withValues(alpha: layer.fillAlpha * 0.20),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: baseRadius * layer.scale));

      canvas.drawPath(path, fillPaint);

      // Layer 2: Glass rim highlight stroke (sáng viền thủy tinh mờ)
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = layer.strokeWidth
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: layer.strokeAlpha),
            Color.lerp(Colors.white, accentColor, 0.5)!.withValues(alpha: layer.strokeAlpha * 0.85),
            accentColor.withValues(alpha: layer.strokeAlpha * 0.6),
          ],
          stops: const [0.5, 0.85, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: baseRadius * layer.scale));

      canvas.drawPath(path, strokePaint);
    }

    // Glowing center core pin (chấm sáng nhỏ ở tâm như Apple Health)
    final coreGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.9),
          accentColor.withValues(alpha: 0.6),
          Colors.transparent,
        ],
        stops: const [0.2, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 14));
    canvas.drawCircle(center, 14, coreGlowPaint);

    final corePinPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.5, corePinPaint);
  }

  /// Calculates a continuous, perfectly closed polar loop (Zero seams / Zero knife slice)
  /// using seamless trigonometric functions for all 7 mood stages.
  Path _computeClosedPath({
    required Offset center,
    required double radius,
    required double mood,
  }) {
    final path = Path();
    const int steps = 240;

    for (int i = 0; i <= steps; i++) {
      final double theta = (i / steps) * 2 * math.pi;
      final double r = _getRadialDistance(theta, mood) * radius;

      // Rotate -90 degrees so top petal is upright
      final double angle = theta - (math.pi / 2);
      final double x = center.dx + (r * math.cos(angle));
      final double y = center.dy + (r * math.sin(angle));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  /// Evaluates normalized radius r(theta) for theta in [0, 2*pi].
  /// Guaranteed r(0) == r(2*pi) for any mood value because all harmonics
  /// use integer multiples of theta!
  double _getRadialDistance(double theta, double mood) {
    // 7 Mood checkpoints:
    // 0.00: Rất khó chịu (10 sharp spiky petals, violet)
    // 0.17: Khó chịu (8 sharp pointed lobes, deep indigo)
    // 0.33: Hơi khó chịu (8 soft rippling waves, ocean blue - Image 2)
    // 0.50: Bình thường (6 soft undulating lobes, teal)
    // 0.67: Hơi dễ chịu (5 rounded pentagon curves, green - Image 4)
    // 0.83: Dễ chịu (5 soft golden star curves, gold - Image 3)
    // 1.00: Rất dễ chịu (5 blooming rounded cherry blossom petals, coral orange - Image 5)

    final List<double> checkpoints = [0.0, 0.17, 0.33, 0.50, 0.67, 0.83, 1.0];

    // Find the two adjacent checkpoints for linear interpolation
    int index = 0;
    while (index < checkpoints.length - 2 && mood > checkpoints[index + 1]) {
      index++;
    }

    final t0 = checkpoints[index];
    final t1 = checkpoints[index + 1];
    final alpha = ((mood - t0) / (t1 - t0)).clamp(0.0, 1.0);

    final rA = _getTierRadius(index, theta);
    final rB = _getTierRadius(index + 1, theta);

    return (1.0 - alpha) * rA + (alpha * rB);
  }

  double _getTierRadius(int tier, double theta) {
    switch (tier) {
      case 0:
        // Tier 0: "Rất khó chịu" (10 sharp pointed petals, like Image 1)
        // Uses cos(10*theta) and cos(20*theta) for sharp faceted petals
        return 0.82 + (0.28 * math.cos(10 * theta)) - (0.06 * math.cos(20 * theta));

      case 1:
        // Tier 1: "Khó chịu" (8 pointed lobes)
        return 0.86 + (0.22 * math.cos(8 * theta)) - (0.04 * math.cos(16 * theta));

      case 2:
        // Tier 2: "Hơi khó chịu" (8 soft rippling waves, exactly Image 2)
        return 0.90 + (0.16 * math.cos(8 * theta));

      case 3:
        // Tier 3: "Bình thường" (6 soft lobes)
        return 0.92 + (0.13 * math.cos(6 * theta));

      case 4:
        // Tier 4: "Hơi dễ chịu" (5 rounded pentagon curves, exactly Image 4)
        return 0.93 + (0.15 * math.cos(5 * theta)) - (0.03 * math.cos(10 * theta));

      case 5:
        // Tier 5: "Dễ chịu" (5 soft golden star curves, exactly Image 3)
        return 0.88 + (0.24 * math.cos(5 * theta)) + (0.05 * math.cos(10 * theta));

      case 6:
      default:
        // Tier 6: "Rất dễ chịu" (5 blooming rounded cherry blossom petals, exactly Image 5)
        return 0.84 + (0.28 * math.cos(5 * theta)) - (0.10 * math.cos(10 * theta));
    }
  }

  @override
  bool shouldRepaint(covariant _AppleStateOfMindPainter oldDelegate) {
    return oldDelegate.moodValue != moodValue ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.pulse != pulse;
  }
}

class _FlowerLayer {
  final double scale;
  final double fillAlpha;
  final double strokeAlpha;
  final double strokeWidth;

  const _FlowerLayer({
    required this.scale,
    required this.fillAlpha,
    required this.strokeAlpha,
    required this.strokeWidth,
  });
}
