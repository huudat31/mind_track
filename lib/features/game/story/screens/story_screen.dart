import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../mini_games/breathing_game/screens/breathing_game_screen.dart';
import '../../mini_games/distortion_game/screens/distortion_game_screen.dart';
import '../../mini_games/evidence_game/screens/evidence_game_screen.dart';
import '../controller/story_controller.dart';
import '../models/story_node.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/muoi_den_widget.dart';
import '../../widgets/speech_bubble.dart';

/// Màn hình dẫn dắt câu chuyện Story cùng Muội Đen
class StoryScreen extends ConsumerStatefulWidget {
  final String? assetPath;
  final String? directJson;

  const StoryScreen({
    super.key,
    this.assetPath,
    this.directJson,
  });

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  bool _isNavigatingToMinigame = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storyControllerProvider.notifier).loadStory(
            assetPath: widget.assetPath ?? 'assets/game/story/exam_01.json',
            jsonContent: widget.directJson,
            resume: true,
          );
    });
  }

  void _handleMinigameTrigger(String minigameType) async {
    if (_isNavigatingToMinigame) return;
    _isNavigatingToMinigame = true;

    Widget targetScreen;
    switch (minigameType) {
      case 'breathing':
        targetScreen = const BreathingGameScreen();
        break;
      case 'distortion':
        targetScreen = const DistortionGameScreen();
        break;
      case 'evidence':
        targetScreen = const EvidenceGameScreen();
        break;
      default:
        targetScreen = const BreathingGameScreen();
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => targetScreen),
    );

    if (mounted) {
      _isNavigatingToMinigame = false;
      ref.read(storyControllerProvider.notifier).completeMinigameAndContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyControllerProvider);

    // Lắng nghe trigger chuyển sang mini-game
    ref.listen(storyControllerProvider, (previous, next) {
      final pendingType = next.pendingMinigameType;
      if (pendingType != null && !_isNavigatingToMinigame) {
        _handleMinigameTrigger(pendingType);
      }
    });

    final currentNode = storyState.currentNode;
    final title = storyState.script?.title ?? 'Đồng hành cùng Muội Đen';

    return GameScaffold(
      title: title,
      onBack: () => Navigator.of(context).pop(),
      body: storyState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : storyState.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.accentCoral),
                        const SizedBox(height: 16),
                        Text(
                          storyState.errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.accentCoral,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => ref.read(storyControllerProvider.notifier).loadStory(
                                assetPath: widget.assetPath ?? 'assets/game/story/exam_01.json',
                                jsonContent: widget.directJson,
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : storyState.isCompleted
                  ? _buildCompletionView(context)
                  : _buildStoryContent(context, currentNode),
    );
  }

  Widget _buildStoryContent(BuildContext context, StoryNode? node) {
    if (node == null) return const SizedBox.shrink();

    final companionMood = node.mood.toSootMood();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Khu vực nhân vật Muội Đen
          Center(
            child: MuoiDenWidget(
              mood: companionMood,
              size: 110,
            ),
          ),
          const SizedBox(height: 14),

          // Lời thoại trong bóng đối thoại
          SpeechBubble(
            text: node.text,
            speakerName: node.speaker == 'muoi_den' ? 'Muội Đen' : 'Bạn',
            tailPosition: BubbleTailPosition.bottom,
          ),
          const SizedBox(height: 24),

          // Danh sách lựa chọn phản hồi
          if (node.choices.isNotEmpty) ...[
            Text(
              'Lựa chọn của bạn:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...node.choices.map((choice) => _buildChoiceButton(context, choice)),
          ],
        ],
      ),
    );
  }

  Widget _buildChoiceButton(BuildContext context, StoryChoice choice) {
    final isMinigame = choice.isMinigameTrigger;
    final buttonColor = isMinigame ? AppColors.primary : Colors.white;
    final textColor = isMinigame ? Colors.white : AppColors.textPrimary;
    final borderColor = isMinigame ? AppColors.primaryDark : AppColors.border;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: buttonColor,
        borderRadius: BorderRadius.circular(16),
        elevation: isMinigame ? 3 : 1,
        shadowColor: isMinigame ? AppColors.primary.withValues(alpha: 0.3) : Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ref.read(storyControllerProvider.notifier).selectChoice(choice);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Row(
              children: [
                if (isMinigame) ...[
                  const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    choice.text,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: isMinigame ? FontWeight.w700 : FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isMinigame ? Colors.white70 : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MuoiDenWidget(
                mood: SootMood.happy,
                size: 110,
              ),
              const SizedBox(height: 16),
              Text(
                'Hành Trình Hoàn Thành!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn đã hoàn thành kịch bản đồng hành tâm lý. Mỗi kỹ năng bạn luyện tập hôm nay là một bước đệm vững chắc cho sức khỏe tinh thần của bạn.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.map_rounded),
                  label: const Text('Về Bản Đồ Trò Chơi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => ref.read(storyControllerProvider.notifier).resetStory(),
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text('Trò chuyện lại từ đầu'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
