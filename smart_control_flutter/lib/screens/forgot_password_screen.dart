import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showAlert('Missing Info', 'Please enter your email address.');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
    });

    try {
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://smarthome-2524a.firebaseapp.com/reset-password',
        handleCodeInApp: true,
        androidPackageName: 'com.electrogadgedc.SmartHome',
        androidInstallApp: true,
        androidMinimumVersion: '12',
        iOSBundleId: 'com.electrogadgedc.SmartHome',
      );

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Email Sent',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
                'Check your inbox for the password reset instructions.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Back to Login',
                    style: TextStyle(
                        color: AuthColors.primary,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showAlert('Reset Failed', e.message ?? 'An error occurred.');
    } catch (e) {
      _showAlert('Reset Failed', e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK',
                style: TextStyle(
                    color: AuthColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      title: 'Forgot Password',
      subtitle:
          'Enter your registered email to receive password recovery instructions.',
      headerWidget: const AuthHeader(
        title: 'Forgot Password',
        subtitle:
            'Enter your registered email to receive password recovery instructions.',
        svgAsset: 'assets/svg/password_recovery.svg',
      ),
      onBack: () => Navigator.pop(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: 'Email Address',
            hintText: 'name@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 20),
          AuthPrimaryButton(
            text: 'Send Reset Link',
            isLoading: _isLoading,
            onPressed: _handleReset,
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  color: AuthColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
