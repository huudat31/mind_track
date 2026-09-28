import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/game/constants/game_strings.dart';
import 'package:mind_track/features/game/mini_games/breathing_game/screens/breathing_game_screen.dart';
import 'package:mind_track/features/game/models/game_level.dart';
import 'package:mind_track/features/game/screens/game_hub_screen.dart';
import 'package:mind_track/features/game/screens/game_placeholder_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('GameHubScreen renders companion header and 3 journey nodes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: GameHubScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(GameStrings.gameTitle), findsOneWidget);
    expect(find.text(GameStrings.journeyMap), findsOneWidget);
    expect(find.text(GameLevel.defaultLevels[0].title), findsOneWidget);
    expect(find.text(GameLevel.defaultLevels[1].title), findsOneWidget);
    expect(find.text(GameLevel.defaultLevels[2].title), findsOneWidget);
  });

  testWidgets('Tapping locked node displays locked SnackBar message',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: GameHubScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Node 2 is locked initially
    final node2 = find.text(GameLevel.defaultLevels[1].title);
    expect(node2, findsOneWidget);

    await tester.ensureVisible(node2);
    await tester.pumpAndSettle();
    await tester.tap(node2);
    await tester.pump();

    expect(find.text(GameStrings.lockedLevelMessage), findsOneWidget);
  });

  testWidgets('Tapping unlocked node navigates to mini-game screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: GameHubScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Node 1 is unlocked initially -> navigates to BreathingGameScreen
    final node1 = find.text(GameLevel.defaultLevels[0].title);
    expect(node1, findsOneWidget);

    await tester.tap(node1);
    await tester.pumpAndSettle();

    expect(find.byType(BreathingGameScreen), findsOneWidget);
  });

  testWidgets('Completing a level in placeholder updates progress and unlocks next level',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: GameHubScreen(
                screenBuilderOverride: (lvl) => GamePlaceholderScreen(level: lvl),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Open Level 1 (with placeholder override)
    await tester.tap(find.text(GameLevel.defaultLevels[0].title));
    await tester.pumpAndSettle();

    // Tap "Hoàn thành thử"
    await tester.tap(find.text('Hoàn thành thử (Mở khóa tiếp)'));
    await tester.pumpAndSettle();

    // Now back on GameHubScreen, Level 2 should be unlocked!
    // Tapping Level 2 should now navigate instead of showing locked SnackBar
    await tester.tap(find.text(GameLevel.defaultLevels[1].title));
    await tester.pumpAndSettle();

    expect(find.byType(GamePlaceholderScreen), findsOneWidget);
    expect(find.text(GameLevel.defaultLevels[1].title), findsNWidgets(2));
  });
}
