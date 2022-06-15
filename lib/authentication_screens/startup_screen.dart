import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ballot_box/home_screens/home_screen.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'create_account_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({Key? key}) : super(key: key);

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  late StreamSubscription<User?> user;

  @override
  void initState() {
    super.initState();
    // checks if the user is already signed in
    // if they are redirect them to the home screen
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    // user.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ballot"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: ElevatedButton(
                  child: const Text('Login'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                ),
              ),
              Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: ElevatedButton(
                  child: const Text('Create Account'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateAccountScreen()),
                    );
                  },
                ),
              ),
              Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    'Forgot Password',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
