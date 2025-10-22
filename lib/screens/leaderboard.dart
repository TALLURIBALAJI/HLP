import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';
import '../services/api_config.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/leaderboard/top?limit=100'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _leaderboard = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading leaderboard: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getBadgeName(int karma) {
    if (karma >= 601) return 'Community Legend';
    if (karma >= 301) return 'Compassion Leader';
    if (karma >= 151) return 'Community Contributor';
    if (karma >= 51) return 'Active Supporter';
    return 'Beginner Helper';
  }

  String _getBadgeEmoji(int karma) {
    if (karma >= 601) return '🌟';
    if (karma >= 301) return '💎';
    if (karma >= 151) return '🏆';
    if (karma >= 51) return '🎖️';
    return '🏅';
  }

  @override
  Widget build(BuildContext context) {

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
          Row(children: [
            Icon(Icons.emoji_events, color: AppTheme.warmGradient.colors.first), 
            const SizedBox(width: 8), 
            Text('Full Rankings', style: const TextStyle(fontWeight: FontWeight.bold)),
            Spacer(),
            IconButton(
              icon: Icon(Icons.refresh, size: 20),
              onPressed: _loadLeaderboard,
            ),
          ]),
          const SizedBox(height: 12),
          // Loading or content
          if (_isLoading)
            Center(child: Padding(
              padding: const EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ))
          else if (_leaderboard.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('No users yet', style: TextStyle(color: Colors.grey)),
            ))
          else
            // Leaderboard entries
            ..._leaderboard.asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;
              final username = user['username'] ?? 'User';
              final karma = user['karma'] ?? 0;
              final badge = _getBadgeName(karma);
              final emoji = _getBadgeEmoji(karma);
              final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';
              final isTop3 = index < 3;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isTop3 ? Color.fromARGB(255, 255, 249, 196) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isTop3 ? Colors.amber.shade200 : Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Rank
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isTop3 ? Colors.amber.shade600 : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '#${index + 1}',
                          style: TextStyle(
                            color: isTop3 ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primary.withOpacity(0.2),
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name and badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(emoji, style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                badge,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Karma points
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$karma',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'pts',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
