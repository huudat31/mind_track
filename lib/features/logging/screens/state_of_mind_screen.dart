import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/supabase_clinical_service.dart';
import '../../../core/widgets/hotline_dialog.dart';
import '../models/daily_log_model.dart';
import '../widgets/state_of_mind_flower.dart';

class StateOfMindScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  const StateOfMindScreen({super.key, this.onBack, this.onClose});

  @override
  State<StateOfMindScreen> createState() => _StateOfMindScreenState();
}

class _StateOfMindScreenState extends State<StateOfMindScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep =
      0; // 0: Cảm xúc, 1: Năng lượng & Cờ đỏ, 2: Tổng kết & Nhật ký

  double _sliderValue = 0.67; // Mặc định: "Hơi dễ chịu"
  late AnimationController _pulseController;
  int _lastVibratedIndex = 4;

  // Step 2 state:
  double _energyLevel = 3.0; // 1.0 -> 5.0
  final Set<String> _selectedFlags = {};
  final Set<String> _selectedTags = {'Công việc'};

  // Step 3 state:
  final TextEditingController _eventController = TextEditingController();
  final TextEditingController _thoughtController = TextEditingController();
  final TextEditingController _balancedController = TextEditingController();
  bool _showCrisisBanner = false;

  final List<String> _availableTags = [
    'Công việc',
    'Học tập',
    'Gia đình',
    'Tình cảm',
    'Bạn bè',
    'Sức khỏe',
    'Tài chính',
    'Một mình',
  ];

  final List<String> _crisisKeywords = [
    'tự tử',
    'tự hại',
    'muốn chết',
    'chết đi',
    'kết thúc cuộc sống',
    'không muốn sống',
    'hết hy vọng',
  ];

  final List<_MoodTier> _tiers = const [
    _MoodTier(
      threshold: 0.08,
      label: 'Rất khó chịu',
      accentColor: Color(0xFF7D54BA),
      bgCenter: Color(0xFFF3ECFA),
      bgEdge: Color(0xFFFAF9F6),
    ),
    _MoodTier(
      threshold: 0.25,
      label: 'Khó chịu',
      accentColor: Color(0xFF4E6DC9),
      bgCenter: Color(0xFFEFF6FF),
      bgEdge: Color(0xFFFAF9F6),
    ),
    _MoodTier(
      threshold: 0.42,
      label: 'Hơi khó chịu',
      accentColor: Color(0xFF288CD6),
      bgCenter: Color(0xFFF0F9FF),
      bgEdge: Color(0xFFFAF9F6),
    ),
    _MoodTier(
      threshold: 0.58,
      label: 'Bình thường',
      accentColor: Color(0xFF439A86),
      bgCenter: Color(0xFFECFDF5),
      bgEdge: Color(0xFFFAF9F6),
    ),
    _MoodTier(
      threshold: 0.75,
      label: 'Hơi dễ chịu',
      accentColor: Color(0xFF4CA04B),
      bgCenter: Color(0xFFF0FDFA),
      bgEdge: Color(0xFFFAF9F6),
    ),
    _MoodTier(
      threshold: 0.92,
      label: 'Dễ chịu',
      accentColor: Color(0xFFD6A018),
      bgCenter: Color(0xFFFEF3C7),
      bgEdge: Color(0xFFFAF9F6),
    ),
    _MoodTier(
      threshold: 1.00,
      label: 'Rất dễ chịu',
      accentColor: Color(0xFFEB6834),
      bgCenter: Color(0xFFFFEDD5),
      bgEdge: Color(0xFFFAF9F6),
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
    _pageController.dispose();
    _eventController.dispose();
    _thoughtController.dispose();
    _balancedController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    } else {
      if (widget.onBack != null) {
        widget.onBack!();
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void _handleClose() {
    if (mounted) {
      setState(() {
        _currentStep = 0;
        _eventController.clear();
        _thoughtController.clear();
        _balancedController.clear();
        _selectedFlags.clear();
      });
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
    if (widget.onClose != null) {
      widget.onClose!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
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

  void _checkCrisisKeywords(String text) {
    final lower = text.toLowerCase();
    bool detected = false;
    for (final kw in _crisisKeywords) {
      if (lower.contains(kw)) {
        detected = true;
        break;
      }
    }
    if (detected != _showCrisisBanner) {
      setState(() {
        _showCrisisBanner = detected;
      });
    }
  }

  void _saveFinalLog() async {
    HapticFeedback.mediumImpact();

    final moodScore = (_sliderValue * 4).round() + 1;
    final success = await SupabaseClinicalService.saveDailyLog(
      moodScore: moodScore,
      valence: _sliderValue,
      energyLevel: _energyLevel,
      contextTags: _selectedTags,
      clinicalFlags: _selectedFlags,
      triggerEvent: _eventController.text.trim().isNotEmpty
          ? _eventController.text.trim()
          : null,
      automaticThought: _thoughtController.text.trim().isNotEmpty
          ? _thoughtController.text.trim()
          : null,
      balancedResponse: _balancedController.text.trim().isNotEmpty
          ? _balancedController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lưu ý: Dữ liệu chưa thể đồng bộ lên Supabase do bạn chưa kích hoạt Anonymous Auth hoặc chưa đăng nhập.'),
          backgroundColor: Color(0xFFE07A5F),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: _currentTier.accentColor,
              size: 26,
            ),
            const SizedBox(width: 10),
            const Text(
              'Ghi nhận thành công',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dữ liệu cảm xúc "${_currentTier.label}" và ${_selectedFlags.length} triệu chứng đã được lưu vào hồ sơ tự theo dõi.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                AppStrings.clinicalDisclaimer,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleClose();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentTier.accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hoàn tất'),
          ),
        ],
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
            center: const Alignment(0, -0.2),
            radius: 1.25,
            colors: [tier.bgCenter, tier.bgEdge],
            stops: const [0.25, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: _handleBack,
                    ),
                    Column(
                      children: [
                        const Text(
                          'Cảm xúc',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bước ${_currentStep + 1} / 3',
                          style: TextStyle(
                            color: tier.accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    _buildCircleButton(
                      icon: Icons.close_rounded,
                      onTap: _handleClose,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1Mood(tier),
                    _buildStep2EnergyAndFlags(tier),
                    _buildStep3SummaryAndJournal(tier),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1Mood(_MoodTier tier) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            'Chọn cảm giác của bạn\nngay lúc này',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ),
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            tier.label,
            key: ValueKey(tier.label),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 26),
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
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    'RẤT DỄ CHỊU',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _buildBottomButton(
          label: 'Tiếp tục',
          tier: tier,
          onTap: () => _goToStep(1),
        ),
      ],
    );
  }

  Widget _buildStep2EnergyAndFlags(_MoodTier tier) {
    final energyLabels = ['Cạn kiệt', 'Thấp', 'Bình ổn', 'Dồi dào', 'Tràn đầy'];
    final energyIndex = (_energyLevel.toInt() - 1).clamp(0, 4);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: tier.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: tier.accentColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tier.accentColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cảm xúc: ${tier.label}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Năng lượng & Dấu hiệu thực thể',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Chọn mức năng lượng và các phản ứng cơ thể bạn cảm nhận',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildGlassSection(
                tier: tier,
                title: 'Mức năng lượng cơ thể',
                trailing: Text(
                  '${_energyLevel.toInt()}/5 · ${energyLabels[energyIndex]}',
                  style: TextStyle(
                    color: tier.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        activeTrackColor: tier.accentColor,
                        inactiveTrackColor: AppColors.surfaceMuted,
                        thumbColor: Colors.white,
                        overlayColor: tier.accentColor.withValues(alpha: 0.25),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                      ),
                      child: Slider(
                        value: _energyLevel,
                        min: 1.0,
                        max: 5.0,
                        divisions: 4,
                        onChanged: (val) {
                          setState(() => _energyLevel = val);
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (i) {
                        final isCur = i == energyIndex;
                        return Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: isCur ? AppColors.textPrimary : AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: isCur
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildGlassSection(
                tier: tier,
                title: 'Cờ đỏ triệu chứng lâm sàng',
                trailing: Text(
                  '${_selectedFlags.length} đã chọn',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chạm nhanh các phản ứng bạn gặp hôm nay để hỗ trợ buổi làm việc với chuyên gia:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...ClinicalFlagsCatalog.categories.map((cat) {
                      final flagsInCat = ClinicalFlagsCatalog.allFlags
                          .where((f) => f.category == cat)
                          .toList();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat,
                              style: TextStyle(
                                color: tier.accentColor.withValues(alpha: 0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: flagsInCat.map((flag) {
                                final isSelected = _selectedFlags.contains(
                                  flag.id,
                                );
                                return _buildGlassChip(
                                  label: flag.name,
                                  icon: flag.icon,
                                  isSelected: isSelected,
                                  tier: tier,
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedFlags.remove(flag.id);
                                      } else {
                                        _selectedFlags.add(flag.id);
                                      }
                                    });
                                    HapticFeedback.selectionClick();
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildGlassSection(
                tier: tier,
                title: 'Ngữ cảnh kích hoạt',
                trailing: const SizedBox.shrink(),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return _buildGlassChip(
                      label: tag,
                      icon: Icons.tag_rounded,
                      isSelected: isSelected,
                      tier: tier,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedTags.remove(tag);
                          } else {
                            _selectedTags.add(tag);
                          }
                        });
                        HapticFeedback.selectionClick();
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        _buildBottomButton(
          label: 'Xem bản ghi nhận',
          tier: tier,
          onTap: () => _goToStep(2),
        ),
      ],
    );
  }

  Widget _buildStep3SummaryAndJournal(_MoodTier tier) {
    final selectedFlagNames = ClinicalFlagsCatalog.allFlags
        .where((f) => _selectedFlags.contains(f.id))
        .map((f) => f.name)
        .toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              const Text(
                'Bản Ghi Nhận Hôm Nay',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tổng hợp dữ liệu chuẩn bị cho bản báo cáo trước trị liệu',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: tier.accentColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.spa_rounded,
                                color: tier.accentColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CẢM XÚC CHỦ ĐẠO',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  tier.label,
                                  style: TextStyle(
                                    color: tier.accentColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            'Năng lượng: ${_energyLevel.toInt()}/5',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.border, height: 24),
                    const Text(
                      'Triệu chứng ghi nhận:',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (selectedFlagNames.isEmpty)
                      const Text(
                        '• Không ghi nhận triệu chứng bất thường',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: selectedFlagNames.map((name) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: tier.accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: tier.accentColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              '• $name',
                              style: TextStyle(
                                color: tier.accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ngữ cảnh liên quan:',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedTags.isEmpty
                          ? 'Không gắn tag'
                          : _selectedTags.join(' · '),
                      style: TextStyle(
                        color: tier.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _buildGlassSection(
                tier: tier,
                title: 'Nhật ký cân bằng (CBT 3 bước)',
                trailing: const Icon(
                  Icons.auto_stories_outlined,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dành 1-2 phút ghi lại sự việc để chuyên gia hiểu rõ bối cảnh:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildJournalTextField(
                      controller: _eventController,
                      label: '1. Sự việc gì vừa xảy ra?',
                      hint: 'Ví dụ: Deadline dồn dập, bất đồng quan điểm...',
                      tier: tier,
                    ),
                    const SizedBox(height: 14),
                    _buildJournalTextField(
                      controller: _thoughtController,
                      label: '2. Suy nghĩ đầu tiên nảy sinh?',
                      hint:
                          'Ví dụ: Mình sẽ không kịp làm, mọi thứ thật quá tải...',
                      tier: tier,
                    ),
                    const SizedBox(height: 14),
                    _buildJournalTextField(
                      controller: _balancedController,
                      label: '3. Góc nhìn cân bằng hoặc điều kiểm soát được?',
                      hint:
                          'Ví dụ: Mình có thể xin lùi hạn hoặc ưu tiên việc quan trọng trước...',
                      tier: tier,
                      isBalanced: true,
                    ),
                    if (_showCrisisBanner) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentCoral.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accentCoral.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              color: AppColors.accentCoral,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Có vẻ bạn đang trải qua cảm giác quá tải. Bạn có muốn gọi ai đó lắng nghe không?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => HotlineDialog.show(context),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.accentCoral,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              child: const Text(
                                'Hotline',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        _buildBottomButton(
          label: 'Hoàn tất & Lưu vào hồ sơ',
          tier: tier,
          onTap: _saveFinalLog,
        ),
      ],
    );
  }

  Widget _buildGlassSection({
    required _MoodTier tier,
    required String title,
    required Widget trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildGlassChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required _MoodTier tier,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? tier.accentColor.withValues(alpha: 0.12)
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? tier.accentColor
                : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tier.accentColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? tier.accentColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? tier.accentColor : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required _MoodTier tier,
    bool isBalanced = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isBalanced ? tier.accentColor : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isBalanced) ...[
              const SizedBox(width: 4),
              Icon(Icons.star_rounded, size: 14, color: tier.accentColor),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: _checkCrisisKeywords,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          maxLines: 2,
          minLines: 1,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
            filled: true,
            fillColor: AppColors.surfaceMuted,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: tier.accentColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton({
    required String label,
    required _MoodTier tier,
    required VoidCallback onTap,
  }) {
    final isInsideTab = widget.onBack != null || widget.onClose != null;
    final bottomPad = isInsideTab ? 88.0 : 20.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          decoration: BoxDecoration(
            color: tier.accentColor,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: tier.accentColor.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomSlider(Color accentColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        const totalHeight = 44.0;
        const trackHeight = 10.0;
        const thumbDiameter = 28.0;
        final thumbLeft = (_sliderValue * (trackWidth - thumbDiameter)).clamp(
          0.0,
          trackWidth - thumbDiameter,
        );
        final activeWidth = (thumbLeft + thumbDiameter / 2).clamp(
          0.0,
          trackWidth,
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPos = box.globalToLocal(details.globalPosition);
            final newValue = (localPos.dx / trackWidth).clamp(0.0, 1.0);
            _onSliderChanged(newValue);
          },
          onTapDown: (details) {
            final newValue = (details.localPosition.dx / trackWidth).clamp(
              0.0,
              1.0,
            );
            _onSliderChanged(newValue);
          },
          child: SizedBox(
            height: totalHeight,
            width: trackWidth,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Inactive base track
                Center(
                  child: Container(
                    height: trackHeight,
                    width: trackWidth,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(trackHeight / 2),
                    ),
                  ),
                ),

                // Active progress track (Exact same vibrant color as the button)
                Positioned(
                  left: 0,
                  top: (totalHeight - trackHeight) / 2,
                  child: Container(
                    height: trackHeight,
                    width: activeWidth,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(trackHeight / 2),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center neutral notch (0.5 - Bình thường)
                Positioned(
                  left: (trackWidth / 2) - 1.25,
                  top: (totalHeight - 14) / 2,
                  child: Container(
                    width: 2.5,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _sliderValue >= 0.5
                          ? Colors.white.withValues(alpha: 0.75)
                          : accentColor.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),

                // Tactile floating Apple-style knob
                Positioned(
                  left: thumbLeft,
                  top: (totalHeight - thumbDiameter) / 2,
                  child: Container(
                    width: thumbDiameter,
                    height: thumbDiameter,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.06),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
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
