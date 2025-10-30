import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';
import '../services/api_config.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<dynamic> _myEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyEvents();
  }

  Future<void> _loadMyEvents() async {
    setState(() => _isLoading = true);
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Fetch user's events from backend
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/events?organizerId=${currentUser.uid}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _myEvents = responseData['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _myEvents = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading events: $e');
      setState(() {
        _myEvents = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsCompleted(String eventId) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/events/$eventId/complete'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Event marked as completed!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          _loadMyEvents(); // Reload the list
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to complete event: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return 'Upcoming';
      case 'ongoing':
        return 'Ongoing';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Events'),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMyEvents,
              child: _myEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create or join events to help the community!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: _myEvents.length,
                        itemBuilder: (context, index) {
                          final event = _myEvents[index];
                          final status = event['status']?.toString() ?? 'upcoming';
                          final title = event['title']?.toString() ?? 'No title';
                          final description = event['description']?.toString() ?? '';
                          final category = event['category']?.toString() ?? '';
                          final participants = event['participants'] as List<dynamic>?;
                          final participantCount = participants?.length ?? 0;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                // Navigate to event details if needed
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Status badge
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusBackgroundColor(status),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _getStatusColor(status),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (category.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.purple.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.purple.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              category,
                                              style: const TextStyle(
                                                color: Colors.purple,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Title
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Description
                                    Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    
                                    // Buttons section
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: status.toLowerCase() == 'completed'
                                          ? Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.check_circle, size: 20, color: Colors.green[700]),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'This event has been completed!',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.green[700],
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                // Volunteers button
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text('Volunteers'),
                                                          content: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              if (participantCount > 0)
                                                                Text(
                                                                  '$participantCount volunteers have joined this event.',
                                                                  style: const TextStyle(
                                                                    fontSize: 14,
                                                                  ),
                                                                )
                                                              else
                                                                const Text(
                                                                  'No volunteers have joined yet.',
                                                                  style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontStyle: FontStyle.italic,
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context),
                                                              child: const Text('Close'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(Icons.people),
                                                    label: const Text('Volunteers'),
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: Colors.purple,
                                                      side: const BorderSide(color: Colors.purple),
                                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // Completed button
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () => _markAsCompleted(event['_id']),
                                                    icon: const Icon(Icons.check_circle),
                                                    label: const Text('Completed'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.green,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
    );
  }
}
