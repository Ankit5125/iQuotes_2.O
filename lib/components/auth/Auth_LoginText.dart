import 'package:flutter/material.dart';

class LoginText extends StatelessWidget {
  const LoginText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(
            decoration: TextDecoration.none,
            color: Colors.black,
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        Text(
          "Sign in To Continue",
          style: TextStyle(
            decoration: TextDecoration.none,
            color: Colors.grey.shade700,
            fontFamily: "Poppins",
            fontWeight: FontWeight.normal,
            fontSize: 25,
          ),
        ),
      ],
    );
  }
}
