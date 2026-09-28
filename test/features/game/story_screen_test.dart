import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/game/story/screens/story_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testJson = '''
{
  "story_id": "test_story_ui",
  "title": "Kiểm tra giao diện Story",
  "context_tag": "hoc_tap",
  "start_node_id": "node_test_start",
  "nodes": [
    {
      "id": "node_test_start",
      "speaker": "muoi_den",
      "text": "Chào bạn! Đây là câu nói chào mừng.",
      "mood": "happy",
      "choices": [
        {
          "text": "Lựa chọn 1: Căng thẳng",
          "next_node_id": "node_test_next"
        }
      ]
    },
    {
      "id": "node_test_next",
      "speaker": "muoi_den",
      "text": "Bạn đã chọn chuyển sang node tiếp theo.",
      "mood": "calm",
      "choices": [
        {
          "text": "Hoàn thành thử thách",
          "next_node_id": null,
          "action": "complete_story"
        }
      ]
    }
  ]
}
''';

  testWidgets('StoryScreen renders dialogue and navigates through choices to completion',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true, size: Size(360, 640)),
          child: const MaterialApp(
            home: StoryScreen(directJson: testJson),
          ),
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify Title and Dialogue Text
    expect(find.text('Kiểm tra giao diện Story'), findsOneWidget);
    expect(find.text('Chào bạn! Đây là câu nói chào mừng.'), findsOneWidget);
    expect(find.text('Lựa chọn 1: Căng thẳng'), findsOneWidget);

    // Tap Choice 1
    await tester.tap(find.text('Lựa chọn 1: Căng thẳng'));
    await tester.pumpAndSettle();

    // Verify next node is rendered
    expect(find.text('Bạn đã chọn chuyển sang node tiếp theo.'), findsOneWidget);
    expect(find.text('Hoàn thành thử thách'), findsOneWidget);

    // Tap Completion choice
    await tester.tap(find.text('Hoàn thành thử thách'));
    await tester.pumpAndSettle();

    // Completion view should appear
    expect(find.text('Hành Trình Hoàn Thành!'), findsOneWidget);
    expect(find.text('Về Bản Đồ Trò Chơi'), findsOneWidget);
  });
}
