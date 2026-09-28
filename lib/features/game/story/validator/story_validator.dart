import 'package:mind_track/features/game/story/models/story_node.dart';

/// Kết quả kiểm định tính hợp lệ của cây kịch bản Story
class StoryValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const StoryValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  @override
  String toString() =>
      'StoryValidationResult(isValid: $isValid, errors: ${errors.length}, warnings: ${warnings.length})';
}

/// Bộ kiểm tra tính toàn vẹn của kịch bản Story
/// Đảm bảo không có broken link, không có dead end, và mọi đường đi đều dẫn tới kết thúc
class StoryValidator {
  static StoryValidationResult validate(StoryScript script) {
    final errors = <String>[];
    final warnings = <String>[];

    if (script.nodes.isEmpty) {
      errors.add('Kịch bản không có node nào.');
      return StoryValidationResult(isValid: false, errors: errors, warnings: warnings);
    }

    // 1. Kiểm tra start node
    if (script.startNodeId.isEmpty || !script.nodes.containsKey(script.startNodeId)) {
      errors.add('Start node "${script.startNodeId}" không tồn tại trong danh sách node.');
    }

    // 2. Kiểm tra broken links (liên kết gãy)
    final endingNodeIds = <String>{};
    for (final entry in script.nodes.entries) {
      final nodeId = entry.key;
      final node = entry.value;

      if (node.isEnding) {
        endingNodeIds.add(nodeId);
      }

      for (final choice in node.choices) {
        final target = choice.nextNodeId;
        if (target != null && target.isNotEmpty) {
          if (!script.nodes.containsKey(target)) {
            errors.add('Node "$nodeId" có lựa chọn trỏ tới node không tồn tại: "$target".');
          }
        }
      }
    }

    if (endingNodeIds.isEmpty) {
      errors.add('Kịch bản không có node kết thúc (ending node) nào.');
    }

    // 3. Tìm tập hợp tất cả các node có thể tiếp cận từ start node (Forward Reachability)
    final reachableFromStart = <String>{};
    if (script.nodes.containsKey(script.startNodeId)) {
      final queue = <String>[script.startNodeId];
      reachableFromStart.add(script.startNodeId);

      while (queue.isNotEmpty) {
        final currentId = queue.removeAt(0);
        final currentNode = script.nodes[currentId]!;

        for (final choice in currentNode.choices) {
          final target = choice.nextNodeId;
          if (target != null && target.isNotEmpty && script.nodes.containsKey(target)) {
            if (!reachableFromStart.contains(target)) {
              reachableFromStart.add(target);
              queue.add(target);
            }
          }
        }
      }
    }

    // Cảnh báo node mồ côi (unreachable nodes)
    for (final nodeId in script.nodes.keys) {
      if (!reachableFromStart.contains(nodeId)) {
        warnings.add('Node "$nodeId" không thể tiếp cận được từ start node.');
      }
    }

    // 4. Kiểm tra dead ends (Backward Reachability từ ending nodes)
    // Xây dựng đồ thị ngược (Reverse Adjacency List)
    final reverseAdj = <String, Set<String>>{};
    for (final nodeId in script.nodes.keys) {
      reverseAdj[nodeId] = <String>{};
    }

    for (final entry in script.nodes.entries) {
      final u = entry.key;
      for (final choice in entry.value.choices) {
        final v = choice.nextNodeId;
        if (v != null && v.isNotEmpty && script.nodes.containsKey(v)) {
          reverseAdj[v]!.add(u);
        }
      }
    }

    // BFS từ tất cả ending nodes ngược về trước
    final canReachEnding = <String>{...endingNodeIds};
    final backwardQueue = <String>[...endingNodeIds];

    while (backwardQueue.isNotEmpty) {
      final current = backwardQueue.removeAt(0);
      final predecessors = reverseAdj[current] ?? const {};

      for (final pred in predecessors) {
        if (!canReachEnding.contains(pred)) {
          canReachEnding.add(pred);
          backwardQueue.add(pred);
        }
      }
    }

    // Bất kỳ node nào tiếp cận được từ start mà không thể đi tới ending -> Dead End
    for (final nodeId in reachableFromStart) {
      if (!canReachEnding.contains(nodeId)) {
        errors.add('Dead end phát hiện: Node "$nodeId" không có đường dẫn nào tới ending node.');
      }
    }

    return StoryValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}
