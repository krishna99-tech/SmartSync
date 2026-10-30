import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_header.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? oobCode;

  const ResetPasswordScreen({super.key, this.oobCode});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSavePassword() async {
    final newPassword = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (newPassword.isEmpty || confirm.isEmpty) {
      _showAlert('Error', 'Please fill in both password fields.');
      return;
    }

    if (newPassword.length < 6) {
      _showAlert(
          'Weak Password', 'Password must be at least 6 characters long.');
      return;
    }

    if (newPassword != confirm) {
      _showAlert('Mismatch', 'Passwords do not match.');
      return;
    }

    if (widget.oobCode == null || widget.oobCode!.isEmpty) {
      _showAlert(
        'Error',
        'Invalid reset link. Please request a new password reset email.',
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.oobCode!,
        newPassword: newPassword,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Success',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
                'Your password has been successfully reset! You can now log in with your new credentials.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Log In',
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
      title: 'Reset Password',
      subtitle:
          'Choose a strong password to protect your SmartHome account.',
      headerWidget: const AuthHeader(
        title: 'Reset Password',
        subtitle:
            'Choose a strong password to protect your SmartHome account.',
        svgAsset: 'assets/svg/password_reset.svg',
      ),
      onBack: () => Navigator.pop(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: 'New Password',
            hintText: 'Minimum 6 characters',
            controller: _passwordController,
            isPassword: true,
            showPassword: _showPassword,
            prefixIcon: Icons.lock_outline_rounded,
            onTogglePassword: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Confirm New Password',
            hintText: 'Re-enter new password',
            controller: _confirmController,
            isPassword: true,
            showPassword: _showPassword,
            prefixIcon: Icons.lock_outline_rounded,
            onTogglePassword: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
          const SizedBox(height: 20),
          AuthPrimaryButton(
            text: 'Save New Password',
            isLoading: _isLoading,
            onPressed: _handleSavePassword,
          ),
          const SizedBox(height: 18),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel & Return',
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
