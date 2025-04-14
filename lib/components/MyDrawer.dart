import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.builder(itemBuilder: (context, index) => ListTile(
        title: Text("Option ${index+1}"),
      ),
        itemCount: 5,
      ),
    );
  }
}
