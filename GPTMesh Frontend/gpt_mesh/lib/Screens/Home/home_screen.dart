import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpt_mesh/Components/Drawer/home_drawer.dart';
import 'package:gpt_mesh/Components/Dropdown/model_selector.dart';
import 'package:gpt_mesh/Components/VoiceInput/voice_input_bar.dart';
import 'package:gpt_mesh/Config/Theme/Services/chat_storage.dart';
import 'package:gpt_mesh/Models/ChatMessage/chat_message.dart';
import 'package:gpt_mesh/Models/Chats/chat_session.dart';
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
  //chats
  List<ChatSession> _chats = [];
  ChatSession? _currentChat;
  // chat messages
  final ScrollController _scrollController = ScrollController();
  AIModel _selectedModel = AIModel.gemini;

  // load chats on start
  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  // load chats from local storage
  Future<void> _loadChats() async {
    final chats = await ChatStorage.loadChats();

    setState(() {
      _chats = chats;
    });
    if (chats.isNotEmpty) {
      _currentChat = chats.first;
    } else {
      _createNewChat();
    }
  }

  // create new chat session and save on local storage
  void _createNewChat() {
    final newChat = ChatSession(
      id: DateTime.now().toString(),
      title: "New Chat",
      messages: [],
    );

    setState(() {
      _chats.insert(0, newChat);
      _currentChat = newChat;
    });

    ChatStorage.saveChats(_chats);
  }

  // delete chat session
  void _deleteChat(ChatSession chat) {
    setState(() {
      _chats.removeWhere((cht) => cht.id == chat.id);
      // handle current chat deletion
      if (_currentChat?.id == chat.id) {
        if (_chats.isNotEmpty) {
          _currentChat = _chats.first;
        } else {
          _createNewChat();
        }
      }
    });
    ChatStorage.saveChats(_chats);
  }

  // add a new message to the chat and scroll to the bottom
  void _addMessage(String text, bool isUser) {
    setState(() {
      _currentChat?.messages.add(ChatMessage(text: text, isUser: isUser));
      // Auto title update (ONLY first user message)
      if (_currentChat != null && _currentChat!.messages.length == 1 && isUser) {
        _currentChat!.title = text.length > 20 ? text.substring(0, 20) : text;
      }
    });

    ChatStorage.saveChats(_chats);
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
        // Uri.parse("http://192.168.0.102:3000/api/ai/ask"),
        Uri.parse("http://localhost:3000/api/ai/ask"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "prompt": text,
          "model": getModelName(_selectedModel).toLowerCase(),
        }),
      );

      final data = jsonDecode(response.body);
      setState(() {
        _currentChat!.messages.removeLast(); // remove "Thinking..."
      });
      _addMessage("${getModelName(_selectedModel)}:\n${data['text']}", false);
    } catch (error) {
      setState(() {
        _currentChat!.messages.removeLast();
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
            },
          ),
        ],
      ),

      // left drawer
      drawer: HomeDrawer(
        chats: _chats,
        currentChat: _currentChat,
        onSelectChat: (chat) {
          setState(() {
            _currentChat = chat;
          });
        },
        onCreateNewChat: _createNewChat,
        onDeleteChat: _deleteChat,
      ),

      // main screen
      body: Column(
        children: [
          // chats
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _currentChat?.messages.length ?? 0,
              itemBuilder: (context, index) {
                final msg = _currentChat!.messages[index];
                return ChatBubble(text: msg.text, isUser: msg.isUser);
              },
            ),
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
