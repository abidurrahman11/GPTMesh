import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatBubble extends StatefulWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  // initialize text to speech
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    // Listen for completion to reset the icon automatically
    // 1. When speech starts, ensure icon is 'Stop'
    flutterTts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
    });

    // 2. When speech finishes naturally
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });

    // 3. When speech is interrupted or stopped manually
    flutterTts.setCancelHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  // method for text to speech
  Future<void> _handleSpeech() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    } else {
      setState(() {
        isSpeaking = true;
      });
      await flutterTts.setLanguage("en-US");
      await flutterTts.speak(widget.text);
    }
  }

  // copy message to clipboard
  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Copied to Clipboard"),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        constraints: BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: widget.isUser
              ? theme.colorScheme.primary
              : theme.brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        // Chat UI
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.isUser
                ? Text(
                    widget.text,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  )
                : MarkdownBody(
                    data: widget.text,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      h1: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                      listBullet: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ),

            // show speech button and copy option
            if (!widget.isUser) ...[
              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 0.5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _handleSpeech,
                    icon: Icon(
                      isSpeaking ? Icons.stop : Icons.volume_up,
                      size: 18,
                    ),
                    tooltip: isSpeaking ? "Stop" : "Listen",
                    visualDensity: VisualDensity.compact,
                    color: isSpeaking ? Colors.red : theme.colorScheme.primary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () => _copyToClipboard(context),
                    tooltip: 'Copy',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
