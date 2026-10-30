import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_links/app_links.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/splash_screen.dart';

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();

    // Maintain splash screen for 2.2s so the startup animation & logo are enjoyed
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was launched via deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (_) {}

    // Listen to incoming deep links while app is open/in background
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (_) {},
    );
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path.contains('reset-password') || uri.host == 'reset-password') {
      final oobCode = uri.queryParameters['oobCode'];
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(oobCode: oobCode),
        ),
      );
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking initial Firebase auth state, show the Splash Screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final user = snapshot.data;

        // If authenticated, render MainNavigationScreen with Home & Profile tabs
        if (user != null) {
          return const MainNavigationScreen();
        }

        // If unauthenticated, render Auth Stack (Login, Signup, ForgotPassword, ResetPassword)
        return Navigator(
          key: _navigatorKey,
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            );
          },
        );
      },
    );
  }
}
