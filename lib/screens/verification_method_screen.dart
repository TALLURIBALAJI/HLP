import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';

class VerificationMethodScreen extends StatefulWidget {
  const VerificationMethodScreen({super.key});

  @override
  State<VerificationMethodScreen> createState() => _VerificationMethodScreenState();
}

class _VerificationMethodScreenState extends State<VerificationMethodScreen> {
  bool _isLoading = false;
  String? _verificationId;

  Future<void> _sendEmailVerification(Map<String, dynamic> userData) async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/otp-verification',
          arguments: {
            'type': 'email',
            'contact': userData['email'],
            'userData': userData,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPhoneVerification(Map<String, dynamic> userData) async {
    setState(() => _isLoading = true);

    try {
      final phoneNumber = userData['mobile'] as String;
      final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (on some Android devices)
          await FirebaseAuth.instance.currentUser?.updatePhoneNumber(credential);
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/otp-verification',
              arguments: {
                'type': 'phone',
                'contact': formattedPhone,
                'verificationId': '',
                'userData': userData,
              },
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send OTP: ${e.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
          
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/otp-verification',
              arguments: {
                'type': 'phone',
                'contact': formattedPhone,
                'verificationId': verificationId,
                'userData': userData,
              },
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() => _verificationId = verificationId);
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      
      String errorMessage = 'Failed to send OTP';
      String detailedError = e.toString();
      
      // Check for specific Firebase errors
      if (detailedError.contains('BILLING_NOT_ENABLED')) {
        errorMessage = '❌ Phone OTP requires Firebase Billing enabled.\n\n'
            'Redirecting to Email Verification...';
        
        // Auto-redirect to email verification after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _sendEmailVerification(userData);
          }
        });
      } else if (detailedError.contains('TOO_MANY_REQUESTS')) {
        errorMessage = '⏳ Too many OTP requests. Please try again later.';
      } else if (detailedError.contains('INVALID_PHONE_NUMBER')) {
        errorMessage = '❌ Invalid phone number format';
      } else {
        errorMessage = '❌ $detailedError';
      }
      
      print('🚨 Phone verification error: $detailedError');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: detailedError.contains('BILLING_NOT_ENABLED')
                ? SnackBarAction(
                    label: 'Use Email',
                    textColor: Colors.white,
                    onPressed: () => _sendEmailVerification(userData),
                  )
                : null,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (userData == null) {
      Future.microtask(() => Navigator.pop(context));
      return const Scaffold();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user,
                  size: 80,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Choose Verification Method',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Select how you want to verify your account',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Email verification option
              _buildVerificationOption(
                icon: Icons.email_outlined,
                title: 'Verify via Email',
                subtitle: userData['email'],
                onTap: () => _sendEmailVerification(userData),
              ),
              const SizedBox(height: 16),

              // Phone verification option
              _buildVerificationOption(
                icon: Icons.phone_android,
                title: 'Verify via Phone',
                subtitle: userData['mobile'],
                onTap: () => _sendPhoneVerification(userData),
                badge: '⚠️ Requires Billing',
                badgeColor: Colors.orange,
              ),
              
              // Info message
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Phone OTP requires Firebase Blaze plan. Use Email verification for now.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              if (_isLoading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Sending verification...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor?.withOpacity(0.2) ?? Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeColor ?? Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
