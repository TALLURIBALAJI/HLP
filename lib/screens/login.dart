import 'package:flutter/material.dart';
import '../theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Icon(Icons.link, size: 80, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 32),
                  const Text('Welcome to HelpLink', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text('Connect, Help, and Grow Together', style: TextStyle(fontSize: 16, color: Colors.white70), textAlign: TextAlign.center),
                  const SizedBox(height: 48),
                  SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () { Navigator.pushNamed(context, '/signin'); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 8), child: const Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, height: 56, child: OutlinedButton(onPressed: () { Navigator.pushNamed(context, '/signup'); }, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                  const SizedBox(height: 24),
                  TextButton(onPressed: () { Navigator.pushReplacementNamed(context, '/home'); }, child: const Text('Sign in as Guest', style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.underline))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
