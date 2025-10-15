import 'package:flutter/material.dart';
import 'home_feed.dart';
import 'post_request.dart';
import 'chat_list.dart';
import 'leaderboard.dart';
import 'profile.dart';
import '../widgets/shared.dart';
import '../theme.dart';

class HomeShell extends StatefulWidget {
  final int initialIndex;
  const HomeShell({super.key, this.initialIndex = 0});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _index = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const HomeFeedScreen(),
      const PostRequestScreen(),
      const ChatListScreen(),
      const LeaderboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(index: _index, children: tabs),
      floatingActionButton: _index == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'fab_post_shell',
                  onPressed: () => setState(() => _index = 1),
                  backgroundColor: AppTheme.warmGradient.colors.first,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 12),
                const EmergencyFloatingButton(),
              ],
            )
          : null,
      bottomNavigationBar: HelpLinkBottomNav(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
