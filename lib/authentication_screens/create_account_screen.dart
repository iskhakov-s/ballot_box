import 'package:ballot_box/authentication_screens/startup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ballot_box/user_model.dart';
import 'package:ballot_box/constants.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  // String errorMessage = '';

  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usernameField = TextFormContainer(
      icon: const Icon(Icons.account_circle),
      controller: usernameController,
      keyboardType: TextInputType.name,
      labelText: "Name",
      validator: (val) {
        if (val!.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );

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
      validator: (val) {
        RegExp regex = RegExp(
            r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$");
        if (val!.isEmpty) {
          return "Please enter your password";
        }
        if (!regex.hasMatch(val)) {
          toast("Password must be at least 8 characters, "
              "contain at least one lowercase letter, one uppercase letter, "
              "one number, and one special character");
          return "Please enter a valid password";
        }
        return null;
      },
    );

    final confirmPasswordField = TextFormContainer(
      icon: const Icon(Icons.vpn_key),
      controller: confirmPasswordController,
      labelText: "Confirm Password",
      obscureText: true,
      textInputAction: TextInputAction.done,
      validator: (val) {
        if (val!.isEmpty) {
          return "Please reenter your password";
        }
        if (val != passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );

    final registerButton = WidgetContainer(
      child: ElevatedButton(
        child: const Text('Register'),
        onPressed: () {
          register(emailController.text, passwordController.text);
        },
      ),
    );

    return ListViewScaffold(
      title: "Create Account",
      children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              usernameField,
              emailField,
              passwordField,
              confirmPasswordField,
              registerButton,
            ],
          ),
        )
      ],
    );
  }

  // TODO: something fucky is happening here, fix it
  // the following error is  raised when data is submitted correctly
  // Error: This widget has been unmounted, so the State no longer has a context (and should be considered defunct).
  // Consider canceling any active work during "dispose" or using the "mounted" getter to determine if the State is still active.
  // somehow loginscreen is skipped and immediately redirected to homescreen
  void register(String email, String password) async {
    if (!mounted) {
      return;
    }
    if (_formKey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => postDetailsToFirestore())
          .catchError((e) {
        snackbar(context, e!.message);
      });
    } else {
      snackbar(context, 'Registration failed');
    }
  }

  void postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();

    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.username = usernameController.text;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
    snackbar(context, "Account created successfully\nPlease sign in");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const StartupScreen()),
      ((route) => false),
    );
  }
}
