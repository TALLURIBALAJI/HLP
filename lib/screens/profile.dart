import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme.dart';
import '../services/user_api_service.dart';
import '../services/help_request_api_service.dart';
import '../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;
  Map<String, dynamic>? userData;
  int postsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔵 Profile: Loading data for user ${currentUser!.uid}');
      
      // Get user data from MongoDB
      final user = await UserApiService.getUserByFirebaseUid(currentUser!.uid);
      print('✅ User data: $user');
      
      // Get user's posts count - the backend will filter by Firebase UID
      final posts = await HelpRequestApiService.getUserPosts(currentUser!.uid);
      print('✅ Posts count: ${posts.length}');
      
      setState(() {
        userData = user;
        postsCount = posts.length;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  String get displayName => currentUser?.displayName ?? 'Guest User';
  String get email => currentUser?.email ?? 'Not signed in';
  String get initials {
    if (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty) {
      final names = currentUser!.displayName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return currentUser!.displayName![0].toUpperCase();
    }
    return currentUser?.email?[0].toUpperCase() ?? 'G';
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

  String _getBadgeDescription(int karma) {
    if (karma >= 601) return 'Top-level helper';
    if (karma >= 301) return 'Major community impact';
    if (karma >= 151) return 'Consistent contributor';
    if (karma >= 51) return 'Frequently participates';
    return 'Started helping others';
  }

  Widget _buildBadge(double scale, BuildContext context, String emoji, String name, String range, bool isUnlocked) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8 * scale),
          decoration: BoxDecoration(
            color: isUnlocked ? Color.fromARGB(255, 255, 250, 235) : Color.fromARGB(255, 244, 244, 244),
            shape: BoxShape.circle,
          ),
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: 24 * scale,
              color: isUnlocked ? null : Colors.grey,
            ),
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          name,
          style: TextStyle(
            fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 10) * scale,
            fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
            color: isUnlocked ? Colors.black87 : Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          range,
          style: TextStyle(
            fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 9) * scale,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Sign out from Google as well to clear cached account
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      
      // Remove OneSignal external user ID
      await NotificationService.removeExternalUserId();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/signin');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final karma = userData?['karma'] ?? 0;
    final level = karma ~/ 100 + 1;
    final progressInLevel = (karma % 100) / 100.0;

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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final scale = (width / 400).clamp(0.85, 1.0);

          return RefreshIndicator(
            onRefresh: _loadUserData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 36 * scale, bottom: 24 * scale),
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
                child: Column(
                  children: [
                    SizedBox(height: 8 * scale),
                    CircleAvatar(
                      radius: 36 * scale,
                      backgroundColor: Colors.white24,
                      backgroundImage: currentUser?.photoURL != null
                          ? NetworkImage(currentUser!.photoURL!)
                          : null,
                      child: currentUser?.photoURL == null
                          ? Text(
                              initials,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontSize: (Theme.of(context).textTheme.titleLarge?.fontSize ?? 20) * scale,
                                  ),
                            )
                          : null,
                    ),
                    SizedBox(height: 12 * scale),
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: (Theme.of(context).textTheme.titleLarge?.fontSize ?? 20) * scale,
                          ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * scale,
                          ),
                    ),
                    SizedBox(height: 16 * scale),
                    // progress bar row
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Level $level - Community Contributor', style: TextStyle(color: Colors.white70, fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) * scale)), 
                          Text('$karma / ${level * 100} pts', style: TextStyle(color: Colors.white70, fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) * scale))
                        ]),
                        SizedBox(height: 8 * scale),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(value: progressInLevel, minHeight: 10 * scale, backgroundColor: Colors.white24, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      ]),
                    )
                  ],
                ),
              ),

              // Stats cards
              Padding(
                padding: EdgeInsets.all(12.0 * scale),
                child: Row(children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16 * scale),
                      margin: EdgeInsets.only(right: 8 * scale),
                      decoration: BoxDecoration(color: Color.fromARGB(255, 255, 244, 234), borderRadius: BorderRadius.circular(8)),
                      child: Column(children: [
                        Text('$karma', style: TextStyle(fontSize: 22 * scale, fontWeight: FontWeight.bold, color: Colors.orange)), 
                        SizedBox(height: 6 * scale), 
                        Text('Karma Points', style: TextStyle(color: Colors.orange, fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) * scale))
                      ]),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16 * scale),
                      margin: EdgeInsets.only(left: 8 * scale),
                      decoration: BoxDecoration(color: Color.fromARGB(255, 235, 245, 255), borderRadius: BorderRadius.circular(8)),
                      child: Column(children: [
                        Text('$postsCount', style: TextStyle(fontSize: 22 * scale, fontWeight: FontWeight.bold, color: AppTheme.primary)), 
                        SizedBox(height: 6 * scale), 
                        Text('My Posts', style: TextStyle(color: AppTheme.primary, fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) * scale))
                      ]),
                    ),
                  ),
                ]),
              ),

              // Achievements card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0 * scale),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16 * scale),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(_getBadgeEmoji(karma), style: TextStyle(fontSize: 24 * scale)),
                      SizedBox(width: 8 * scale), 
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Badge', style: TextStyle(color: Colors.grey[600], fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) * scale)),
                            SizedBox(height: 4 * scale),
                            Text(_getBadgeName(karma), style: TextStyle(fontWeight: FontWeight.bold, fontSize: (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) * scale)),
                            SizedBox(height: 2 * scale),
                            Text(_getBadgeDescription(karma), style: TextStyle(color: Colors.grey[600], fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 11) * scale)),
                          ],
                        ),
                      ),
                    ]),
                    SizedBox(height: 16 * scale),
                    Divider(),
                    SizedBox(height: 8 * scale),
                    Text('All Badges', style: TextStyle(fontWeight: FontWeight.w600, fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 13) * scale, color: Colors.grey[700])),
                    SizedBox(height: 12 * scale),
                    Wrap(alignment: WrapAlignment.spaceEvenly, spacing: 12 * scale, runSpacing: 12 * scale, children: [
                      _buildBadge(scale, context, '🏅', 'Beginner Helper', '0-50', karma >= 0),
                      _buildBadge(scale, context, '🎖️', 'Active Supporter', '51-150', karma >= 51),
                      _buildBadge(scale, context, '🏆', 'Community Contributor', '151-300', karma >= 151),
                      _buildBadge(scale, context, '💎', 'Compassion Leader', '301-600', karma >= 301),
                      _buildBadge(scale, context, '🌟', 'Community Legend', '601+', karma >= 601),
                    ])
                  ]),
                ),
              ),

              SizedBox(height: 12 * scale),
              // Action buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0 * scale),
                child: Column(children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warmGradient.colors.first,
                        padding: EdgeInsets.symmetric(vertical: 14 * scale),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
                      icon: const Icon(Icons.emoji_events, color: Colors.white),
                      label: const Text('View Leaderboard', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  if (currentUser != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(vertical: 14 * scale),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: EdgeInsets.symmetric(vertical: 14 * scale),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.pushReplacementNamed(context, '/signin'),
                        icon: const Icon(Icons.login, color: Colors.white),
                        label: const Text('Sign In / Sign Up', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                ]),
              ),

              SizedBox(height: 16 * scale),
            ],
              ),
            ),
          );
        }),
      ),
    ),
    );
  }
}
