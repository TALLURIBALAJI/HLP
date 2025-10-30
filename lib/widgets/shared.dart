import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/dummy.dart';
import '../theme.dart';
import '../services/help_request_api_service.dart';
import '../services/user_api_service.dart';
import 'ui_components.dart';

class HelpLinkBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int>? onTap;
  const HelpLinkBottomNav({super.key, required this.index, this.onTap});

  void _onTap(BuildContext context, int i) {
    if (onTap != null) return onTap!(i);
    // Default behavior: open the app shell at the requested tab so the bottom
    // navigation remains visible. We use pushReplacementNamed to avoid
    // stacking multiple shells.
    Navigator.pushReplacementNamed(context, '/home', arguments: i);
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
  final _descController = TextEditingController();
  final _locController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descController.dispose();
    _locController.dispose();
    super.dispose();
  }

  Future<void> _sendEmergencyAlert() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the emergency'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_locController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide location'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Import Firebase Auth at the top if not already imported
      final currentUser = await _getCurrentUser();
      
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Create emergency help request via API
      final result = await _createEmergencyRequest(
        firebaseUid: currentUser,
        description: _descController.text.trim(),
        location: _locController.text.trim(),
      );

      setState(() => _isSubmitting = false);

      if (result != null && mounted) {
        Navigator.of(context).pop(); // Close dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚨 EMERGENCY ALERT SENT! Help is on the way!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to home feed to see the emergency post
        Navigator.pushReplacementNamed(context, '/home', arguments: 0);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send alert: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _getCurrentUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      return currentUser?.uid;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _createEmergencyRequest({
    required String firebaseUid,
    required String description,
    required String location,
  }) async {
    try {
      // Ensure user exists in MongoDB
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await UserApiService.createOrUpdateUser(
          firebaseUid: firebaseUid,
          email: currentUser.email ?? '',
          username: currentUser.displayName ?? 'User',
          mobile: currentUser.phoneNumber ?? '',
        );
      }

      // Create emergency help request with highest priority
      final result = await HelpRequestApiService.createHelpRequest(
        firebaseUid: firebaseUid,
        title: '🚨 EMERGENCY: ${description.substring(0, description.length > 50 ? 50 : description.length)}',
        description: description,
        category: 'Emergency',
        urgency: 'High',
        location: {
          'address': location,
          'coordinates': [0.0, 0.0],
        },
        anonymous: false,
      );

      return result;
    } catch (e) {
      print('Error creating emergency request: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.destructive.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.warning_amber_rounded, color: AppTheme.destructive, size: 24),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Emergency Help', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Quick alert to community',
            style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Describe emergency *',
                hintText: 'What help do you need urgently?',
                prefixIcon: const Icon(Icons.emergency),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 3,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locController,
              decoration: InputDecoration(
                labelText: 'Location *',
                hintText: 'Enter your current location',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will notify nearby community members immediately',
                      style: TextStyle(fontSize: 11, color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _sendEmergencyAlert,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send),
          label: Text(_isSubmitting ? 'Sending...' : 'Send Alert'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.destructive,
            foregroundColor: Colors.white,
            minimumSize: const Size(120, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
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
