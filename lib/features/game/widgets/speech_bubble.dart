import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

enum BubbleTailPosition { left, right, bottom, none }

/// Bong bóng thoại trò chuyện của Muội Đen hoặc người dẫn đường.
/// Hỗ trợ bật/tắt typewriter effect, điều chỉnh tốc độ, và đuôi bong bóng vector.
class SpeechBubble extends StatefulWidget {
  final String text;
  final String? speakerName;
  final bool enableTypewriter;
  final Duration charDuration;
  final VoidCallback? onTypingFinished;
  final BubbleTailPosition tailPosition;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsets padding;

  const SpeechBubble({
    super.key,
    required this.text,
    this.speakerName,
    this.enableTypewriter = true,
    this.charDuration = const Duration(milliseconds: 25),
    this.onTypingFinished,
    this.tailPosition = BubbleTailPosition.bottom,
    this.backgroundColor = Colors.white,
    this.textColor = AppColors.textPrimary,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
  });

  @override
  State<SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends State<SpeechBubble> {
  Timer? _timer;
  int _charIndex = 0;
  late String _displayedText;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _displayedText = widget.enableTypewriter ? '' : widget.text;
    _charIndex = widget.enableTypewriter ? 0 : widget.text.length;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasStarted) {
      _hasStarted = true;
      _startTypewriterIfNeeded();
    }
  }

  @override
  void didUpdateWidget(covariant SpeechBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      _startTypewriterIfNeeded();
    }
  }

  void _startTypewriterIfNeeded() {
    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!widget.enableTypewriter || disableAnim || widget.text.isEmpty) {
      setState(() {
        _displayedText = widget.text;
        _charIndex = widget.text.length;
      });
      widget.onTypingFinished?.call();
      return;
    }

    setState(() {
      _displayedText = '';
      _charIndex = 0;
    });
    _timer = Timer.periodic(widget.charDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charIndex < widget.text.length) {
        setState(() {
          _charIndex++;
          _displayedText = widget.text.substring(0, _charIndex);
        });
      } else {
        timer.cancel();
        widget.onTypingFinished?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.speakerName != null
          ? '${widget.speakerName} nói: ${widget.text}'
          : widget.text,
      child: CustomPaint(
        painter: _BubbleTailPainter(
          tailPosition: widget.tailPosition,
          color: widget.backgroundColor,
          borderColor: AppColors.border,
        ),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.speakerName != null) ...[
                Text(
                  widget.speakerName!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                widget.enableTypewriter ? _displayedText : widget.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: widget.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final BubbleTailPosition tailPosition;
  final Color color;
  final Color borderColor;

  _BubbleTailPainter({
    required this.tailPosition,
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (tailPosition == BubbleTailPosition.none) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final borderPath = Path();

    if (tailPosition == BubbleTailPosition.bottom) {
      final centerX = size.width * 0.45;
      final bottomY = size.height;
      path.moveTo(centerX - 10, bottomY);
      path.lineTo(centerX, bottomY + 8);
      path.lineTo(centerX + 10, bottomY);
      path.close();

      borderPath.moveTo(centerX - 10, bottomY);
      borderPath.lineTo(centerX, bottomY + 8);
      borderPath.lineTo(centerX + 10, bottomY);
    } else if (tailPosition == BubbleTailPosition.left) {
      final centerY = size.height * 0.5;
      path.moveTo(0, centerY - 8);
      path.lineTo(-8, centerY);
      path.lineTo(0, centerY + 8);
      path.close();

      borderPath.moveTo(0, centerY - 8);
      borderPath.lineTo(-8, centerY);
      borderPath.lineTo(0, centerY + 8);
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) {
    return oldDelegate.tailPosition != tailPosition ||
        oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor;
  }
}
