import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/LoginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Center(
          child: Text('Login Screen'),
        ),
        SizedBox(
          height: 20,
        ),
        CircularProgressIndicator(),
      ],
    );
  }
}
