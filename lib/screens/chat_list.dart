import 'package:flutter/material.dart';
import '../theme.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now we show empty state (no conversations)
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Messages', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Stay connected with your community', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 12),
          // search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search conversations...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
          ),
          const SizedBox(height: 12),
          // empty state box
          Container(
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(radius: 28, backgroundColor: AppTheme.primary.withAlpha(40), child: Icon(Icons.chat_bubble, color: AppTheme.primary)),
              const SizedBox(height: 12),
              Text('No conversations yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Start helping others to begin chatting!', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
            ]),
          ),
        ],
      ),
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
    {'who': 'them', 'text': 'Hi, how can I help?', 'time': '2:15 PM'},
    {'who': 'me', 'text': 'I need help with groceries.', 'time': '2:16 PM'}
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
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: isMe ? AppTheme.primaryGradient : null,
                          color: isMe ? null : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          m['text']!,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(m['time']!, style: const TextStyle(fontSize: 11, color: Colors.black45)),
                      )
                    ],
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
