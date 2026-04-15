import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpt_mesh/Components/Drawer/home_drawer.dart';
import 'package:gpt_mesh/Components/Dropdown/model_selector.dart';
import 'package:gpt_mesh/Components/VoiceInput/voice_input_bar.dart';
import 'package:gpt_mesh/Models/ChatMessage/chat_message.dart';
import 'package:gpt_mesh/Widgets/ChatBubble/chat_bubble.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // access the state of the input bar to update the text when voice input is received
  final GlobalKey<VoiceInputBarState> inputKey = GlobalKey();
  // chat messages
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  AIModel _selectedModel = AIModel.gemini;

  // add a new message to the chat and scroll to the bottom
  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
    // scroll to the bottom after a short delay to ensure the new message is rendered
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String getModelName(AIModel model) {
    switch (model) {
      case AIModel.gemini:
        return "Gemini";
      case AIModel.openai:
        return "OpenAI";
      case AIModel.claude:
        return "Claude";
      case AIModel.deepseek:
        return "DeepSeek";
    }
  }

  // 🤖 Simulate AI (replace with API later)
  Future<void> _handleUserMessage(String text) async {
    _addMessage(text, true);
    // loading effect
    _addMessage("Thinking...", false);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.102:3000/api/ai/ask"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "prompt": text,
          "model": getModelName(_selectedModel).toLowerCase(),
        }),
      );

      final data = jsonDecode(response.body);
      setState(() {
        _messages.removeLast(); // remove "Thinking..."
      });
      _addMessage("${getModelName(_selectedModel)}:\n${data['text']}", false);
    } catch (error) {
      setState(() {
        _messages.removeLast();
      });
      _addMessage("Error: $error", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EchoAssists"),

        // ai model selector menu
        actions: [
          ModelSelector(
            selectedModel: _selectedModel,
            onChanged: (model) {
              setState(() {
                _selectedModel = model;
              });
            }
          ),
        ],
      ),

      // left drawer
      drawer: HomeDrawer(),
      
      // main screen
      body: Column(
        children: [
          // chats
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ChatBubble(text: msg.text, isUser: msg.isUser);
              },
            )
          ),
          // input options
          VoiceInputBar(
            key: inputKey,
            onSendText: (text) {
              _handleUserMessage(text);
              print("Send $text");
            },
            onStartRecording: () {
              print("Start Recording");
            },
            onStopRecording: () {
              print("Stop Recording");
            },
          ),
        ],
      ),
    );
  }
}