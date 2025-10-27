import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../services/user_api_service.dart';
import '../services/notification_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpControllers = List.generate(6, (index) => TextEditingController());
  final _focusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isLoading = false;
  bool _isResending = false;
  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _timer;
  
  String _verificationId = '';
  String _verificationType = 'email'; // 'email' or 'phone'
  String _contactInfo = '';
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _verificationType = args['type'] ?? 'email';
          _contactInfo = args['contact'] ?? '';
          _verificationId = args['verificationId'] ?? '';
          _userData = args['userData'];
        });
        
        if (_verificationType == 'email') {
          _startEmailVerificationCheck();
        }
        _startResendTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _startEmailVerificationCheck() {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        timer.cancel();
        return;
      }

      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser?.emailVerified ?? false) {
        timer.cancel();
        await _completeVerification(updatedUser!);
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete OTP'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_verificationType == 'phone') {
        // Verify phone OTP
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: otp,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        await _completeVerification(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Verification failed';
      if (e.code == 'invalid-verification-code') {
        message = 'Invalid OTP. Please check and try again';
      } else if (e.code == 'session-expired') {
        message = 'OTP expired. Please request a new one';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeVerification(User user) async {
    try {
      // Sync user to MongoDB
      await UserApiService.createOrUpdateUser(
        firebaseUid: user.uid,
        email: _userData?['email'] ?? user.email!,
        username: _userData?['username'],
        mobile: _userData?['mobile'],
        profileImage: user.photoURL,
      );

      // Set up OneSignal
      await NotificationService.setExternalUserId(user.uid);
      final playerId = await NotificationService.getPlayerId();
      if (playerId != null) {
        await UserApiService.registerOneSignalPlayerId(user.uid, playerId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Verification successful!'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      print('Error completing verification: $e');
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend || _isResending) return;

    setState(() => _isResending = true);

    try {
      if (_verificationType == 'email') {
        final user = FirebaseAuth.instance.currentUser;
        await user?.sendEmailVerification();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Verification email sent!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Resend phone OTP
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: _contactInfo,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await _completeVerification(user);
            }
          },
          verificationFailed: (FirebaseAuthException e) {
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
            setState(() => _verificationId = verificationId);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ OTP sent!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            setState(() => _verificationId = verificationId);
          },
        );
      }

      _startResendTimer();
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
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _verificationType == 'email' ? Icons.email_outlined : Icons.phone_android,
                  size: 80,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                _verificationType == 'email' ? 'Verify Email' : 'Verify Phone',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                _verificationType == 'email'
                    ? 'Check your email and click the verification link, or wait for auto-verification'
                    : 'Enter the 6-digit code sent to',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Contact info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _contactInfo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // OTP input (only for phone)
              if (_verificationType == 'phone') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      height: 60,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          
                          // Auto-verify when all digits entered
                          if (index == 5 && value.isNotEmpty) {
                            _verifyOtp();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Verify OTP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],

              if (_verificationType == 'email') ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Waiting for email verification...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],

              const SizedBox(height: 24),

              // Resend button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the ${_verificationType == 'email' ? 'email' : 'code'}? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: _canResend && !_isResending ? _resendOtp : null,
                    child: Text(
                      _canResend
                          ? 'Resend'
                          : 'Resend in ${_resendCountdown}s',
                      style: TextStyle(
                        color: _canResend ? AppTheme.primary : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
