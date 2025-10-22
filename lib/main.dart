import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/onboarding.dart';
import 'screens/home_shell.dart';
import 'screens/post_request.dart';
import 'screens/book_exchange.dart';
import 'screens/chat_list.dart';
import 'screens/profile.dart';
import 'screens/leaderboard.dart';
import 'screens/announcements.dart';
import 'screens/categories.dart';
import 'screens/signin.dart';
import 'screens/signup.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/home': (_) => const HomeShell(),
        '/post': (_) => const PostRequestScreen(),
        '/books': (_) => const BookExchangeScreen(),
        '/chats': (_) => const ChatListScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/leaderboard': (_) => const LeaderboardScreen(),
        '/announcements': (_) => const AnnouncementsScreen(),
        '/categories': (_) => const CategoriesScreen(),
        '/signin': (_) => const SignInScreen(),
        '/signup': (_) => const SignUpScreen(),
      },
    );
  }
}

