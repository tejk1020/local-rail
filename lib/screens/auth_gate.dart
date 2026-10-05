import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _getRememberMe() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool('remember_me') ?? true;
  }

  Future<void> _handleRememberMe(
      User? user,
      ) async {
    if (user == null) {
      return;
    }

    final rememberMe =
    await _getRememberMe();

    if (!rememberMe) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream:
      FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // ========================================================
        // WAITING FOR FIREBASE
        // ========================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child:
              CircularProgressIndicator(),
            ),
          );
        }

        // ========================================================
        // USER LOGGED IN
        // ========================================================

        if (snapshot.hasData &&
            snapshot.data != null) {
          return FutureBuilder<bool>(
            future: _getRememberMe(),

            builder:
                (context, rememberSnapshot) {
              if (rememberSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child:
                    CircularProgressIndicator(),
                  ),
                );
              }

              final bool rememberMe =
                  rememberSnapshot.data ?? true;

              if (!rememberMe) {
                // Sign out asynchronously.
                _handleRememberMe(
                  snapshot.data,
                );

                return const Scaffold(
                  body: Center(
                    child:
                    CircularProgressIndicator(),
                  ),
                );
              }

              return const HomeScreen();
            },
          );
        }

        // ========================================================
        // USER NOT LOGGED IN
        // ========================================================

        return const LoginScreen();
      },
    );
  }
}