import 'package:flutter/material.dart';
import '../theme.dart';
// ...existing imports...

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 36, bottom: 24),
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
            child: Column(
              children: [
                const SizedBox(height: 8),
                CircleAvatar(radius: 36, backgroundColor: Colors.white24, child: Text('T', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white))),
                const SizedBox(height: 12),
                Text('TALLURI BALAJI', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('balabalaji6139@gmail.com', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                const SizedBox(height: 16),
                // progress bar row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Level 1 - Community Contributor', style: TextStyle(color: Colors.white70)), Text('0 / 100 pts', style: TextStyle(color: Colors.white70))]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(value: 0.0, minHeight: 10, backgroundColor: Colors.white24, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  ]),
                )
              ],
            ),
          ),

          // Stats cards
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(color: Color.fromARGB(255, 255, 244, 234), borderRadius: BorderRadius.circular(8)),
                  child: Column(children: [Text('0', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)), const SizedBox(height: 6), Text('Karma Points', style: TextStyle(color: Colors.orange))]),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(color: Color.fromARGB(255, 235, 245, 255), borderRadius: BorderRadius.circular(8)),
                  child: Column(children: [Text('5', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary)), const SizedBox(height: 6), Text('My Posts', style: TextStyle(color: AppTheme.primary))]),
                ),
              ),
            ]),
          ),

          // Achievements card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.emoji_events, color: AppTheme.primary), const SizedBox(width: 8), Text('Achievements', style: TextStyle(fontWeight: FontWeight.bold))]),
                const SizedBox(height: 12),
                Wrap(alignment: WrapAlignment.spaceEvenly, spacing: 12, runSpacing: 12, children: [
                  Column(children: [CircleAvatar(radius: 22, backgroundColor: Color.fromARGB(255, 255, 250, 235), child: Icon(Icons.star, color: Colors.orange)), const SizedBox(height: 6), Text('First Help')]),
                  Column(children: [CircleAvatar(radius: 22, backgroundColor: Color.fromARGB(255, 255, 250, 235), child: Icon(Icons.emoji_events, color: Colors.orange)), const SizedBox(height: 6), Text('Community Hero')]),
                  Column(children: [CircleAvatar(radius: 22, backgroundColor: Color.fromARGB(255, 244, 244, 244), child: Icon(Icons.verified, color: Colors.grey)), const SizedBox(height: 6), Text('Generous Heart')]),
                  Column(children: [CircleAvatar(radius: 22, backgroundColor: Color.fromARGB(255, 244, 244, 244), child: Icon(Icons.emoji_events_outlined, color: Colors.grey)), const SizedBox(height: 6), Text('Super Helper')]),
                ])
              ]),
            ),
          ),

          const SizedBox(height: 12),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(children: [
              SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, icon: const Icon(Icons.list, color: Colors.white), label: const Text('My Help Requests', style: TextStyle(color: Colors.white)))),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warmGradient.colors.first, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => Navigator.pushNamed(context, '/leaderboard'), icon: const Icon(Icons.emoji_events, color: Colors.white), label: const Text('View Leaderboard', style: TextStyle(color: Colors.white)))),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: OutlinedButton.icon(style: OutlinedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, icon: const Icon(Icons.logout), label: const Text('Logout'))),
            ]),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
