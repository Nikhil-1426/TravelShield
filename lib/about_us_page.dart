import 'package:flutter/material.dart';
import 'home_page.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 223, 218, 218),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(240, 44, 91, 91),
        title: Text("About Us" , style: TextStyle(color: Color.fromARGB(179, 251, 236, 236), fontSize: 22)),
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
              "Welcome to Travel Shield!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Meet the creators behind Travel Shield – Arnav, Nikhil, Aditi A and Aditi B.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              "Contact Information:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Email: your@email.com",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Phone: +91 (123) 456-7890",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Follow Us:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                _buildSocialMediaIcon(Icons.facebook, "Facebook"),
                /* _buildSocialMediaIcon(Icons.twitter, "Twitter"),
                _buildSocialMediaIcon(Icons.instagram, "Instagram"), */
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Icon(icon, size: 40),
          SizedBox(height: 8),
          Text(label),
        ],
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