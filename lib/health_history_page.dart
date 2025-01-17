import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart'; // Import the profile page
import 'home_page.dart';    // Import the home page
import 'settings_page.dart'; // Import the settings page

class HealthHistoryPage extends StatelessWidget {
  final String uid;

  const HealthHistoryPage({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health History"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          "View your health history here.",
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 1, // Keep Home page selected by default
        items: <Widget>[
          Icon(Icons.person, size: 30, color: Colors.white), // Profile icon
          Icon(Icons.home, size: 30, color: Colors.white),   // Home icon
          Icon(Icons.settings, size: 30, color: Colors.white), // Settings icon
        ],
        color: Colors.teal,
        buttonBackgroundColor: Colors.tealAccent,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          User? user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            // If user is not logged in, navigate to SignInPage or handle appropriately
            Navigator.pushNamed(context, '/signin');
          } else {
            // Pass the authenticated user's UID to the respective pages
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(uid: user.uid)),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(uid: user.uid)),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(uid: user.uid)),
              );
            }
          }
        },
      ),
    );
  }
}
