import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../constants/game_strings.dart';
import '../mini_games/breathing_game/screens/breathing_game_screen.dart';
import '../mini_games/distortion_game/screens/distortion_game_screen.dart';
import '../mini_games/evidence_game/screens/evidence_game_screen.dart';
import '../models/game_level.dart';
import '../models/game_skill.dart';
import '../models/level_progress.dart';
import '../progress/game_progress_provider.dart';
import '../story/screens/story_screen.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/muoi_den_widget.dart';
import '../widgets/speech_bubble.dart';
import '../widgets/star_rating.dart';
import 'game_placeholder_screen.dart';

class GameHubScreen extends ConsumerWidget {
  final Widget Function(GameLevel level)? screenBuilderOverride;

  const GameHubScreen({super.key, this.screenBuilderOverride});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(gameProgressProvider);

    return GameScaffold(
      title: GameStrings.gameTitle,
      body: progressAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text(
            'Không thể tải tiến trình: $err',
            style: const TextStyle(color: AppColors.accentCoral),
          ),
        ),
        data: (progressMap) {
          final totalStars = progressMap.values.fold<int>(
            0,
            (sum, p) => sum + p.stars,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              // Companion Section: Muội Đen và Lời dặn dò
              _buildCompanionHeader(totalStars),
              const SizedBox(height: 16),

              // Story Mode Entry
              _buildStoryModeBanner(context),
              const SizedBox(height: 24),

              // Road Map Title
              Row(
                children: [
                  const Icon(
                    Icons.route_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    GameStrings.journeyMap,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Journey Path Nodes
              ...List.generate(GameLevel.defaultLevels.length, (index) {
                final level = GameLevel.defaultLevels[index];
                final progress = progressMap[level.id] ??
                    LevelProgress.initial(level.id, isUnlocked: index == 0);
                final isLast = index == GameLevel.defaultLevels.length - 1;

                return _buildJourneyNode(
                  context: context,
                  level: level,
                  progress: progress,
                  isLast: isLast,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompanionHeader(int totalStars) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MuoiDenWidget(mood: SootMood.happy, size: 76),
              const SizedBox(width: 14),
              const Expanded(
                child: SpeechBubble(
                  speakerName: GameStrings.sootName,
                  text:
                      'Chào bạn! Mình sẽ cùng bạn đi qua từng thử thách để hiểu hơn về tâm trí nhé!',
                  enableTypewriter: false,
                  tailPosition: BubbleTailPosition.left,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Tổng sao đã tích lũy:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 20, color: Color(0xFFF4A261)),
                  const SizedBox(width: 4),
                  Text(
                    '$totalStars / 9',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryModeBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cốt Truyện Đồng Hành',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vượt qua áp lực thi cử cùng Muội Đen',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoryScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Bắt đầu',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyNode({
    required BuildContext context,
    required GameLevel level,
    required LevelProgress progress,
    required bool isLast,
  }) {
    final isLocked = progress.isLocked;
    final isCompleted = progress.isCompleted;

    IconData nodeIcon;
    switch (level.skillId) {
      case SkillId.breathing:
        nodeIcon = Icons.air_rounded;
        break;
      case SkillId.distortionSpotting:
        nodeIcon = Icons.psychology_alt_rounded;
        break;
      case SkillId.evidenceScale:
        nodeIcon = Icons.balance_rounded;
        break;
    }

    final cardBgColor = isLocked ? AppColors.surfaceMuted : Colors.white;
    final borderColor = isLocked
        ? AppColors.border
        : (isCompleted ? const Color(0xFF86EFAC) : AppColors.primaryLight);

    return Column(
      children: [
        Semantics(
          button: true,
          label: '${level.title}, ${isLocked ? GameStrings.levelStatusLocked : (isCompleted ? GameStrings.levelStatusCompleted : GameStrings.levelStatusUnlocked)}',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (isLocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          const Expanded(child: Text(GameStrings.lockedLevelMessage)),
                        ],
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                } else {
                  final Widget targetScreen;
                  if (screenBuilderOverride != null) {
                    targetScreen = screenBuilderOverride!(level);
                  } else if (level.skillId == SkillId.breathing) {
                    targetScreen = const BreathingGameScreen();
                  } else if (level.skillId == SkillId.distortionSpotting) {
                    targetScreen = const DistortionGameScreen();
                  } else if (level.skillId == SkillId.evidenceScale) {
                    targetScreen = const EvidenceGameScreen();
                  } else {
                    targetScreen = GamePlaceholderScreen(level: level);
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => targetScreen),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1.4),
                  boxShadow: [
                    if (!isLocked)
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    // Node Avatar Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isLocked
                            ? AppColors.border
                            : (isCompleted
                                ? const Color(0xFFDCFCE7)
                                : AppColors.primary.withValues(alpha: 0.14)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLocked ? Icons.lock_rounded : nodeIcon,
                        size: 26,
                        color: isLocked
                            ? AppColors.textMuted
                            : (isCompleted ? const Color(0xFF16A34A) : AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Level Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isLocked ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            level.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isLocked ? AppColors.textMuted : AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                          if (!isLocked) ...[
                            const SizedBox(height: 6),
                            StarRating(stars: progress.stars, size: 16),
                          ],
                        ],
                      ),
                    ),

                    // Trailing Action Icon
                    Icon(
                      isLocked ? Icons.lock_outline_rounded : Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: isLocked ? AppColors.textMuted : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Đường nối giữa các node (Timeline road path)
        if (!isLast)
          Container(
            width: 3,
            height: 24,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFF86EFAC) : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}
