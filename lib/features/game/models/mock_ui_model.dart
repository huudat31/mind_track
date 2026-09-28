/// Loại người gửi trong giao diện giả lập đoạn chat
enum SenderType {
  me('me'),
  friend('friend'),
  mom('mom'),
  sibling('sibling');

  final String id;
  const SenderType(this.id);

  static SenderType fromId(String id) {
    return values.firstWhere(
      (s) => s.id == id,
      orElse: () => throw FormatException('SenderType không hợp lệ: "$id"'),
    );
  }

  String get displayName {
    switch (this) {
      case SenderType.me:
        return 'Tôi';
      case SenderType.friend:
        return 'Bạn thân';
      case SenderType.mom:
        return 'Mẹ';
      case SenderType.sibling:
        return 'Em';
    }
  }

  bool get isMe => this == SenderType.me;
}

/// Lớp niêm phong (Sealed class) cho các hình thức giao diện đời thực giả lập
sealed class MockUiData {
  final String type;
  const MockUiData(this.type);

  factory MockUiData.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == null) {
      throw const FormatException('mock_ui thiếu trường bắt buộc "type"');
    }
    return switch (type) {
      'chat' => MockUiChat.fromJson(json),
      'note' => MockUiNote.fromJson(json),
      'notification' => MockUiNotification.fromJson(json),
      'social_post' => MockUiSocialPost.fromJson(json),
      _ => throw FormatException('Không hỗ trợ mock_ui type: "$type"'),
    };
  }
}

/// Một tin nhắn đơn lẻ trong khung chat
class ChatMessage {
  final SenderType sender;
  final String text;
  final String timestamp;

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: SenderType.fromId(json['sender'] as String),
      text: json['text'] as String,
      timestamp: json['timestamp'] as String,
    );
  }
}

/// 1. Giao diện khung chat tin nhắn
class MockUiChat extends MockUiData {
  final List<ChatMessage> messages;

  const MockUiChat(this.messages) : super('chat');

  factory MockUiChat.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List?;
    if (rawMessages == null || rawMessages.isEmpty) {
      throw const FormatException('MockUiChat phải có ít nhất 1 message');
    }
    return MockUiChat(
      rawMessages
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 2. Giao diện trang sổ tay ghi chú
class MockUiNote extends MockUiData {
  final String content;
  final String date;

  const MockUiNote({
    required this.content,
    required this.date,
  }) : super('note');

  factory MockUiNote.fromJson(Map<String, dynamic> json) {
    return MockUiNote(
      content: json['content'] as String,
      date: json['date'] as String,
    );
  }
}

/// 3. Giao diện thông báo hệ thống (Notification banner)
class MockUiNotification extends MockUiData {
  final String title;
  final String body;
  final String time;

  const MockUiNotification({
    required this.title,
    required this.body,
    required this.time,
  }) : super('notification');

  factory MockUiNotification.fromJson(Map<String, dynamic> json) {
    return MockUiNotification(
      title: json['title'] as String,
      body: json['body'] as String,
      time: json['time'] as String,
    );
  }
}

/// 4. Giao diện bài đăng mạng xã hội giả lập
class MockUiSocialPost extends MockUiData {
  final String author;
  final String content;
  final String? image;
  final int likes;
  final int comments;
  final String time;

  const MockUiSocialPost({
    required this.author,
    required this.content,
    this.image,
    required this.likes,
    required this.comments,
    required this.time,
  }) : super('social_post');

  factory MockUiSocialPost.fromJson(Map<String, dynamic> json) {
    return MockUiSocialPost(
      author: json['author'] as String,
      content: json['content'] as String,
      image: json['image'] as String?,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      time: json['time'] as String,
    );
  }
}
