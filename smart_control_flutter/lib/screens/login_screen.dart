import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_social_button.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          _errorMessage =
              'Invalid credentials. Please verify your email and password.';
        } else {
          _errorMessage = e.message ?? 'An error occurred. Please try again.';
        }
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Connection failed. Please check your network.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted =
        isDark ? AuthColors.textMutedDark : AuthColors.textMutedLight;

    return AuthBackground(
      title: 'Welcome back',
      subtitle: 'Please log in to continue.',
      headerWidget: const AuthHeader(
        title: 'Welcome back',
        subtitle: 'Enter your credentials to access your smart devices.',
        svgAsset: 'assets/svg/smart_home.svg',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          AuthTextField(
            label: 'Email',
            hintText: 'name@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 16),

          // Password Field
          AuthTextField(
            label: 'Password',
            hintText: '••••••••',
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
          const SizedBox(height: 12),

          // Remember Me & Forgot Password Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _rememberMe = !_rememberMe;
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: AuthColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          fontSize: 13,
                          color: textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 13,
                    color: AuthColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Error Message Alert Box
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AuthColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AuthColors.error.withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AuthColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AuthColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Primary Sign In Button
          AuthPrimaryButton(
            text: 'Sign In',
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 20),

          // Shadcn Style Divider: —— or continue with ——
          const AuthDivider(text: 'or continue with'),
          const SizedBox(height: 16),

          // Social Auth Button
          AuthSocialButton(
            label: 'Continue with Google',
            icon: const Icon(
              Icons.g_mobiledata_rounded,
              size: 26,
              color: AuthColors.primary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Firebase Email/Password authentication active.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 22),

          // Bottom Register Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(
                  fontSize: 13,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignupScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 13,
                    color: AuthColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
