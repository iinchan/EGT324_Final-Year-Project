import 'package:elderly_app/newuser_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user registered
          if (snapshot.hasData) {
            return const newuser_login();
          }

          //user not registered in
          else {
            return const newuser_login();
          }
        },
      ),
    );
  }
}
