import 'package:flutter/material.dart';
import 'screens/onboarding.dart';
import 'screens/home_feed.dart';
import 'screens/post_request.dart';
import 'screens/book_exchange.dart';
import 'screens/chat_list.dart';
import 'screens/profile.dart';
import 'screens/leaderboard.dart';
import 'screens/announcements.dart';
import 'screens/categories.dart';
import 'theme.dart';

void main() {
  runApp(const HelpLinkApp());
}

class HelpLinkApp extends StatelessWidget {
  const HelpLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HelpLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData(),
      home: const OnboardingScreen(),
      routes: {
        '/home': (_) => const HomeFeedScreen(),
        '/post': (_) => const PostRequestScreen(),
        '/books': (_) => const BookExchangeScreen(),
        '/chats': (_) => const ChatListScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/leaderboard': (_) => const LeaderboardScreen(),
        '/announcements': (_) => const AnnouncementsScreen(),
        '/categories': (_) => const CategoriesScreen(),
      },
    );
  }
}

