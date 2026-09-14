import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/state_of_mind_flower.dart';
import 'daily_logging_screen.dart';

class StateOfMindScreen extends StatefulWidget {
  const StateOfMindScreen({super.key});

  @override
  State<StateOfMindScreen> createState() => _StateOfMindScreenState();
}

class _StateOfMindScreenState extends State<StateOfMindScreen>
    with SingleTickerProviderStateMixin {
  double _sliderValue = 0.5; // 0.0 -> 1.0
  late AnimationController _pulseController;
  int _lastVibratedIndex = 3;

  final List<_MoodTier> _tiers = const [
    _MoodTier(
      threshold: 0.08,
      label: 'Rất khó chịu',
      accentColor: Color(0xFF7D54BA),
      bgCenter: Color(0xFF2E1C44),
      bgEdge: Color(0xFF181122),
    ),
    _MoodTier(
      threshold: 0.25,
      label: 'Khó chịu',
      accentColor: Color(0xFF4E6DC9),
      bgCenter: Color(0xFF1D2647),
      bgEdge: Color(0xFF121626),
    ),
    _MoodTier(
      threshold: 0.42,
      label: 'Hơi khó chịu',
      accentColor: Color(0xFF288CD6),
      bgCenter: Color(0xFF192F4A),
      bgEdge: Color(0xFF101C2B),
    ),
    _MoodTier(
      threshold: 0.58,
      label: 'Bình thường',
      accentColor: Color(0xFF439A86),
      bgCenter: Color(0xFF1A332E),
      bgEdge: Color(0xFF11201D),
    ),
    _MoodTier(
      threshold: 0.75,
      label: 'Hơi dễ chịu',
      accentColor: Color(0xFF4CA04B),
      bgCenter: Color(0xFF203820),
      bgEdge: Color(0xFF142414),
    ),
    _MoodTier(
      threshold: 0.92,
      label: 'Dễ chịu',
      accentColor: Color(0xFFD6A018),
      bgCenter: Color(0xFF383216),
      bgEdge: Color(0xFF221E0E),
    ),
    _MoodTier(
      threshold: 1.00,
      label: 'Rất dễ chịu',
      accentColor: Color(0xFFEB6834),
      bgCenter: Color(0xFF3D2116),
      bgEdge: Color(0xFF24140E),
    ),
  ];

  _MoodTier get _currentTier {
    for (final tier in _tiers) {
      if (_sliderValue <= tier.threshold) {
        return tier;
      }
    }
    return _tiers.last;
  }

  int get _currentTierIndex {
    for (int i = 0; i < _tiers.length; i++) {
      if (_sliderValue <= _tiers[i].threshold) {
        return i;
      }
    }
    return _tiers.length - 1;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;
    });

    final newIndex = _currentTierIndex;
    if (newIndex != _lastVibratedIndex) {
      _lastVibratedIndex = newIndex;
      HapticFeedback.selectionClick();
    }
  }

  void _onNext() {
    // Điều hướng sang bước 2: Ghi nhận ngữ cảnh, Cờ đỏ lâm sàng & Nhật ký CBT
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyLoggingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tier = _currentTier;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.15),
            radius: 1.1,
            colors: [
              tier.bgCenter,
              tier.bgEdge,
            ],
            stops: const [0.25, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with circular buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.maybePop(context),
                    ),
                    const Text(
                      'Cảm xúc',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _buildCircleButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.maybePop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Chọn cảm giác của bạn\nngay lúc này',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),

              // Center Visual: State of Mind Flower with pulsing animation
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return StateOfMindFlower(
                        moodValue: _sliderValue,
                        accentColor: tier.accentColor,
                        pulseAnimation: _pulseController.value,
                      );
                    },
                  ),
                ),
              ),

              // Mood Label
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  tier.label,
                  key: ValueKey(tier.label),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Custom Mood Slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildCustomSlider(tier.accentColor),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RẤT KHÓ CHỊU',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'RẤT DỄ CHỊU',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bottom Button: "Tiếp"
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    decoration: BoxDecoration(
                      color: tier.accentColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: tier.accentColor.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Tiếp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomSlider(Color accentColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        const trackHeight = 36.0;
        const thumbDiameter = 32.0;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPos = box.globalToLocal(details.globalPosition);
            final newValue = (localPos.dx / trackWidth).clamp(0.0, 1.0);
            _onSliderChanged(newValue);
          },
          onTapDown: (details) {
            final newValue = (details.localPosition.dx / trackWidth).clamp(0.0, 1.0);
            _onSliderChanged(newValue);
          },
          child: Container(
            height: trackHeight,
            width: trackWidth,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(trackHeight / 2),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Thumb circle
                Positioned(
                  left: (_sliderValue * (trackWidth - thumbDiameter - 4)) + 2,
                  child: Container(
                    width: thumbDiameter,
                    height: thumbDiameter,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _MoodTier {
  final double threshold;
  final String label;
  final Color accentColor;
  final Color bgCenter;
  final Color bgEdge;

  const _MoodTier({
    required this.threshold,
    required this.label,
    required this.accentColor,
    required this.bgCenter,
    required this.bgEdge,
  });
}
