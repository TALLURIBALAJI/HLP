import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import 'chat_screen.dart';
import '../services/help_request_api_service.dart';

class HelpRequestDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> helpRequest;

  const HelpRequestDetailsScreen({
    super.key,
    required this.helpRequest,
  });

  @override
  State<HelpRequestDetailsScreen> createState() => _HelpRequestDetailsScreenState();
}

class _HelpRequestDetailsScreenState extends State<HelpRequestDetailsScreen> {
  bool _isProcessing = false;

  Future<void> _acceptHelpRequest() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isProcessing = true);
    
    try {
      await HelpRequestApiService.acceptHelpRequest(
        widget.helpRequest['_id'],
        currentUser.uid,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Help request accepted! +10 Karma earned!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Refresh the screen
        setState(() {
          widget.helpRequest['status'] = 'accepted';
          widget.helpRequest['acceptedBy'] = currentUser.uid;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _completeHelpRequest() async {
    setState(() => _isProcessing = true);
    
    try {
      await HelpRequestApiService.completeHelpRequest(widget.helpRequest['_id']);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Help request completed! +20 Karma earned!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Refresh the screen
        setState(() {
          widget.helpRequest['status'] = 'completed';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.helpRequest['title']?.toString() ?? 'No title';
    final description = widget.helpRequest['description']?.toString() ?? 'No description';
    final urgency = widget.helpRequest['urgency']?.toString() ?? 'Medium';
    final category = widget.helpRequest['category']?.toString() ?? 'Other';
    
    // Handle location - it could be a string or an object with address field
    String location;
    if (widget.helpRequest['location'] is Map) {
      location = widget.helpRequest['location']['address']?.toString() ?? 'Location not provided';
    } else {
      location = widget.helpRequest['location']?.toString() ?? 'Location not provided';
    }
    
    final status = widget.helpRequest['status']?.toString() ?? 'open';
    
    // Get requester info - the field is called 'userId' in the backend
    final requester = widget.helpRequest['userId'] as Map<String, dynamic>?;
    final requesterName = requester?['username']?.toString() ?? 'Anonymous';
    final requesterId = requester?['firebaseUid']?.toString() ?? '';
    final requesterEmail = requester?['email']?.toString() ?? '';
    
    // Get accepted by info
    final acceptedBy = widget.helpRequest['acceptedBy'];
    
    print('🔍 Debug Help Request:');
    print('   Full request: ${widget.helpRequest}');
    print('   Requester: $requester');
    print('   Requester Name: $requesterName');
    print('   Requester ID: $requesterId');
    print('   Status: $status');
    print('   Accepted By: $acceptedBy');
    
    // Get current user
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwnPost = currentUser?.uid == requesterId;
    final isAcceptedByCurrentUser = acceptedBy == currentUser?.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help Request Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Urgency badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getUrgencyColor(urgency),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      urgency.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  _buildInfoCard(
                    icon: Icons.category_outlined,
                    title: 'Category',
                    content: category,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  _buildInfoCard(
                    icon: Icons.description_outlined,
                    title: 'Description',
                    content: description,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),

                  // Location
                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    content: location,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),

                  // Status
                  _buildInfoCard(
                    icon: Icons.info_outline,
                    title: 'Status',
                    content: status.toUpperCase(),
                    color: status == 'open' ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 16),

                  // Requester info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.primary.withOpacity(0.2),
                          child: Text(
                            requesterName.isNotEmpty ? requesterName[0].toUpperCase() : 'A',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Posted by',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                requesterName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons based on status
                  if (status == 'open' && !isOwnPost)
                    // Accept Help Request Button (+10 Karma)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _acceptHelpRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.volunteer_activism, color: Colors.white),
                        label: Text(
                          _isProcessing ? 'Accepting...' : 'Accept Help Request (+10 Karma)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (status == 'accepted' && isAcceptedByCurrentUser)
                    // Complete Help Request Button (+20 Karma)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _completeHelpRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle, color: Colors.white),
                        label: Text(
                          _isProcessing ? 'Completing...' : 'Mark as Completed (+20 Karma)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (status == 'accepted' && isOwnPost)
                    // Info for requester waiting for completion
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.pending_actions, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Help request accepted. Waiting for helper to mark as completed.',
                              style: TextStyle(color: Colors.orange.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (status == 'completed')
                    // Completed Badge
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            '✅ Help Request Completed!',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Message button (only if not own post and not completed)
                  if (!isOwnPost && status != 'completed')
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          print('🔵 Send Message button clicked');
                          print('   Other User ID: $requesterId');
                          print('   Other User Name: $requesterName');
                          print('   Other User Email: $requesterEmail');
                          
                          if (requesterId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error: User information not available'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          // Navigate to chat screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                otherUserId: requesterId,
                                otherUserName: requesterName,
                                otherUserEmail: requesterEmail,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.message, color: Colors.white),
                        label: const Text(
                          'Send Message',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (isOwnPost)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This is your post. Others can message you to help.',
                              style: TextStyle(color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
