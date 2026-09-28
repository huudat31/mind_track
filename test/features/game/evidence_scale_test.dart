import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/game/models/evidence_card_model.dart';
import 'package:mind_track/features/game/mini_games/evidence_game/logic/evidence_scale_logic.dart';
import 'package:mind_track/features/game/mini_games/evidence_game/screens/evidence_game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Evidence Card & Scenario Models', () {
    test('EvidenceSide fromString parses strings', () {
      expect(EvidenceSide.fromString('support'), EvidenceSide.support);
      expect(EvidenceSide.fromString('ung_ho'), EvidenceSide.support);
      expect(EvidenceSide.fromString('against'), EvidenceSide.against);
      expect(EvidenceSide.fromString('neutral'), EvidenceSide.neutral);
      expect(EvidenceSide.fromString('unknown'), isNull);
    });

    test('Scenario file contains 6 valid scenarios covering 4 context tags', () {
      final file = File('assets/game/evidence_scenarios.json');
      final jsonString = file.readAsStringSync();
      final scenarios = EvidenceScaleSession.parseScenariosFromJson(jsonString);

      expect(scenarios.length, 6);

      final tags = scenarios.map((s) => s.contextTag).toSet();
      expect(tags.contains('hoc_tap'), isTrue);
      expect(tags.contains('gia_dinh'), isTrue);
      expect(tags.contains('tinh_cam'), isTrue);
      expect(tags.contains('mang_xa_hoi'), isTrue);

      for (final s in scenarios) {
        expect(s.evidenceCards.length, inInclusiveRange(6, 8));
        expect(s.negativeThought, isNotEmpty);
        expect(s.balancedThought, isNotEmpty);
      }
    });
  });

  group('EvidenceScaleSession Pure Dart Logic', () {
    final testScenario = EvidenceScenario(
      id: 'test_s1',
      contextTag: 'hoc_tap',
      negativeThought: 'Suy nghĩ tiêu cực mẫu',
      balancedThought: 'Góc nhìn cân bằng mẫu',
      evidenceCards: [
        const EvidenceCardModel(id: 'c1', text: 'Ủng hộ 1', side: EvidenceSide.support),
        const EvidenceCardModel(id: 'c2', text: 'Ngược lại 1', side: EvidenceSide.against),
        const EvidenceCardModel(id: 'c3', text: 'Ngược lại 2', side: EvidenceSide.against),
        const EvidenceCardModel(id: 'c4', text: 'Trung tính 1', side: EvidenceSide.neutral),
      ],
    );

    test('tryPlaceCard correctly places cards and rejects invalid side', () {
      final session = EvidenceScaleSession(scenario: testScenario);

      expect(session.remainingCards.length, 4);
      expect(session.leftPlateCards.isEmpty, isTrue);
      expect(session.rightPlateCards.isEmpty, isTrue);

      // Try placing against card on support plate -> should fail
      final failed = session.tryPlaceCard(testScenario.evidenceCards[1], EvidenceSide.support);
      expect(failed, isFalse);
      expect(session.firstAttemptFailedCardIds.contains('c2'), isTrue);
      expect(session.remainingCards.length, 4);

      // Place correctly
      final success1 = session.tryPlaceCard(testScenario.evidenceCards[0], EvidenceSide.support);
      expect(success1, isTrue);
      expect(session.leftPlateCards.length, 1);
      expect(session.remainingCards.length, 3);

      // Neutral card can be placed on support
      final successNeutral = session.tryPlaceCard(testScenario.evidenceCards[3], EvidenceSide.support);
      expect(successNeutral, isTrue);
    });

    test('calculateTiltAngle tilts according to plate weights', () {
      final session = EvidenceScaleSession(scenario: testScenario);

      // Balanced initially -> tilt 0.0
      expect(session.calculateTiltAngle(), 0.0);

      // Place right card -> right heavier -> tilt positive
      session.tryPlaceCard(testScenario.evidenceCards[1], EvidenceSide.against);
      expect(session.calculateTiltAngle(), greaterThan(0.0));

      // Place left card -> balanced again
      session.tryPlaceCard(testScenario.evidenceCards[0], EvidenceSide.support);
      expect(session.calculateTiltAngle(), 0.0);

      // Place another right card -> right heavier
      session.tryPlaceCard(testScenario.evidenceCards[2], EvidenceSide.against);
      expect(session.calculateTiltAngle(), greaterThan(0.0));
    });

    test('Stars and accuracy calculation works properly', () {
      final session = EvidenceScaleSession(scenario: testScenario);

      // Place all 4 without errors
      session.tryPlaceCard(testScenario.evidenceCards[0], EvidenceSide.support);
      session.tryPlaceCard(testScenario.evidenceCards[1], EvidenceSide.against);
      session.tryPlaceCard(testScenario.evidenceCards[2], EvidenceSide.against);
      session.tryPlaceCard(testScenario.evidenceCards[3], EvidenceSide.against);

      expect(session.calculateFirstAttemptAccuracy(), 100);
      expect(session.calculateStars(), 3);
      expect(session.isCompleted, isTrue);
    });
  });

  group('EvidenceGameScreen Widget Tests', () {
    final sampleScenario = EvidenceScenario(
      id: 'sample_s1',
      contextTag: 'hoc_tap',
      negativeThought: 'Mình không làm được bài',
      balancedThought: 'Góc nhìn tích cực cân bằng',
      evidenceCards: [
        const EvidenceCardModel(id: 'c1', text: 'Thẻ bằng chứng ủng hộ', side: EvidenceSide.support),
      ],
    );

    testWidgets('Renders scenario and allows placing card via tap to reveal balanced thought',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              home: EvidenceGameScreen(initialScenario: sampleScenario),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('“Mình không làm được bài”'), findsOneWidget);
      expect(find.text('Bằng chứng ngược lại'), findsOneWidget);
      expect(find.text('Bằng chứng ủng hộ'), findsOneWidget);

      // Tap on card to select
      await tester.tap(find.text('Thẻ bằng chứng ủng hộ'));
      await tester.pump();

      // Tap on Left plate (Ủng hộ) to place card
      await tester.tap(find.text('Bằng chứng ủng hộ'));
      await tester.pumpAndSettle();

      // Balanced thought should now be visible!
      expect(find.text('Góc nhìn cân bằng mới:'), findsOneWidget);
      expect(find.text('Góc nhìn tích cực cân bằng'), findsOneWidget);
      expect(find.text('Tiếp nhận góc nhìn này'), findsOneWidget);
    });
  });
}
