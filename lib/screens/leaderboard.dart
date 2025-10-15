import 'package:flutter/material.dart';
import '../theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final top = [
      {'name': 'TALLURI BALAJI', 'karma': '0', 'subtitle': 'Community Helper'}
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // orange header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(color: AppTheme.warmGradient.colors.first, borderRadius: BorderRadius.circular(8)),
            child: Column(children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 28),
              const SizedBox(height: 6),
              Text('Top Community Helpers', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Celebrating those who make a difference', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [Icon(Icons.emoji_events, color: AppTheme.warmGradient.colors.first), const SizedBox(width: 8), Text('Full Rankings', style: const TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          // top highlighted entry
          ...top.map((t) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Color.fromARGB(255, 255, 249, 196), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    CircleAvatar(backgroundColor: AppTheme.primary, child: Text('T', style: const TextStyle(color: Colors.white))),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t['name']!, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(t['subtitle']!, style: const TextStyle(color: Colors.black54))])
                  ]),
                  Text(t['karma']!, style: const TextStyle(fontWeight: FontWeight.bold))
                ]),
              ))
        ],
      ),
    );
  }
}
