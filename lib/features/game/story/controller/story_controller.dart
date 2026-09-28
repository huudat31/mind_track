import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_track/features/game/story/models/story_node.dart';
import 'package:mind_track/features/game/story/parser/story_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Trạng thái của phiên hội thoại Story
class StoryState {
  final StoryScript? script;
  final StoryNode? currentNode;
  final List<String> historyNodeIds;
  final bool isCompleted;
  final bool isLoading;
  final String? pendingMinigameType;
  final String? pendingNextNodeId;
  final String? errorMessage;

  const StoryState({
    this.script,
    this.currentNode,
    this.historyNodeIds = const [],
    this.isCompleted = false,
    this.isLoading = false,
    this.pendingMinigameType,
    this.pendingNextNodeId,
    this.errorMessage,
  });

  StoryState copyWith({
    StoryScript? script,
    StoryNode? currentNode,
    List<String>? historyNodeIds,
    bool? isCompleted,
    bool? isLoading,
    String? pendingMinigameType,
    String? pendingNextNodeId,
    String? errorMessage,
    bool clearPendingMinigame = false,
    bool clearError = false,
  }) {
    return StoryState(
      script: script ?? this.script,
      currentNode: currentNode ?? this.currentNode,
      historyNodeIds: historyNodeIds ?? this.historyNodeIds,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      pendingMinigameType: clearPendingMinigame
          ? null
          : (pendingMinigameType ?? this.pendingMinigameType),
      pendingNextNodeId: clearPendingMinigame
          ? null
          : (pendingNextNodeId ?? this.pendingNextNodeId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Controller điều phối luồng Story bằng Riverpod Notifier
class StoryController extends Notifier<StoryState> {
  static const String _prefPrefix = 'game_story_active_node_';

  @override
  StoryState build() {
    return const StoryState(isLoading: true);
  }

  /// Tải kịch bản từ Assets hoặc từ chuỗi JSON trực tiếp
  Future<void> loadStory({
    String assetPath = 'assets/game/story/exam_01.json',
    String? jsonContent,
    bool resume = true,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final String rawJson;
      if (jsonContent != null) {
        rawJson = jsonContent;
      } else {
        rawJson = await rootBundle.loadString(assetPath);
      }

      final script = StoryParser.parse(rawJson);
      final prefs = await SharedPreferences.getInstance();
      final savedNodeId = resume ? prefs.getString('$_prefPrefix${script.storyId}') : null;

      StoryNode? initialNode;
      if (savedNodeId != null && script.nodes.containsKey(savedNodeId)) {
        initialNode = script.nodes[savedNodeId];
      } else {
        initialNode = script.startNode;
      }

      state = state.copyWith(
        script: script,
        currentNode: initialNode,
        isCompleted: initialNode?.choices.isEmpty ?? false,
        isLoading: false,
        historyNodeIds: initialNode != null ? [initialNode.id] : [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải câu chuyện: $e',
      );
    }
  }

  /// Người dùng chọn một phản hồi / ngã rẽ trong hội thoại
  Future<void> selectChoice(StoryChoice choice) async {
    final currentScript = state.script;
    if (currentScript == null) return;

    // 1. Nếu lựa chọn kích hoạt mini-game
    if (choice.isMinigameTrigger) {
      state = state.copyWith(
        pendingMinigameType: choice.minigameType,
        pendingNextNodeId: choice.nextNodeId,
      );
      return;
    }

    // 2. Nếu lựa chọn kết thúc câu chuyện
    if (choice.isCompleteStory || choice.nextNodeId == null || choice.nextNodeId!.isEmpty) {
      await _markStoryCompleted();
      return;
    }

    // 3. Chuyển sang node tiếp theo
    final targetNode = currentScript.getNode(choice.nextNodeId!);
    if (targetNode != null) {
      await _transitionToNode(targetNode);
    }
  }

  /// Được gọi sau khi mini-game kết thúc để tiếp tục kịch bản
  Future<void> completeMinigameAndContinue() async {
    final nextId = state.pendingNextNodeId;
    final currentScript = state.script;

    state = state.copyWith(clearPendingMinigame: true);

    if (nextId != null && currentScript != null) {
      final nextNode = currentScript.getNode(nextId);
      if (nextNode != null) {
        await _transitionToNode(nextNode);
      }
    }
  }

  /// Chuyển trạng thái sang node mục tiêu và lưu vào SharedPreferences
  Future<void> _transitionToNode(StoryNode node) async {
    final currentScript = state.script;
    if (currentScript != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefPrefix${currentScript.storyId}', node.id);
    }

    state = state.copyWith(
      currentNode: node,
      isCompleted: node.choices.isEmpty,
      historyNodeIds: [...state.historyNodeIds, node.id],
    );
  }

  /// Đánh dấu kịch bản đã hoàn thành và dọn dẹp state
  Future<void> _markStoryCompleted() async {
    final currentScript = state.script;
    if (currentScript != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefPrefix${currentScript.storyId}');
    }

    state = state.copyWith(isCompleted: true);
  }

  /// Chơi lại từ đầu
  Future<void> resetStory() async {
    final currentScript = state.script;
    if (currentScript == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefPrefix${currentScript.storyId}');

    final startNode = currentScript.startNode;
    state = state.copyWith(
      currentNode: startNode,
      isCompleted: false,
      historyNodeIds: startNode != null ? [startNode.id] : [],
      clearPendingMinigame: true,
      clearError: true,
    );
  }
}

/// Provider toàn cục cho Story Controller
final storyControllerProvider =
    NotifierProvider<StoryController, StoryState>(() => StoryController());
