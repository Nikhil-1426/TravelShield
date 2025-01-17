import 'package:flutter/material.dart';
import 'home_page.dart';

class HelpCentrePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 223, 218, 218) ,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(240, 44, 91, 91),
        title: Text("Help Centre" , style: TextStyle(color: Color.fromARGB(179, 251, 236, 236), fontSize: 22)),
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
              "Welcome to the Help Centre",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 17),
            Text(
              "If you need assistance, please contact our support team.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 17),
            _buildSectionTitle("Common Questions"),
            SizedBox(height: 10),
            _buildQuestionAnswer(
              "How do I reset my password?",
              "You can reset your password by visiting our website and clicking on the 'Forgot Password' link.",
            ),
            _buildQuestionAnswer(
              "What are the supported devices?",
              "Our app is available on both iOS and Android devices. Make sure your device meets the minimum requirements.",
            ),
            _buildQuestionAnswer(
              "How can I update my profile information?",
              "To update your profile, go to the 'Settings' section in the app and select 'Edit Profile.' Make the desired changes and save.",
            ),
            _buildQuestionAnswer(
              "Is my personal information secure?",
              "Yes, we take the security of your personal information seriously. Our app employs advanced encryption and security measures to protect your data.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildQuestionAnswer(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 7),
        Text(
          answer,
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.only(right: 12),
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