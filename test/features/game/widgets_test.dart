import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/game/constants/game_strings.dart';
import 'package:mind_track/features/game/models/game_skill.dart';
import 'package:mind_track/features/game/widgets/game_scaffold.dart';
import 'package:mind_track/features/game/widgets/muoi_den_widget.dart';
import 'package:mind_track/features/game/widgets/skill_unlocked_banner.dart';
import 'package:mind_track/features/game/widgets/speech_bubble.dart';
import 'package:mind_track/features/game/widgets/star_rating.dart';

void main() {
  testWidgets('MuoiDenWidget renders all moods with appropriate Semantics',
      (WidgetTester tester) async {
    for (final mood in SootMood.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MuoiDenWidget(mood: mood, size: 80),
          ),
        ),
      );

      expect(find.byType(MuoiDenWidget), findsOneWidget);
      expect(find.bySemanticsLabel(mood.semanticLabel), findsOneWidget);
    }
  });

  testWidgets('SpeechBubble renders text and speakerName without typewriter animation in test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SpeechBubble(
            speakerName: 'Muội Đen',
            text: 'Xin chào người bạn mới!',
            enableTypewriter: false,
          ),
        ),
      ),
    );

    expect(find.text('Muội Đen'), findsOneWidget);
    expect(find.text('Xin chào người bạn mới!'), findsOneWidget);
  });

  testWidgets('StarRating displays correct filled and unfilled stars',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StarRating(stars: 2, animate: false),
        ),
      ),
    );

    expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(1));
  });

  testWidgets('SkillUnlockedBanner displays title and skill information',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SkillUnlockedBanner(skillId: SkillId.distortionSpotting),
        ),
      ),
    );

    expect(find.text(GameStrings.skillUnlockedTitle), findsOneWidget);
    expect(find.text(SkillId.distortionSpotting.title), findsOneWidget);
    expect(find.text(SkillId.distortionSpotting.description), findsOneWidget);
  });

  testWidgets('GameScaffold displays title, back button, and emergency hotline button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GameScaffold(
          title: 'Thử thách hơi thở',
          body: Center(child: Text('Nội dung game')),
        ),
      ),
    );

    expect(find.text('Thử thách hơi thở'), findsOneWidget);
    expect(find.text('Nội dung game'), findsOneWidget);
    expect(find.text(GameStrings.emergencySupport), findsOneWidget);
  });

  testWidgets('GameScaffold and widgets render cleanly at 360x640 with textScaler 1.3',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.3),
            size: Size(360, 640),
          ),
          child: GameScaffold(
            title: 'Màn chơi thử thách',
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const MuoiDenWidget(mood: SootMood.thinking, size: 80),
                  const SpeechBubble(
                    speakerName: 'Muội Đen',
                    text: 'Bài tập này giúp chúng mình nhận diện các góc nhìn.',
                    enableTypewriter: false,
                  ),
                  const SizedBox(height: 10),
                  const StarRating(stars: 3),
                  const SizedBox(height: 10),
                  const SkillUnlockedBanner(skillId: SkillId.breathing),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
