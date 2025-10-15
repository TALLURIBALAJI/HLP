import 'package:flutter/material.dart';
import '../widgets/ui_components.dart' as ui;

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = List.generate(6, (i) => {
      'title': 'Community Drive ${i + 1}',
      'type': i % 2 == 0 ? 'Volunteer Drive' : 'Donation Campaign',
      'date': 'Oct ${16 + i}, 2025',
      'location': 'Community Center',
      'participants': '${10 + i * 5}'
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Community Events')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: events.length,
        itemBuilder: (context, i) {
          final e = events[i];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${e['title']}'), ui.Badge(text: e['type']!, color: Colors.blue)]),
                  const SizedBox(height: 8),
                  Text('${e['date']} • ${e['location']}'),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${e['participants']} participants'), ui.GradientButton(onPressed: () {}, child: const Text('Join Event'))])
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
