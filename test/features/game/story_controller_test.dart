import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/game/story/controller/story_controller.dart';
import 'package:mind_track/features/game/story/models/story_node.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StoryController Logic & State Management', () {
    final file = File('assets/game/story/exam_01.json');
    final jsonContent = file.readAsStringSync();

    test('Loads story successfully and sets current node to startNode', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(storyControllerProvider.notifier);
      await notifier.loadStory(jsonContent: jsonContent, resume: false);

      final state = container.read(storyControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.script, isNotNull);
      expect(state.currentNode?.id, 'node_01_start');
      expect(state.historyNodeIds, ['node_01_start']);
    });

    test('Transitions to next node and saves to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(storyControllerProvider.notifier);
      await notifier.loadStory(jsonContent: jsonContent, resume: false);

      final stateBefore = container.read(storyControllerProvider);
      final firstChoice = stateBefore.currentNode!.choices.first;

      await notifier.selectChoice(firstChoice);

      final stateAfter = container.read(storyControllerProvider);
      expect(stateAfter.currentNode?.id, 'node_02_stress');
      expect(stateAfter.historyNodeIds, ['node_01_start', 'node_02_stress']);

      // Check SharedPreferences persisted node
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('game_story_active_node_exam_01'), 'node_02_stress');
    });

    test('Resumes from SharedPreferences when available', () async {
      SharedPreferences.setMockInitialValues({
        'game_story_active_node_exam_01': 'node_03_breathing_trigger',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(storyControllerProvider.notifier);
      await notifier.loadStory(jsonContent: jsonContent, resume: true);

      final state = container.read(storyControllerProvider);
      expect(state.currentNode?.id, 'node_03_breathing_trigger');
    });

    test('Triggers minigame and resumes after completion', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(storyControllerProvider.notifier);
      await notifier.loadStory(jsonContent: jsonContent, resume: false);

      // Navigate to breathing trigger
      final choice1 = const StoryChoice(
        text: 'Thở',
        nextNodeId: 'node_04_after_breathing',
        action: 'start_minigame:breathing',
      );

      await notifier.selectChoice(choice1);

      final statePending = container.read(storyControllerProvider);
      expect(statePending.pendingMinigameType, 'breathing');
      expect(statePending.pendingNextNodeId, 'node_04_after_breathing');

      // Complete minigame
      await notifier.completeMinigameAndContinue();

      final stateAfter = container.read(storyControllerProvider);
      expect(stateAfter.pendingMinigameType, isNull);
      expect(stateAfter.currentNode?.id, 'node_04_after_breathing');
    });

    test('resetStory clears SharedPreferences and returns to start node', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(storyControllerProvider.notifier);
      await notifier.loadStory(jsonContent: jsonContent, resume: false);

      final choice = container.read(storyControllerProvider).currentNode!.choices.first;
      await notifier.selectChoice(choice);

      expect(container.read(storyControllerProvider).currentNode?.id, 'node_02_stress');

      await notifier.resetStory();

      final stateReset = container.read(storyControllerProvider);
      expect(stateReset.currentNode?.id, 'node_01_start');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('game_story_active_node_exam_01'), isFalse);
    });
  });
}
