import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          "Configure your app settings here.",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
