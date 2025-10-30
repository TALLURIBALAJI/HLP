import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../services/help_request_api_service.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  List<dynamic> _myPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyPosts();
  }

  Future<void> _loadMyPosts() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final posts = await HelpRequestApiService.getUserPosts(currentUser.uid);
      setState(() {
        _myPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsCompleted(String postId) async {
    try {
      final success = await HelpRequestApiService.completeHelpRequest(postId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Help request marked as completed!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMyPosts(); // Reload to remove completed post
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Posts'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myPosts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No posts yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first help request!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMyPosts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _myPosts.length,
                    itemBuilder: (context, index) {
                      final post = _myPosts[index];
                      final status = post['status']?.toString() ?? 'open';
                      final title = post['title']?.toString() ?? 'No title';
                      final description = post['description']?.toString() ?? '';
                      final category = post['category']?.toString() ?? '';
                      final helper = post['helperId'] as Map<String, dynamic>?;
                      final helperName = helper?['username']?.toString() ?? 'No one yet';
                      final helperEmail = helper?['email']?.toString() ?? '';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            // Navigate to a detailed view if needed
                            // For now, just show info
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
                                        color: AppTheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.primary.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          color: AppTheme.primary,
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
                              
                              // Buttons section - Complete button for ALL posts
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: status.toLowerCase() == 'completed'
                                    ? // For COMPLETED posts - show completed message
                                    Container(
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
                                                'This help request has been completed!',
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
                                    : // For OPEN and IN PROGRESS posts - show two buttons
                                        Row(
                                          children: [
                                            // Agreed button - shows who accepted
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () {
                                                  // Show dialog with accepter info
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text('Accepted By'),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          if (helper != null)
                                                            Row(
                                                              children: [
                                                                const Icon(Icons.person, size: 40, color: Colors.blue),
                                                                const SizedBox(width: 12),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        helperName,
                                                                        style: const TextStyle(
                                                                          fontSize: 16,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      if (helperEmail.isNotEmpty)
                                                                        Text(
                                                                          helperEmail,
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
                                                              'No one has accepted this request yet.',
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
                                                  foregroundColor: Colors.blue,
                                                  side: const BorderSide(color: Colors.blue),
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
                                                onPressed: () => _markAsCompleted(post['_id']),
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
    );
  }
}
