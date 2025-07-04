import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:smart_parking_app/screens/dashboard_screen.dart'; // Tidak lagi langsung ke dashboard
import 'package:smart_parking_app/screens/login_signup_screen.dart';
import 'package:smart_parking_app/screens/main_navigation_screen.dart'; // Import MainNavigationScreen
import 'package:smart_parking_app/theme_provider.dart'; // Import ThemeNotifier

class AuthWrapper extends StatelessWidget {
  final ThemeNotifier themeNotifier;

  const AuthWrapper({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is logged in
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return MainNavigationScreen(
                themeNotifier: themeNotifier); // Teruskan notifier
          }
          // User is not logged in
          return const LoginSignupScreen();
        }
        // Checking auth state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
