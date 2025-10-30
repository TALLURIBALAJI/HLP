import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';
import '../services/api_config.dart';

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({super.key});

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  List<dynamic> _myDonations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyDonations();
  }

  Future<void> _loadMyDonations() async {
    setState(() => _isLoading = true);
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Fetch user's donations from backend
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/donations?userId=${currentUser.uid}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _myDonations = responseData['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _myDonations = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading donations: $e');
      setState(() {
        _myDonations = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsCompleted(String donationId) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/donations/$donationId/complete'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Donation marked as completed!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload the list
        _loadMyDonations();
      } else {
        throw Exception('Failed to complete donation');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'inprogress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'inprogress':
        return 'In Progress';
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
        title: const Text('My Donations'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMyDonations,
              child: _myDonations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.volunteer_activism,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No donations yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start donating items to help others!',
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
                        itemCount: _myDonations.length,
                        itemBuilder: (context, index) {
                          final donation = _myDonations[index];
                          final status = donation['status']?.toString() ?? 'open';
                          final title = donation['title']?.toString() ?? 'No title';
                          final description = donation['description']?.toString() ?? '';
                          final category = donation['category']?.toString() ?? '';
                          final recipient = donation['recipientId'] as Map<String, dynamic>?;
                          final recipientName = recipient?['username']?.toString() ?? 'No one yet';
                          final recipientEmail = recipient?['email']?.toString() ?? '';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                // Navigate to donation details if needed
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
                                              color: Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.green.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              category,
                                              style: const TextStyle(
                                                color: Colors.green,
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
                                                      'This donation has been completed!',
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
                                                // Agreed button
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text('Accepted By'),
                                                          content: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              if (recipient != null)
                                                                Row(
                                                                  children: [
                                                                    const Icon(Icons.person, size: 40, color: Colors.green),
                                                                    const SizedBox(width: 12),
                                                                    Expanded(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            recipientName,
                                                                            style: const TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          if (recipientEmail.isNotEmpty)
                                                                            Text(
                                                                              recipientEmail,
                                                                              style: TextStyle(
                                                                                fontSize: 14,
                                                                                color: Colors.grey[600],
                                                                              ),
                                                                            ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              else
                                                                const Text(
                                                                  'No one has accepted this donation yet.',
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
                                                    icon: const Icon(Icons.handshake),
                                                    label: const Text('Agreed'),
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: Colors.green,
                                                      side: const BorderSide(color: Colors.green),
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
                                                    onPressed: () => _markAsCompleted(donation['_id']),
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
