import 'package:flutter/material.dart';
import '../theme.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now we show empty state (no conversations)
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            final scale = (width / 400).clamp(0.85, 1.0);

            return ListView(
              padding: EdgeInsets.all(12 * scale),
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 24 * scale, horizontal: 12 * scale),
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(8)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Messages', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: (Theme.of(context).textTheme.titleLarge?.fontSize ?? 20) * scale)),
                    SizedBox(height: 6 * scale),
                    Text('Stay connected with your community', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * scale)),
                  ]),
                ),
                SizedBox(height: 12 * scale),
                // search
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                  child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search conversations...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
                ),
                SizedBox(height: 12 * scale),
                // empty state box
                Container(
                  height: 220 * scale,
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    CircleAvatar(radius: 28 * scale, backgroundColor: AppTheme.primary.withAlpha(40), child: Icon(Icons.chat_bubble, color: AppTheme.primary, size: 24 * scale)),
                    SizedBox(height: 12 * scale),
                    Text('No conversations yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) * scale)),
                    SizedBox(height: 6 * scale),
                    Text('Start helping others to begin chatting!', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) * scale)),
                  ]),
                ),
              ],
            );
          }),
        ),
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
