import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/game/constants/game_strings.dart';
import 'package:mind_track/features/game/mini_games/breathing_game/logic/breathing_phase.dart';
import 'package:mind_track/features/game/mini_games/breathing_game/logic/breathing_scorer.dart';
import 'package:mind_track/features/game/mini_games/breathing_game/screens/breathing_game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BreathingPhase & Timing Constants', () {
    test('4-4-6 timing adds up to 14s total cycle', () {
      expect(BreathingConstants.inhaleSeconds, 4);
      expect(BreathingConstants.holdSeconds, 4);
      expect(BreathingConstants.exhaleSeconds, 6);
      expect(BreathingConstants.totalCycleSeconds, 14);
      expect(BreathingConstants.totalCycles, 3);
    });

    test('getPhaseFromProgress correctly segments the phases', () {
      expect(BreathingScorer.getPhaseFromProgress(0.0), BreathingPhase.inhale);
      expect(BreathingScorer.getPhaseFromProgress(0.20), BreathingPhase.inhale);
      expect(BreathingScorer.getPhaseFromProgress(0.35), BreathingPhase.hold);
      expect(BreathingScorer.getPhaseFromProgress(0.55), BreathingPhase.hold);
      expect(BreathingScorer.getPhaseFromProgress(0.70), BreathingPhase.exhale);
      expect(BreathingScorer.getPhaseFromProgress(0.99), BreathingPhase.exhale);
    });
  });

  group('BreathingScorer Unit Tests', () {
    test('Perfect synchronization yields 100% and 3 stars', () {
      final scorer = BreathingScorer();

      // Record 10 samples in Inhale (all holding)
      for (int i = 0; i < 10; i++) {
        scorer.recordSample(cycleProgress: 0.1, isUserHolding: true);
      }
      // Record 10 samples in Hold (all holding)
      for (int i = 0; i < 10; i++) {
        scorer.recordSample(cycleProgress: 0.4, isUserHolding: true);
      }
      // Record 10 samples in Exhale (all released)
      for (int i = 0; i < 10; i++) {
        scorer.recordSample(cycleProgress: 0.8, isUserHolding: false);
      }

      expect(scorer.calculateAccuracy(), 100);
      expect(scorer.calculateStars(), 3);
    });

    test('Synchronization between 60% and 85% yields 2 stars', () {
      final scorer = BreathingScorer();

      // 7 correct, 3 wrong
      for (int i = 0; i < 7; i++) {
        scorer.recordSample(cycleProgress: 0.1, isUserHolding: true);
      }
      for (int i = 0; i < 3; i++) {
        scorer.recordSample(cycleProgress: 0.1, isUserHolding: false);
      }

      expect(scorer.calculateAccuracy(), 70);
      expect(scorer.calculateStars(), 2);
    });

    test('Synchronization below 60% yields 1 star (completion encouraged)', () {
      final scorer = BreathingScorer();

      // 4 correct, 6 wrong
      for (int i = 0; i < 4; i++) {
        scorer.recordSample(cycleProgress: 0.1, isUserHolding: true);
      }
      for (int i = 0; i < 6; i++) {
        scorer.recordSample(cycleProgress: 0.1, isUserHolding: false);
      }

      expect(scorer.calculateAccuracy(), 40);
      expect(scorer.calculateStars(), 1);
    });
  });

  group('BreathingGameScreen Widget Tests', () {
    testWidgets('Renders tutorial dialog initially and allows starting session',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              home: BreathingGameScreen(showTutorialInitially: true),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(GameStrings.breathingTutorialTitle), findsOneWidget);
      expect(find.text(GameStrings.breathingStart), findsOneWidget);

      // Tap start in tutorial
      await tester.tap(find.text(GameStrings.breathingStart));
      await tester.pump();

      expect(find.text('Vòng thở: 1 / 3'), findsOneWidget);
    });

    testWidgets('Toggle tap mode works without issue',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              home: BreathingGameScreen(showTutorialInitially: false),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find switch mode button
      final toggleBtn = find.text('Khó giữ ngón tay? Chuyển sang Chạm nhịp');
      expect(toggleBtn, findsOneWidget);

      await tester.tap(toggleBtn);
      await tester.pump();

      expect(find.text('Chạm để hít/giữ'), findsOneWidget);
      expect(find.text('Chuyển sang chế độ Giữ ngón tay'), findsOneWidget);
    });
  });
}
