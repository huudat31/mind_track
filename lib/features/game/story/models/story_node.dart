import 'package:mind_track/features/game/widgets/muoi_den_widget.dart';

/// Các trạng thái cảm xúc của Muội Đen trong câu chuyện
enum StoryMood {
  happy,
  worried,
  thinking,
  determined;

  static StoryMood fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'happy':
      case 'vui':
        return StoryMood.happy;
      case 'worried':
      case 'lo_lang':
        return StoryMood.worried;
      case 'thinking':
      case 'suy_nghi':
        return StoryMood.thinking;
      case 'determined':
      case 'quyet_tam':
        return StoryMood.determined;
      default:
        return StoryMood.happy;
    }
  }

  SootMood toSootMood() {
    switch (this) {
      case StoryMood.happy:
        return SootMood.happy;
      case StoryMood.worried:
        return SootMood.worried;
      case StoryMood.thinking:
        return SootMood.thinking;
      case StoryMood.determined:
        return SootMood.calm;
    }
  }
}

/// Một lựa chọn rẽ nhánh trong hội thoại
class StoryChoice {
  final String text;
  final String? nextNodeId;
  final String? action;

  const StoryChoice({
    required this.text,
    this.nextNodeId,
    this.action,
  });

  factory StoryChoice.fromJson(Map<String, dynamic> json) {
    return StoryChoice(
      text: json['text'] as String? ?? '',
      nextNodeId: json['next_node_id'] as String?,
      action: json['action'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    if (nextNodeId != null) 'next_node_id': nextNodeId,
    if (action != null) 'action': action,
  };

  bool get isMinigameTrigger => action != null && action!.startsWith('start_minigame:');

  String? get minigameType {
    if (!isMinigameTrigger) return null;
    return action!.replaceFirst('start_minigame:', '').trim();
  }

  bool get isCompleteStory => action == 'complete_story';
}

/// Một mắt xích / node hội thoại trong câu chuyện
class StoryNode {
  final String id;
  final String speaker;
  final String text;
  final StoryMood mood;
  final List<StoryChoice> choices;

  const StoryNode({
    required this.id,
    required this.speaker,
    required this.text,
    required this.mood,
    required this.choices,
  });

  factory StoryNode.fromJson(Map<String, dynamic> json) {
    final choicesList = (json['choices'] as List<dynamic>?)
            ?.map((e) => StoryChoice.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    return StoryNode(
      id: json['id'] as String? ?? '',
      speaker: json['speaker'] as String? ?? 'muoi_den',
      text: json['text'] as String? ?? '',
      mood: StoryMood.fromString(json['mood'] as String?),
      choices: choicesList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'speaker': speaker,
    'text': text,
    'mood': mood.name,
    'choices': choices.map((c) => c.toJson()).toList(),
  };

  /// Kiểm tra xem node này có phải là kết thúc hành trình không
  bool get isEnding =>
      choices.isEmpty ||
      choices.any((c) => c.isCompleteStory || c.nextNodeId == null || c.nextNodeId!.isEmpty);
}

/// Toàn bộ kịch bản một câu chuyện
class StoryScript {
  final String storyId;
  final String title;
  final String contextTag;
  final String startNodeId;
  final Map<String, StoryNode> nodes;

  const StoryScript({
    required this.storyId,
    required this.title,
    required this.contextTag,
    required this.startNodeId,
    required this.nodes,
  });

  factory StoryScript.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'] as List<dynamic>? ?? [];
    final nodeMap = <String, StoryNode>{};

    for (final item in rawNodes) {
      if (item is Map<String, dynamic>) {
        final node = StoryNode.fromJson(item);
        if (node.id.isNotEmpty) {
          nodeMap[node.id] = node;
        }
      }
    }

    return StoryScript(
      storyId: json['story_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      contextTag: json['context_tag'] as String? ?? 'hoc_tap',
      startNodeId: json['start_node_id'] as String? ?? '',
      nodes: nodeMap,
    );
  }

  StoryNode? getNode(String id) => nodes[id];
  StoryNode? get startNode => nodes[startNodeId];
}
