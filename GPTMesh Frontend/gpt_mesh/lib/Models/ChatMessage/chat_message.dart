class ChatMessage {
  final String text;
  final String role;

  ChatMessage({required this.text, required this.role});

  Map<String, dynamic> toJson() => {
    'text': text,
    'role': role,
  };

  factory ChatMessage.fromJson (Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      role: json['role'],
    );
  }
}