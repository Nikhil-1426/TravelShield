import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String uid;  // Add a final variable to store the passed uid
  const ProfilePage({Key? key, required this.uid}) : super(key: key); 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          "This is your profile.",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}