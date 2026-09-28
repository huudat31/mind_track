import 'dart:convert';
import 'package:mind_track/features/game/story/models/story_node.dart';

/// Bộ phân tích dữ liệu JSON cho kịch bản hội thoại
class StoryParser {
  /// Phân tích chuỗi JSON sang đối tượng [StoryScript]
  static StoryScript parse(String jsonString) {
    if (jsonString.trim().isEmpty) {
      throw const FormatException('Chuỗi JSON câu chuyện không được để trống.');
    }

    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Cấu trúc JSON không hợp lệ, yêu cầu một Map.');
    }

    return StoryScript.fromJson(decoded);
  }
}
