import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/game/story/models/story_node.dart';
import 'package:mind_track/features/game/story/parser/story_parser.dart';
import 'package:mind_track/features/game/story/validator/story_validator.dart';

void main() {
  group('StoryValidator with Assets exam_01.json', () {
    test('exam_01.json is completely valid with 0 broken links and 0 dead ends', () {
      final file = File('assets/game/story/exam_01.json');
      expect(file.existsSync(), isTrue);

      final jsonContent = file.readAsStringSync();
      final script = StoryParser.parse(jsonContent);

      expect(script.storyId, 'exam_01');
      expect(script.nodes.length, greaterThanOrEqualTo(14));

      final validation = StoryValidator.validate(script);

      if (!validation.isValid) {
        // ignore: avoid_print
        print('Validation errors: ${validation.errors}');
      }

      expect(validation.isValid, isTrue, reason: validation.errors.join(', '));
      expect(validation.errors, isEmpty);
    });
  });

  group('StoryValidator Pure Logic Edge Cases', () {
    test('Returns invalid when start node does not exist', () {
      const script = StoryScript(
        storyId: 'invalid_start',
        title: 'Lỗi start node',
        contextTag: 'hoc_tap',
        startNodeId: 'non_existent_node',
        nodes: {
          'node_1': StoryNode(
            id: 'node_1',
            speaker: 'muoi_den',
            text: 'Xin chào',
            mood: StoryMood.happy,
            choices: [],
          ),
        },
      );

      final result = StoryValidator.validate(script);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('Start node')), isTrue);
    });

    test('Detects broken links pointing to nonexistent target nodes', () {
      const script = StoryScript(
        storyId: 'broken_link',
        title: 'Lỗi liên kết',
        contextTag: 'hoc_tap',
        startNodeId: 'node_1',
        nodes: {
          'node_1': StoryNode(
            id: 'node_1',
            speaker: 'muoi_den',
            text: 'Bước 1',
            mood: StoryMood.happy,
            choices: [
              StoryChoice(text: 'Đi tiếp', nextNodeId: 'node_ghost'),
            ],
          ),
        },
      );

      final result = StoryValidator.validate(script);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('node_ghost')), isTrue);
    });

    test('Detects dead ends where a branch cannot reach any ending node', () {
      // node_1 -> node_trap_a <-> node_trap_b (vòng lặp không lối thoát tới ending)
      const script = StoryScript(
        storyId: 'dead_end_cycle',
        title: 'Bẫy vô tận',
        contextTag: 'hoc_tap',
        startNodeId: 'node_1',
        nodes: {
          'node_1': StoryNode(
            id: 'node_1',
            speaker: 'muoi_den',
            text: 'Bước 1',
            mood: StoryMood.happy,
            choices: [
              StoryChoice(text: 'Vào bẫy', nextNodeId: 'node_trap_a'),
              StoryChoice(text: 'Về đích', nextNodeId: 'node_end'),
            ],
          ),
          'node_trap_a': StoryNode(
            id: 'node_trap_a',
            speaker: 'muoi_den',
            text: 'Kẹt trong bẫy A',
            mood: StoryMood.worried,
            choices: [
              StoryChoice(text: 'Sang bẫy B', nextNodeId: 'node_trap_b'),
            ],
          ),
          'node_trap_b': StoryNode(
            id: 'node_trap_b',
            speaker: 'muoi_den',
            text: 'Kẹt trong bẫy B',
            mood: StoryMood.worried,
            choices: [
              StoryChoice(text: 'Về bẫy A', nextNodeId: 'node_trap_a'),
            ],
          ),
          'node_end': StoryNode(
            id: 'node_end',
            speaker: 'muoi_den',
            text: 'Kết thúc',
            mood: StoryMood.happy,
            choices: [
              StoryChoice(text: 'Xong', action: 'complete_story'),
            ],
          ),
        },
      );

      final result = StoryValidator.validate(script);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('Dead end')), isTrue);
      expect(result.errors.any((e) => e.contains('node_trap_a') || e.contains('node_trap_b')), isTrue);
    });

    test('Reports warning for unreachable orphan nodes', () {
      const script = StoryScript(
        storyId: 'orphan_node',
        title: 'Node mồ côi',
        contextTag: 'hoc_tap',
        startNodeId: 'node_1',
        nodes: {
          'node_1': StoryNode(
            id: 'node_1',
            speaker: 'muoi_den',
            text: 'Bắt đầu',
            mood: StoryMood.happy,
            choices: [
              StoryChoice(text: 'Kết thúc', action: 'complete_story'),
            ],
          ),
          'orphan_node_x': StoryNode(
            id: 'orphan_node_x',
            speaker: 'muoi_den',
            text: 'Không ai gọi tôi',
            mood: StoryMood.thinking,
            choices: [],
          ),
        },
      );

      final result = StoryValidator.validate(script);
      expect(result.isValid, isTrue); // Không có lỗi fatal
      expect(result.warnings.any((w) => w.contains('orphan_node_x')), isTrue);
    });
  });
}
