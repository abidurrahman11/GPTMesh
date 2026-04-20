import 'dart:convert';

import 'package:gpt_mesh/Models/Chats/chat_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatStorage {
  static const String key = 'chats';

  static Future<void> saveChats (List<ChatSession> chats) async {
    final prefs = await SharedPreferences.getInstance();

    final data = chats.map((chat) => jsonEncode(chat.toJson())).toList();

    await prefs.setStringList(key, data);
  }

  static Future<List<ChatSession>> loadChats() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(key);

    if (data == null) {
      return [];
    }

    return data.map((chat) => ChatSession.fromJson(jsonDecode(chat))).toList();
  }
}