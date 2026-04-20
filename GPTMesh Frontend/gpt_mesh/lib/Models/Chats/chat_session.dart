import 'package:gpt_mesh/Models/ChatMessage/chat_message.dart';

class ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;

  ChatSession({required this.id, required this.title, required this.messages});

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((msg) => msg.toJson()).toList(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List).map((msg) => ChatMessage.fromJson(msg)).toList(),
    );
  }
}
