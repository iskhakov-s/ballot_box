import 'package:ballot_box/home_screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ballot_box/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormContainer(
      icon: const Icon(Icons.mail),
      controller: emailController,
      labelText: "Email",
      keyboardType: TextInputType.emailAddress,
      validator: (val) {
        RegExp regex = RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
        if (val!.isEmpty) {
          return 'Please enter an email';
        }
        if (!regex.hasMatch(val)) {
          return "Please enter a valid email";
        }
        return null;
      },
    );

    final passwordField = TextFormContainer(
      icon: const Icon(Icons.vpn_key),
      controller: passwordController,
      labelText: "Password",
      obscureText: true,
      textInputAction: TextInputAction.done,
      validator: (val) {
        if (val!.isEmpty) {
          return "Please enter your password";
        }
        return null;
      },
    );

    final loginButton = WidgetContainer(
      child: ElevatedButton(
        child: const Text('Login'),
        onPressed: () {
          signIn(emailController.text, passwordController.text);
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  emailField,
                  passwordField,
                  loginButton,
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then(
        (uid) {
          snackbar(context, "Login Successful");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false,
          );
        },
      ).catchError(
        (e) {
          snackbar(context, e!.message);
        },
      );
    } else {
      snackbar(context, "Login Failed");
    }
  }
}
