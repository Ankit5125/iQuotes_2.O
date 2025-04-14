import 'package:flutter/material.dart';
import '../../auth/forgetPassword.dart';
import '../MyTextInput.dart';

class LoginInputFields extends StatelessWidget {

  final TextEditingController emailController;
  final TextEditingController passwordController;
  const LoginInputFields({required this.emailController, required this.passwordController, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email",
          style: TextStyle(
            decoration: TextDecoration.none,
            color: Colors.grey.shade700,
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        MyTextInput(
          name: "Enter Your Email Here",
          controller: emailController,
          isPasswordField: false,
          isNameField: false,
        ),
        Container(height: 30),
        Text(
          "Password",
          style: TextStyle(
            decoration: TextDecoration.none,
            color: Colors.grey.shade700,
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        MyTextInput(
          name: "Enter Your Password Here",
          controller: passwordController,
          isPasswordField: true,
          isNameField: false,
        ),

        Container(height: 5),

        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                child: Text("Forget Password ?"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                }, // navigate to forget password screen
              ),
            ],
          ),
        ),
      ],
    );
  }
}
