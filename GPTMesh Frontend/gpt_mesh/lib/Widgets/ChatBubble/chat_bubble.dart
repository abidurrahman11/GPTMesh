import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        constraints: BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        // Chat UI
        child: isUser
            ? Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            )
            : MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                  height: 1.5,
                ),
                h1: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                h2: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                code: TextStyle(
                  backgroundColor: Colors.black12,
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                codeblockDecoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.black
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                blockquote: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                listBullet: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
      ),
    );
  }
}