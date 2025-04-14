import 'package:flutter/material.dart';

class NameButton extends StatelessWidget {
  final String name;
  final doThis;
  const NameButton({required this.name, required this.doThis ,super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: doThis,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.black),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(name),
      ),
    );
  }
}
