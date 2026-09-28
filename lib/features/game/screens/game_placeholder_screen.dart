import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/game_level.dart';
import '../progress/game_progress_provider.dart';
import '../widgets/game_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Màn hình tạm thời cho các mini-game đang trong tiến trình xây dựng.
/// Cung cấp nút hoàn thành thử để kiểm thử toàn diện luồng mở khóa màn chơi.
class GamePlaceholderScreen extends ConsumerWidget {
  final GameLevel level;

  const GamePlaceholderScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GameScaffold(
      title: level.title,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                level.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                level.description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(gameProgressProvider.notifier).markCompleted(
                        levelId: level.id,
                        score: 90,
                        stars: 3,
                      );
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Hoàn thành thử (Mở khóa tiếp)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
