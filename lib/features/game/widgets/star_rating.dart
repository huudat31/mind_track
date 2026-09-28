import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int stars; // 0 - 3
  final double size;
  final bool animate;

  const StarRating({
    super.key,
    required this.stars,
    this.size = 28,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = stars.clamp(0, 3);
    const totalStars = 3;

    return Semantics(
      label: 'Đạt $clamped trên 3 sao',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalStars, (index) {
          final isFilled = index < clamped;
          final starWidget = Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: isFilled ? const Color(0xFFF4A261) : const Color(0xFFCBD5E1),
          );

          if (!animate) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: starWidget,
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + index * 150),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: starWidget,
            ),
          );
        }),
      ),
    );
  }
}
