import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/game_skill.dart';
import 'game_scaffold.dart';
import 'muoi_den_widget.dart';
import 'result_dialog.dart';
import 'skill_unlocked_banner.dart';
import 'speech_bubble.dart';
import 'star_rating.dart';

/// Thư viện xem thử các Widget của Module Game.
/// Chỉ có thể truy cập hoặc hiển thị trong môi trường Debug (kDebugMode).
class GameWidgetGallery extends StatefulWidget {
  const GameWidgetGallery({super.key});

  @override
  State<GameWidgetGallery> createState() => _GameWidgetGalleryState();
}

class _GameWidgetGalleryState extends State<GameWidgetGallery> {
  SootMood _selectedMood = SootMood.calm;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Gallery chỉ khả dụng trong chế độ gỡ lỗi (kDebugMode)')),
      );
    }

    return GameScaffold(
      title: 'Game Widget Gallery',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('1. Nhân vật Muội Đen & Biểu cảm'),
          Center(
            child: MuoiDenWidget(
              mood: _selectedMood,
              size: 110,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: SootMood.values.map((mood) {
              final isSelected = mood == _selectedMood;
              return ChoiceChip(
                label: Text(mood.name),
                selected: isSelected,
                onSelected: (val) {
                  if (val) setState(() => _selectedMood = mood);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('2. Bong bóng hội thoại (SpeechBubble)'),
          const SpeechBubble(
            speakerName: 'Muội Đen',
            text: 'Chào bạn! Mình là Muội Đen. Hôm nay tâm trí bạn đang cảm thấy thế nào?',
            tailPosition: BubbleTailPosition.bottom,
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('3. Đánh giá sao (StarRating)'),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StarRating(stars: 1),
              StarRating(stars: 2),
              StarRating(stars: 3, animate: true),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('4. Banner mở khóa kỹ năng (SkillUnlockedBanner)'),
          const SkillUnlockedBanner(skillId: SkillId.distortionSpotting),
          const SizedBox(height: 24),

          _buildSectionHeader('5. Hộp thoại kết quả (ResultDialog)'),
          ElevatedButton(
            onPressed: () {
              ResultDialog.show(
                context: context,
                stars: 3,
                score: 92,
                onReplay: () {},
                onContinue: () {},
              );
            },
            child: const Text('Mở thử ResultDialog 3 sao'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
