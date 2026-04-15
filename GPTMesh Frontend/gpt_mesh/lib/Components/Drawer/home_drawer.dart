import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text(
              "EchoAssists",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(title: const Text("Privacy Policy"), onTap: () {}),
          ListTile(title: Text("Settings"), onTap: () {}),
        ],
      ),
    );
  }
}
