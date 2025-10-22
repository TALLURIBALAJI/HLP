import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login.dart';
import 'screens/signin.dart';
import 'screens/signup.dart';
import 'screens/home_shell.dart';
import 'screens/post_request.dart';
import 'screens/book_exchange.dart';
import 'screens/chat_list.dart';
import 'screens/profile.dart';
import 'screens/leaderboard.dart';
import 'screens/announcements.dart';
import 'screens/categories.dart';
import 'screens/image_upload_demo.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const AuthWrapper(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signin': (_) => const SignInScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/home': (_) => const HomeShell(),
        '/post': (_) => const PostRequestScreen(),
        '/books': (_) => const BookExchangeScreen(),
        '/chats': (_) => const ChatListScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/leaderboard': (_) => const LeaderboardScreen(),
        '/announcements': (_) => const AnnouncementsScreen(),
        '/categories': (_) => const CategoriesScreen(),
        '/image-upload-demo': (_) => const ImageUploadDemoScreen(),
      },
    );
  }
}

// Auth wrapper to check if user is logged in
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is logged in, go to home
        if (snapshot.hasData) {
          return const HomeShell();
        }
        
        // If not logged in, show login screen
        return const LoginScreen();
      },
    );
  }
}

