import 'package:flutter/material.dart';

import '../models/dummy.dart';
import '../theme.dart';
import 'ui_components.dart';

class HelpLinkBottomNav extends StatelessWidget {
  final int index;
  const HelpLinkBottomNav({super.key, required this.index});

  void _onTap(BuildContext context, int i) {
    switch (i) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/post');
        break;
      case 2:
        Navigator.pushNamed(context, '/chats');
        break;
      case 3:
        Navigator.pushNamed(context, '/leaderboard');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.grid_view, 'label': 'Post'},
      {'icon': Icons.chat, 'label': 'Chat'},
      {'icon': Icons.emoji_events, 'label': 'Leaderboard'},
      {'icon': Icons.person, 'label': 'Profile'},
    ];

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final active = i == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTap(context, i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: active
                              ? [BoxShadow(color: AppTheme.primary.withAlpha(40), blurRadius: 8, offset: const Offset(0, 4))]
                              : null,
                        ),
                        child: Icon(item['icon'] as IconData, color: active ? Colors.white : Colors.grey.shade600, size: 20),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['label'] as String,
                        style: TextStyle(fontSize: 12, color: active ? AppTheme.primary : Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class EmergencyFloatingButton extends StatelessWidget {
  const EmergencyFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'fab_emergency',
      backgroundColor: AppTheme.destructive,
      onPressed: () => showDialog(
        context: context,
        builder: (_) => const EmergencyDialog(),
      ),
      child: const Icon(Icons.warning),
    );
  }
}

class EmergencyDialog extends StatefulWidget {
  const EmergencyDialog({super.key});

  @override
  State<EmergencyDialog> createState() => _EmergencyDialogState();
}

class _EmergencyDialogState extends State<EmergencyDialog> {
  final desc = TextEditingController();
  final loc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Emergency Help'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Describe emergency')),
            const SizedBox(height: 8),
            TextField(controller: loc, decoration: const InputDecoration(labelText: 'Location (auto or manual)')),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                    onPressed: () {}, icon: const Icon(Icons.gps_fixed), label: const Text('Auto-detect')),
                const SizedBox(width: 8),
                GradientButton(onPressed: () => Navigator.of(context).pop(), child: Row(children: const [Icon(Icons.send, color: Colors.white), SizedBox(width: 8), Text('Send Alert')])),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class HelpCard extends StatelessWidget {
  final HelpRequest request;
  const HelpCard({super.key, required this.request});

  Color _urgencyColor(String u) {
    switch (u) {
      case 'High':
        return AppTheme.destructive;
      case 'Medium':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _emojiForCategory(request.category);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withAlpha((0.94 * 255).round()),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.06 * 255).round()), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [AvatarGradient(child: Text((request.user ?? 'A').substring(0,1))), const SizedBox(width: 8), Text(request.user ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold))]),
                Row(children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: _urgencyColor(request.urgency), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(request.category)
                ])
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: Text(icon)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(request.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 6), Text(request.description ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54))])),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.black45), const SizedBox(width: 4), Text('${request.distanceKm.toStringAsFixed(1)} km away', style: const TextStyle(color: Colors.black54))]),
                GradientButton(onPressed: () {}, child: const Text('Offer Help'))
              ],
            )
          ],
        ),
      ),
    );
  }

  String _emojiForCategory(String c) {
    switch (c) {
      case 'Books':
        return '📚';
      case 'Food':
        return '🍛';
      case 'Clothes':
        return '👕';
      case 'Medical':
        return '💊';
      case 'Elderly':
        return '👵';
      case 'Education':
        return '🎓';
      case 'Emergency':
        return '🚨';
      default:
        return '🔧';
    }
  }
}
