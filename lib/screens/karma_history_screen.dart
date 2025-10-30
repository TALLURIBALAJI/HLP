import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/help_request_api_service.dart';
import '../services/user_api_service.dart';
import '../theme.dart';

class KarmaHistoryScreen extends StatefulWidget {
  const KarmaHistoryScreen({super.key});

  @override
  State<KarmaHistoryScreen> createState() => _KarmaHistoryScreenState();
}

class _KarmaHistoryScreenState extends State<KarmaHistoryScreen> {
  List<Map<String, dynamic>> _karmaHistory = [];
  bool _isLoading = true;
  int _totalKarma = 0;

  @override
  void initState() {
    super.initState();
    _loadKarmaHistory();
  }

  Future<void> _loadKarmaHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Fetch user's posts to calculate karma
      final myPosts = await HelpRequestApiService.getUserPosts(currentUser.uid);
      final acceptedPosts = await HelpRequestApiService.getAcceptedPosts(currentUser.uid);
      
      List<Map<String, dynamic>> history = [];

      // Add karma for created posts (+2 each)
      for (var post in myPosts) {
        history.add({
          'action': 'Creating a help request',
          'title': post['title'] ?? 'Untitled',
          'points': 2,
          'icon': Icons.add_circle,
          'color': Colors.blue,
          'date': post['createdAt'] ?? DateTime.now().toString(),
        });
      }

      // Add karma for accepted posts (+10 each for accepting)
      for (var post in acceptedPosts) {
        if (post['status']?.toString().toLowerCase() == 'inprogress' || 
            post['status']?.toString().toLowerCase() == 'completed') {
          history.add({
            'action': 'Offering help / accepting a request',
            'title': post['title'] ?? 'Untitled',
            'points': 10,
            'icon': Icons.volunteer_activism,
            'color': Colors.green,
            'date': post['acceptedAt'] ?? post['updatedAt'] ?? DateTime.now().toString(),
          });
        }
      }

      // Add karma for completed posts (+20 each for completing)
      for (var post in acceptedPosts) {
        if (post['status']?.toString().toLowerCase() == 'completed') {
          history.add({
            'action': 'Completing a help request (verified by seeker)',
            'title': post['title'] ?? 'Untitled',
            'points': 20,
            'icon': Icons.check_circle,
            'color': Colors.purple,
            'date': post['completedAt'] ?? post['updatedAt'] ?? DateTime.now().toString(),
          });
        }
      }

      // Sort by date (newest first)
      history.sort((a, b) => b['date'].toString().compareTo(a['date'].toString()));

      // Get actual karma from backend user data
      final userData = await UserApiService.getUserByFirebaseUid(currentUser.uid);
      final backendKarma = userData?['karma'] ?? 0;

      setState(() {
        _karmaHistory = history;
        _totalKarma = backendKarma;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading karma history: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return 'Today';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Recent';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Karma History'),
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadKarmaHistory,
              child: Column(
                children: [
                  // Total Karma Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.orange.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Karma Points',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_totalKarma',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_karmaHistory.length} activities',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // History List
                  Expanded(
                    child: _karmaHistory.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 80,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No karma history yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start helping others to earn karma!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _karmaHistory.length,
                            itemBuilder: (context, index) {
                              final item = _karmaHistory[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: item['color'].withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      item['icon'],
                                      color: item['color'],
                                      size: 28,
                                    ),
                                  ),
                                  title: Text(
                                    item['action'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        item['title'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(item['date']),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      '+${item['points']}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
