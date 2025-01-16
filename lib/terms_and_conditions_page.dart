import 'package:flutter/material.dart';
import 'home_page.dart'; // Import your home screen file

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 223, 218, 218),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(240, 44, 91, 91),
        title: Text("Terms and Conditions" , style: TextStyle(color: Color.fromARGB(179, 251, 236, 236), fontSize: 22)),
        iconTheme : IconThemeData(
          color: Color.fromARGB(179, 251, 236, 236), // Set the back button color
        ),
        actions: [
          _buildCircularIconButton(Icons.home, () {
            // Navigate to the home page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(uid: '',)),
            );
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Introduction",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Welcome to Remembron! These terms and conditions outline the rules and regulations for the use of our mobile application.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "1. Acceptance of Terms",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "By accessing or using our app, you agree to be bound by these terms and conditions. If you disagree with any part of these terms, you may not use our app.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "2. User Account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "To use certain features of the app, you may be required to create a user account. You are responsible for maintaining the confidentiality of your account and password.",
              style: TextStyle(fontSize: 16),
            ),
            // Add more sections as needed

            // Example: Privacy Policy section
            SizedBox(height: 16),
            Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Our privacy policy explains how we collect, use, and protect your personal information. By using our app, you agree to our privacy policy.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.only(right: 12), // Adjust the right padding as needed
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Color.fromARGB(179, 251, 236, 236),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}