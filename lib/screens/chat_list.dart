import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_api_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<dynamic> _chats = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final chats = await ChatApiService.getUserChats(currentUser.uid);
      if (mounted) {
        setState(() {
          _chats = chats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading chats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChats,
            tooltip: 'Refresh chats',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? const Center(
                  child: Text(
                    'No messages yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadChats,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, i) {
                      final chat = _chats[i];
                      final otherParticipant = chat['otherParticipant'];
                      final lastMessage = chat['lastMessage'] ?? 'No messages yet';
                      final username = otherParticipant?['username'] ?? 'Unknown User';
                      final email = otherParticipant?['email'] ?? '';
                      final firebaseUid = otherParticipant?['firebaseUid'] ?? '';

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            username.isNotEmpty ? username[0].toUpperCase() : 'U',
                          ),
                        ),
                        title: Text(username),
                        subtitle: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                otherUserId: firebaseUid,
                                otherUserName: username,
                                otherUserEmail: email,
                              ),
                            ),
                          ).then((_) => _loadChats()); // Refresh when returning
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(),
                    itemCount: _chats.length,
                  ),
                ),
      bottomNavigationBar: const SizedBox(height: 0),
    );
  }
}

class ChatWindow extends StatefulWidget {
  final String name;
  const ChatWindow({super.key, required this.name});

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  final controller = TextEditingController();
  final messages = <Map<String, String>>[]; // Empty - no default messages

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                final isMe = m['who'] == 'me';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m['text']!,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.mic)),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Message...'),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;
                    setState(() {
                      messages.add({'who': 'me', 'text': controller.text.trim()});
                      controller.clear();
                    });
                  },
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
