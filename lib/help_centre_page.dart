import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class HelpCentrePage extends StatelessWidget {
  Future<String?> _getUid() async {
    // Retrieve UID from Firebase Auth or SharedPreferences
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? (await SharedPreferences.getInstance()).getString('uid');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ Colors.tealAccent,Color.fromARGB(255, 19, 152, 152)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
        title: const Text(
          "Help Centre",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
     
        centerTitle: true,
        elevation: 4,
        iconTheme: const IconThemeData(
        color: Colors.white, // Set the back button color to white
      ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            color: Colors.white,
            onPressed: () async {
              final uid = await _getUid();
              if (uid != null && uid.isNotEmpty) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(uid: uid)),
                );
              } else {
                // Redirect to sign-in if UID is not available
                Navigator.pushReplacementNamed(context, '/signin');
              }
            },
            tooltip: 'Home',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildRectangularCard(
                  title: "Welcome to the Help Centre",
                  icon: Icons.help_center,
                  color: Colors.blue,
                  cardHeight: 140,
                  child: const Text(
                    "If you need assistance, please explore the FAQs below or contact our support team.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle("Common Questions"),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: [
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildQuestionAnswer(String question, String answer) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRectangularCard({
    required String title,
    required IconData icon,
    required Color color,
    double cardHeight = 100,
    Widget? child,
  }) {
    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: child ??
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
