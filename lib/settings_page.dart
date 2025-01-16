import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'home_page.dart';
import 'help_centre_page.dart';
import 'terms_and_conditions_page.dart';
import 'about_us_page.dart';
import 'profile_page.dart';

class SettingsPage extends StatelessWidget {
  final String uid;

  const SettingsPage({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Header Section
          Container(
            height: 80, // Header height
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.teal, Colors.tealAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "Settings",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Profile Section (User Details)
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Error fetching profile data.",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                );
              }

              var userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              String name = userData['name'] ?? 'Guest User';
              String email = userData['email'] ?? 'user@example.com';

              return Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color.fromARGB(255, 9, 11, 13),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              );
            },
          ),

          // Settings Items with smaller spacing
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSettingItem("Help Centre", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpCentrePage()),
                  );
                }),
                _buildSettingItem("Terms and Conditions", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TermsAndConditionsPage()),
                  );
                }),
                _buildSettingItem("About Us", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUsPage()),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 2,
        items: const [
          Icon(Icons.person, size: 30, color: Colors.white),
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.settings, size: 30, color: Colors.white),
        ],
        color: Colors.teal,
        buttonBackgroundColor: Colors.tealAccent,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage(uid: uid)),
            );
          }
        },
      ),
    );
  }

  Widget _buildSettingItem(String title, VoidCallback onPressed) {
    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 300,
          margin: const EdgeInsets.symmetric(vertical: 8), // Reduced margin
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(210, 16, 126, 119),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//ADD SIGN OUT BUTTON