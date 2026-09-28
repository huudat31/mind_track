import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/game/models/cognitive_distortion_type.dart';
import 'package:mind_track/features/game/models/distortion_question.dart';
import 'package:mind_track/features/game/mini_games/distortion_game/logic/distortion_game_engine.dart';
import 'package:mind_track/features/game/mini_games/distortion_game/screens/distortion_game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CognitiveDistortionType & Question Model', () {
    test('fromString parses various key representations', () {
      expect(
        CognitiveDistortionType.fromString('catastrophizing'),
        CognitiveDistortionType.catastrophizing,
      );
      expect(
        CognitiveDistortionType.fromString('tham_hoa_hoa'),
        CognitiveDistortionType.catastrophizing,
      );
      expect(
        CognitiveDistortionType.fromString('black_and_white'),
        CognitiveDistortionType.blackAndWhite,
      );
      expect(
        CognitiveDistortionType.fromString('invalid_key'),
        isNull,
      );
    });

    test('DistortionQuestion validates schema and throws descriptive FormatException', () {
      expect(
        () => DistortionQuestion.fromJson({
          'contextTag': 'hoc_tap',
          'thought': 'Test',
          'correctType': 'labeling',
        }),
        throwsFormatException,
      );

      expect(
        () => DistortionQuestion.fromJson({
          'id': 'q1',
          'contextTag': 'hoc_tap',
          'thought': 'Test',
          'correctType': 'non_existent_type',
        }),
        throwsFormatException,
      );
    });
  });

  group('Distortion Questions File & Game Engine', () {
    late List<DistortionQuestion> questions;

    setUpAll(() {
      final file = File('assets/game/distortion_questions.json');
      final jsonContent = file.readAsStringSync();
      questions = DistortionGameEngine.parseQuestionsFromJson(jsonContent);
    });

    test('Asset questions file contains exactly 24 valid questions with 4 context tags', () {
      expect(questions.length, 24);

      final tags = questions.map((q) => q.contextTag).toSet();
      expect(tags.contains('hoc_tap'), isTrue);
      expect(tags.contains('gia_dinh'), isTrue);
      expect(tags.contains('tinh_cam'), isTrue);
      expect(tags.contains('mang_xa_hoi'), isTrue);

      for (final tag in tags) {
        final count = questions.where((q) => q.contextTag == tag).length;
        expect(count, greaterThanOrEqualTo(6));
      }
    });

    test('generateSessionRounds returns 8 rounds with randomized options and valid correct index', () {
      final engine = DistortionGameEngine(allQuestions: questions);
      final rounds = engine.generateSessionRounds(count: 8);

      expect(rounds.length, 8);

      for (final round in rounds) {
        expect(round.options.length, 4);
        expect(round.correctOptionIndex, inInclusiveRange(0, 3));
        expect(round.options[round.correctOptionIndex], round.question.correctType);
      }
    });

    test('generateSessionRounds prioritizes preferredContextTag', () {
      final engine = DistortionGameEngine(allQuestions: questions);
      final rounds = engine.generateSessionRounds(
        preferredContextTag: 'hoc_tap',
        count: 8,
      );

      final hocTapCount =
          rounds.where((r) => r.question.contextTag == 'hoc_tap').length;
      expect(hocTapCount, greaterThanOrEqualTo(6));
    });

    test('Scoring calculates stars correctly', () {
      // >= 90% -> 3 stars (8/8 = 100%, 7/8 = 88% -> 2 stars)
      expect(DistortionGameEngine.calculateStars(8, 8), 3);
      expect(DistortionGameEngine.calculateStars(7, 8), 2); // 88%
      expect(DistortionGameEngine.calculateStars(6, 8), 2); // 75%
      expect(DistortionGameEngine.calculateStars(5, 8), 1); // 63%
      expect(DistortionGameEngine.calculateStars(4, 8), 1); // 50%
      expect(DistortionGameEngine.calculateStars(3, 8), 0); // 38%
    });
  });

  group('DistortionGameScreen Widget Test', () {
    final sampleQuestions = [
      const DistortionQuestion(
        id: 'sample_1',
        contextTag: 'hoc_tap',
        thought: 'Mình không làm được bài này thì mình là kẻ ngốc.',
        correctType: CognitiveDistortionType.labeling,
        explanation: 'Đây là gán nhãn bản thân.',
        reframeSuggestion: 'Chưa làm được một bài không có nghĩa mình ngốc.',
      ),
      const DistortionQuestion(
        id: 'sample_2',
        contextTag: 'hoc_tap',
        thought: 'Điểm 9 vẫn là thất bại vì không được 10.',
        correctType: CognitiveDistortionType.blackAndWhite,
        explanation: 'Đây là tư duy trắng đen.',
        reframeSuggestion: 'Điểm 9 là thành tích rất tốt.',
      ),
    ];

    testWidgets('Renders question thought and answering options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              home: DistortionGameScreen(initialQuestions: sampleQuestions),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Câu 1 / 2'), findsOneWidget);
      expect(find.text('Đúng: 0'), findsOneWidget);

      final isSample1 = find
          .text('“Mình không làm được bài này thì mình là kẻ ngốc.”')
          .evaluate()
          .isNotEmpty;
      final correctOptionFinder =
          find.text(isSample1 ? 'Gán nhãn bản thân' : 'Nghĩ trắng - đen');
      expect(correctOptionFinder, findsOneWidget);

      await tester.tap(correctOptionFinder);
      await tester.pump();

      // Check reframe card is shown
      expect(find.text('Chính xác rồi!'), findsOneWidget);
      expect(find.text('Gợi ý đổi góc nhìn (Reframe):'), findsOneWidget);
      expect(find.text('Câu tiếp theo'), findsOneWidget);
      expect(find.text('Đúng: 1'), findsOneWidget);
    });
  });
}
