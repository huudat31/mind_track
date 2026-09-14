import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BoxBreathingScreen extends StatefulWidget {
  const BoxBreathingScreen({super.key});

  @override
  State<BoxBreathingScreen> createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _instructionText = 'Hít vào chậm rãi';
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    // 16 giây cho một chu kỳ Box Breathing (4s Hít - 4s Giữ - 4s Thở - 4s Giữ)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    _scaleAnimation = TweenSequence<double>([
      // 0 - 4s (0% - 25%): Hít vào -> phình to
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.45)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      // 4 - 8s (25% - 50%): Giữ hơi -> giữ kích thước
      TweenSequenceItem(
        tween: ConstantTween<double>(1.45),
        weight: 25,
      ),
      // 8 - 12s (50% - 75%): Thở ra -> thu nhỏ về ban đầu
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.45, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      // 12 - 16s (75% - 100%): Nín thở tĩnh -> giữ kích thước nhỏ
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 25,
      ),
    ]).animate(_controller);

    _controller.addListener(() {
      final value = _controller.value;
      setState(() {
        if (value < 0.25) {
          _instructionText = 'Hít vào (4s)';
        } else if (value < 0.50) {
          _instructionText = 'Nín thở & Giữ (4s)';
        } else if (value < 0.75) {
          _instructionText = 'Thở ra từ từ (4s)';
        } else {
          _instructionText = 'Thả lỏng tĩnh (4s)';
        }
      });
    });

    _controller.repeat();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thở vuông (Box Breathing)'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Kỹ thuật cân bằng hệ thần kinh 4-4-4-4',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 50),

              // Animated Breathing Circle
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryLight.withOpacity(0.5),
                            AppColors.primary.withOpacity(0.2),
                            Colors.transparent,
                          ],
                          stops: const [0.4, 0.75, 1.0],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.air_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 60),

              // Instruction Text
              Text(
                _instructionText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Theo nhịp chuyển động của vòng tròn',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 40),

              // Control button
              IconButton.filledTonal(
                onPressed: _togglePlay,
                iconSize: 32,
                icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.surfaceMuted,
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
