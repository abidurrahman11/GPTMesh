import 'package:flutter/material.dart';
import 'package:gpt_mesh/Models/Chats/chat_session.dart';

class HomeDrawer extends StatelessWidget {
  final List<ChatSession> chats;
  final ChatSession? currentChat;
  final Function(ChatSession) onSelectChat;
  final VoidCallback onCreateNewChat;
  final Function(ChatSession) onDeleteChat;

  const HomeDrawer({
    super.key,
    required this.chats,
    required this.currentChat,
    required this.onSelectChat,
    required this.onCreateNewChat,
    required this.onDeleteChat,
  });

  void _showDeleteDialog(BuildContext context, ChatSession chat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Chat"),
          content: const Text("Are you sure you want to delete this chat?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDeleteChat(chat);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline),
                  SizedBox(width: 10),
                  Text(
                    "Your Chats",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Chat List
            Expanded(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final isSelected = chat.id == currentChat?.id;

                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    leading: const Icon(Icons.chat),
                    title: Text(
                      chat.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      // delete chat
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () {
                        _showDeleteDialog(context, chat);
                      },
                    ),
                    onTap: () {
                      onSelectChat(chat);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),

            const Divider(),

            // New Chat Button
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: () {
                  onCreateNewChat();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add),
                label: const Text("New Chat"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
