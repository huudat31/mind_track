import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/game/mini_games/breathing_game/screens/breathing_game_screen.dart';
import 'package:mind_track/features/game/mini_games/distortion_game/screens/distortion_game_screen.dart';
import 'package:mind_track/features/game/mini_games/evidence_game/screens/evidence_game_screen.dart';
import 'package:mind_track/features/game/screens/game_hub_screen.dart';
import 'package:mind_track/features/game/story/screens/story_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const smallScreenSize = Size(360, 640);
  const largeTextScaler = TextScaler.linear(1.3);

  group('Small Screen (360x640) & TextScaler 1.3 Accessibility Tests', () {
    testWidgets('GameHubScreen renders without overflow on 360x640 with textScaler 1.3',
        (WidgetTester tester) async {
      FlutterError.onError = (details) {
        FlutterError.dumpErrorToConsole(details);
      };
      tester.view.physicalSize = const Size(360 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MediaQuery(
            data: MediaQueryData(
              size: smallScreenSize,
              textScaler: largeTextScaler,
              disableAnimations: true,
            ),
            child: MaterialApp(
              home: GameHubScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('BreathingGameScreen renders without overflow on 360x640 with textScaler 1.3',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MediaQuery(
            data: MediaQueryData(
              size: smallScreenSize,
              textScaler: largeTextScaler,
              disableAnimations: true,
            ),
            child: MaterialApp(
              home: BreathingGameScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('DistortionGameScreen renders without overflow on 360x640 with textScaler 1.3',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MediaQuery(
            data: MediaQueryData(
              size: smallScreenSize,
              textScaler: largeTextScaler,
              disableAnimations: true,
            ),
            child: MaterialApp(
              home: DistortionGameScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('EvidenceGameScreen renders without overflow on 360x640 with textScaler 1.3',
        (WidgetTester tester) async {
      FlutterError.onError = (details) {
        FlutterError.dumpErrorToConsole(details);
      };
      tester.view.physicalSize = const Size(360 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MediaQuery(
            data: MediaQueryData(
              size: smallScreenSize,
              textScaler: largeTextScaler,
              disableAnimations: true,
            ),
            child: MaterialApp(
              home: EvidenceGameScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('StoryScreen renders without overflow on 360x640 with textScaler 1.3',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const simpleJson = '''
{
  "story_id": "test_responsive",
  "title": "Thử nghiệm phản hồi",
  "context_tag": "hoc_tap",
  "start_node_id": "node_1",
  "nodes": [
    {
      "id": "node_1",
      "speaker": "muoi_den",
      "text": "Kiểm tra hiển thị chữ dài và cỡ chữ lớn trên thiết bị màn hình nhỏ.",
      "mood": "happy",
      "choices": [
        {
          "text": "Lựa chọn thử nghiệm với nội dung dài nhiều dòng để kiểm tra khả năng co giãn dòng chữ",
          "next_node_id": null,
          "action": "complete_story"
        }
      ]
    }
  ]
}
''';

      await tester.pumpWidget(
        const ProviderScope(
          child: MediaQuery(
            data: MediaQueryData(
              size: smallScreenSize,
              textScaler: largeTextScaler,
              disableAnimations: true,
            ),
            child: MaterialApp(
              home: StoryScreen(directJson: simpleJson),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
