import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ballot_box/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
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

    final loginButton = WidgetContainer(
      child: ElevatedButton(
        child: const Text('Reset Password'),
        onPressed: () {
          resetPassword();
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
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
                  loginButton,
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void resetPassword() async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .sendPasswordResetEmail(email: emailController.text)
          .then(
            (uid) => {
              snackbar(context, "Password reset email sent"),
              Navigator.pop(context),
            },
          )
          .catchError(
        (e) {
          snackbar(context, e!.message);
        },
      );
    } else {
      snackbar(context, "Reset email not sent");
    }
  }
}
