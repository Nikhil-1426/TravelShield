import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final String uid;  // Add a final variable to store the passed uid

  // Update the constructor to require the uid
  const SettingsPage({Key? key, required this.uid}) : super(key: key); 
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