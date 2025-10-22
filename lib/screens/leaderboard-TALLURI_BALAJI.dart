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

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final scale = (width / 400).clamp(0.85, 1.0);

          return ListView(
            padding: EdgeInsets.all(12 * scale),
            children: [
              // orange header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 28 * scale),
                decoration: BoxDecoration(color: AppTheme.warmGradient.colors.first, borderRadius: BorderRadius.circular(8)),
                child: Column(children: [
                  Icon(Icons.emoji_events, color: Colors.white, size: 28 * scale),
                  SizedBox(height: 6 * scale),
                  Text('Top Community Helpers', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: (Theme.of(context).textTheme.titleLarge?.fontSize ?? 20) * scale)),
                  SizedBox(height: 6 * scale),
                  Text('Celebrating those who make a difference', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70, fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) * scale)),
                ]),
              ),
              SizedBox(height: 12 * scale),
              Row(children: [
                Icon(Icons.emoji_events, color: AppTheme.warmGradient.colors.first), 
                SizedBox(width: 8 * scale), 
                Text('Full Rankings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * scale)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh, size: 20 * scale),
                  onPressed: _loadLeaderboard,
                ),
              ]),
              SizedBox(height: 12 * scale),
              // Loading or content
              if (_isLoading)
                Center(child: Padding(
                  padding: EdgeInsets.all(32 * scale),
                  child: CircularProgressIndicator(),
                ))
              else if (_leaderboard.isEmpty)
                Center(child: Padding(
                  padding: EdgeInsets.all(32 * scale),
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
                    margin: EdgeInsets.only(bottom: 8 * scale),
                    padding: EdgeInsets.all(12 * scale),
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
                          width: 32 * scale,
                          height: 32 * scale,
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
                                fontSize: 12 * scale,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        // Avatar
                        CircleAvatar(
                          radius: 20 * scale,
                          backgroundColor: AppTheme.primary.withOpacity(0.2),
                          child: Text(
                            initial,
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        // Name and badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * scale,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2 * scale),
                              Row(
                                children: [
                                  Text(emoji, style: TextStyle(fontSize: 12 * scale)),
                                  SizedBox(width: 4 * scale),
                                  Text(
                                    badge,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 11) * scale,
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
                                fontSize: (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) * scale,
                                color: Colors.orange,
                              ),
                            ),
                            Text(
                              'pts',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 10) * scale,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        }),
      ),
    ),
    );
  }
}
