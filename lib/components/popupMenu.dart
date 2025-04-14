import 'package:flutter/material.dart';

class myPopUpMenu extends StatelessWidget {
  const myPopUpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        icon: Icon(Icons.more_vert),
        itemBuilder: (context) => [
              PopupMenuItem(
                  child: ListTile(
                leading: Icon(Icons.remove_red_eye),
                title: Text("Visit"),
              )),
              PopupMenuItem(
                  child: ListTile(
                leading: Icon(Icons.download),
                title: Text("Download"),
              ))
            ]);
  }
}
