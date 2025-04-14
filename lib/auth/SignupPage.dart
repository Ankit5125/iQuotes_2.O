import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iQuotes/screens/MainBody.dart';

import '../components/MyTextInput.dart';

class SignupPageScreen extends StatefulWidget {
  const SignupPageScreen({super.key});

  @override
  State<SignupPageScreen> createState() => _SignupPageScreenState();
}

class _SignupPageScreenState extends State<SignupPageScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "iQuotes",
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name",
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.grey.shade700,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    MyTextInput(
                      name: "Enter Your Name Here",
                      controller: nameController,
                      isPasswordField: false,
                      isNameField: true,
                    ),
                    Container(height: 30,),
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
                  ],
                ),

                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextButton(
                        onPressed: _signUpTriggered,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.black),
                          foregroundColor: WidgetStateProperty.all(Colors.white),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Sign Up"),
                        ),
                      ),
                    ),
                    Container(height: 12,),
                    Text(
                      "By signing up, you agree to our Terms and Privacy Policy",
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.grey,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already Have an Account ?",
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      Container(width: 10,),
                      GestureDetector(
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: (){
                          Navigator.pop(context);
                        },
                      )
                    ],

                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signUpTriggered() async {

    if(passwordController.text.isNotEmpty && emailController.text.isNotEmpty){
      if(passwordController.text.trim().length >= 8){
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim()
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Account Created Successfully"))
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainBody()),
                (Route<dynamic> route) => false, // Remove all routes
          );
        }
        on FirebaseAuthException catch (e) {
          String message = 'Error...';
          if (e.code == 'weak-password') {
            message = 'The password provided is too weak.';
          } else if (e.code == 'email-already-in-use') {
            message = 'An account already exists with that email.';
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
        catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed, please Try Again')));
        }
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password Must Contains Atleast 8 Characters..."))
        );
      }
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Both Fields are Required"))
      );
    }


  }
}
