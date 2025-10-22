import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = List.generate(6, (i) => 'Chat with User ${i + 1}');

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, i) => ListTile(
          leading: CircleAvatar(child: Text(chats[i][5])),
          title: Text(chats[i]),
          subtitle: const Text('Last message preview...'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatWindow(name: chats[i])),
          ),
        ),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: chats.length,
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
  final messages = <Map<String, String>>[
    {'who': 'them', 'text': 'Hi, how can I help?'},
    {'who': 'me', 'text': 'I need help with groceries.'}
  ];

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
