import 'package:flutter/material.dart';

class MyTextInput extends StatefulWidget {
  final String name;
  final TextEditingController controller;
  final bool isPasswordField;
  final bool isNameField;
  // Changed from emailController to controller
  const MyTextInput({
    super.key,
    required this.name,
    required this.controller,
    required this.isPasswordField,
    required this.isNameField});

  @override
  State<MyTextInput> createState() => _MyTextInputState();
}

class _MyTextInputState extends State<MyTextInput> {

  Icon lock = Icon(Icons.lock);
  bool isPassVisible = true;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Colors.grey,
          selectionHandleColor: Colors.black,
          cursorColor: Colors.black, // Changed from white to black to match your design
        ),
      ),
      child: TextField(
        obscureText: widget.isPasswordField? isPassVisible: false,
        controller: widget.controller, // Access through widget.controller
        cursorColor: Colors.black,
        style: TextStyle(
          color: Colors.grey.shade800,
          backgroundColor: Colors.transparent,
        ),
        decoration: InputDecoration(
          hintText: widget.name, // Use the name parameter as hint text
          filled: true,
          fillColor: Colors.grey.shade300,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: widget.isPasswordField?
          IconButton(onPressed: toggleIcon, icon: lock) : widget.isNameField ? Icon(Icons.person) : Icon(Icons.email)
        ),
      ),
    );
  }

  void toggleIcon(){
    setState(() {
      if(lock.icon == Icons.lock){
        lock = Icon(Icons.lock_open_outlined);
      }
      else{
        lock = Icon(Icons.lock);
      }
      isPassVisible = !isPassVisible;
    });
  }
}