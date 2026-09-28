import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/game/models/cognitive_distortion_type.dart';
import 'package:mind_track/features/game/models/companion_tone.dart';
import 'package:mind_track/features/game/models/distortion_scenario.dart';
import 'package:mind_track/features/game/models/mock_ui_model.dart';
import 'package:mind_track/features/game/mini_games/distortion_game/logic/distortion_game_engine.dart';
import 'package:mind_track/features/game/mini_games/distortion_game/screens/distortion_game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DistortionType Enum & Strict Fail-Fast Validation', () {
    test('fromId correctly resolves valid IDs', () {
      expect(DistortionType.fromId('labeling'), DistortionType.labeling);
      expect(DistortionType.fromId('catastrophizing'), DistortionType.catastrophizing);
      expect(DistortionType.fromId('all_or_nothing'), DistortionType.allOrNothing);
      expect(DistortionType.fromId('personalization'), DistortionType.personalization);
      expect(DistortionType.fromId('mind_reading'), DistortionType.mindReading);
      expect(DistortionType.fromId('emotional_reasoning'), DistortionType.emotionalReasoning);
    });

    test('fromId throws FormatException on invalid ID (Fail-Fast)', () {
      expect(
        () => DistortionType.fromId('invalid_trap_id'),
        throwsFormatException,
      );
    });

    test('ToneType and CompanionIntro fallback chain works strictly', () {
      const intro = CompanionIntro({
        ToneType.chill: 'Chill intro',
        ToneType.friendly: 'Friendly intro',
        ToneType.calm: 'Calm intro',
      });

      expect(intro.getIntro(ToneType.chill), 'Chill intro');
      expect(intro.getIntro(ToneType.friendly), 'Friendly intro');
      expect(intro.getIntro(ToneType.calm), 'Calm intro');
    });
  });

  group('Distortion Scenarios File & Game Engine', () {
    late List<DistortionScenario> scenarios;

    setUpAll(() {
      final file = File('assets/game/distortion_questions.json');
      final jsonContent = file.readAsStringSync();
      scenarios = DistortionGameEngine.parseScenariosFromJson(jsonContent);
    });

    test('Asset file contains 12 standardized CBT scenarios with diverse MockUI types', () {
      expect(scenarios.length, 12);

      final tags = scenarios.map((s) => s.contextTag).toSet();
      expect(tags.contains('hoc_tap'), isTrue);
      expect(tags.contains('gia_dinh'), isTrue);
      expect(tags.contains('tinh_cam'), isTrue);

      final uiTypes = scenarios.map((s) => s.mockUi.type).toSet();
      expect(uiTypes.contains('chat'), isTrue);
      expect(uiTypes.contains('note'), isTrue);
      expect(uiTypes.contains('notification'), isTrue);
      expect(uiTypes.contains('social_post'), isTrue);
    });

    test('generateSessionRounds returns rounds with randomized options and valid correct index', () {
      final engine = DistortionGameEngine(allScenarios: scenarios);
      final rounds = engine.generateSessionRounds(count: 6);

      expect(rounds.length, 6);

      for (final round in rounds) {
        expect(round.options.length, 4);
        expect(round.correctOptionIndex, inInclusiveRange(0, 3));
        expect(round.options[round.correctOptionIndex], round.scenario.distortionType);
      }
    });

    test('Scoring calculates stars correctly', () {
      expect(DistortionGameEngine.calculateStars(6, 6), 3); // 100% -> 3 sao
      expect(DistortionGameEngine.calculateStars(5, 6), 2); // 83% -> 2 sao
      expect(DistortionGameEngine.calculateStars(3, 6), 1); // 50% -> 1 sao
      expect(DistortionGameEngine.calculateStars(2, 6), 0); // 33% -> 0 sao
    });
  });

  group('DistortionGameScreen Widget Test with MockUi and Tone Dial', () {
    final sampleScenario = DistortionScenario(
      id: 'sample_chat_1',
      contextTag: 'hoc_tap',
      mockUi: const MockUiChat([
        ChatMessage(sender: SenderType.friend, text: 'Tớ được 9.5!', timestamp: '10:00'),
        ChatMessage(sender: SenderType.me, text: 'Tớ được 7.0...', timestamp: '10:01'),
      ]),
      thought: 'Mình đúng là đứa kém cỏi không làm được gì.',
      distortionType: DistortionType.labeling,
      choices: [
        DistortionType.catastrophizing,
        DistortionType.labeling,
        DistortionType.mindReading,
        DistortionType.emotionalReasoning,
      ],
      hintKey: 'hint_labeling',
      reframe: 'Điểm 7 không định nghĩa toàn bộ con người mình.',
      companionIntro: const CompanionIntro({
        ToneType.chill: 'Chill: Cay thật nhưng đừng tự dìm!',
        ToneType.friendly: 'Friendly: Cùng nhận diện bẫy suy nghĩ nhé.',
        ToneType.calm: 'Calm: Quan sát dạng suy nghĩ vừa xuất hiện.',
      }),
    );

    testWidgets('Renders MockUi chat, thought, companion intro and allows answering',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                disableAnimations: true,
                size: Size(800, 1600),
              ),
              child: DistortionGameScreen(
                initialScenarios: [sampleScenario],
                initialTone: ToneType.chill,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Counter & Tone
      expect(find.text('Câu 1 / 1'), findsOneWidget);
      expect(find.text('Giọng: CHILL'), findsOneWidget);

      // Verify Mock UI Chat messages rendered
      expect(find.text('Tớ được 9.5!'), findsOneWidget);
      expect(find.text('Tớ được 7.0...'), findsOneWidget);

      // Verify Thought & Companion Intro
      expect(find.text('“Mình đúng là đứa kém cỏi không làm được gì.”'), findsOneWidget);
      expect(find.text('Chill: Cay thật nhưng đừng tự dìm!'), findsOneWidget);

      // Tap Correct Option (Dán nhãn)
      final correctButton = find.text('Dán nhãn');
      expect(correctButton, findsOneWidget);

      await tester.tap(correctButton);
      await tester.pump();

      // Check Reframe Card appears
      expect(find.text('Chính xác rồi!'), findsOneWidget);
      expect(find.text('Điểm 7 không định nghĩa toàn bộ con người mình.'), findsOneWidget);
      expect(find.text('Câu tiếp theo'), findsOneWidget);
    });
  });
}
