import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_reminder_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String uid;

  const HomePage({Key? key, required this.uid}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? summaryText;
  bool isLoadingSummary = true;
  double? healthScore;

String username = 'Username'; // Default value
Future<void> _fetchUsername() async {
  try {
    var userDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();

    if (userDocument.exists) {
      print('User document data: ${userDocument.data()}'); // Debug print
      setState(() {
        username = userDocument.data()?['name'] ?? 'Default Username';
      });
    } else {
      print('No such document!');
    }
  } catch (e) {
    print('Error fetching username: $e');
  }
}


  @override
  void initState() {
    super.initState();
    _fetchSummary();
    _fetchHealthScore();
    _fetchUsername();
  }

  Future<void> _fetchSummary() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('summaries')
          .orderBy('generatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          summaryText = snapshot.docs.first['summary'] as String;
          isLoadingSummary = false;
        });
      } else {
        setState(() {
          summaryText = "No summary available yet.";
          isLoadingSummary = false;
        });
      }
    } catch (e) {
      setState(() {
        summaryText = "Failed to load summary.";
        isLoadingSummary = false;
      });
    }
  }

  Future<void> _fetchHealthScore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('healthScores')
          .orderBy('generatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          healthScore = snapshot.docs.first['healthScore'] as double?;
        });
      } else {
        setState(() {
          healthScore = 0.0;
        });
      }
    } catch (e) {
      setState(() {
        healthScore = 0.0;
      });
    }
  }

  Future<String> translateText(String text, String languageCode) async {
  const String flaskServerUrl = 'http://192.168.156.197:5000/translate';

  try {
    final Map<String, dynamic> payload = {
      'text': text,
      'to': [languageCode], // `to` must be a list as expected by Flask
      'from': 'en', // Optionally include the source language
    };

    final http.Response response = await http.post(
      Uri.parse(flaskServerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List translations = responseData['translations'];
      return translations.isNotEmpty ? translations[0]['translatedText'] : 'Translation unavailable.';
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      return 'Translation failed. Please try again.';
    }
  } catch (e) {
    print('Exception occurred: $e');
    return 'An error occurred. Please try again.';
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Travel Shield',
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        backgroundColor: Colors.transparent,  // Make AppBar transparent
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [ Colors.tealAccent,Color.fromARGB(255, 19, 152, 152)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  ),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout,color:Colors.white),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/signin');
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 63, 152, 143) ,Color.fromARGB(255, 141, 249, 224)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Stack(
  children: [
    // Background image for the entire card with curved corners and shadow
    ClipRRect(
      borderRadius: BorderRadius.circular(20.0), // Apply curved corners
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bckgrnd2.jpg'),
            fit: BoxFit.cover, // Ensures the background image covers the container
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // Shadow color with transparency
              spreadRadius: 2, // Spread of the shadow
              blurRadius: 8, // Blur effect for the shadow
              offset: Offset(0, 4), // Offset of the shadow (vertical offset in this case)
            ),
          ],
        ),
      ),
    ),
    // Small grey rectangle on the left
    Positioned(
      left: 5,
      top: 0,
      bottom: 0,
      width: 90, // Adjust width to your preference
      child: Container(
        color: Color.fromARGB(258, 188, 246, 244), // Solid grey color
        child: Center(
          child: Image.asset(
            'assets/App_logo2.png', // Path to the logo
            height: 90, // Adjust the size of the logo
            width: 90,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
    // Text content written over the background image
    Positioned(
      left: 110, // Offset to the right of the grey rectangle
      top: 30, // Adjust vertical alignment
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 7, width: 10),
          Text(
            'Hi $username!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 205, 241, 236), // White text for contrast
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your healthcare companion \nat your fingertips',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70, // Slightly transparent white
            ),
          ),
        ],
      ),
    ),
  ],
),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                    
                      Expanded(
                        child: _buildFeatureCard(
                          title: 'Health Score',
                          icon: Icons.favorite,
                          color: Colors.red,
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Health Score',
                                style: const TextStyle(
                                  fontSize: 21.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 38, 144, 137),
                                ),
                              ),
                              const SizedBox(height: 7),
                              healthScore == null
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(Colors.red),
                                    )
                                  : CircularPercentIndicator(
                                      radius: 45.0,
                                      lineWidth: 8.0,
                                      percent: (healthScore! / 10.0).clamp(0.0, 1.0),
                                      center: Text(
                                        "${healthScore?.toStringAsFixed(2) ?? '0.00'}",
                                        style: const TextStyle(
                                          fontFamily: 'ArialRoundedMTBold',
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 44, 166, 158),
                                        ),
                                      ),
                                      progressColor: const Color.fromARGB(255, 44, 166, 158),
                                      backgroundColor: Colors.white,
                                    ),
                            ],
                          ),
                        ),
                      ),


                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildFeatureCard(
                          title: 'Plan a Trip',
                          imagePath: 'assets/amazon.png',
                          color: const Color.fromARGB(255, 44, 166, 158),
                          destination: CreateReminderPage(uid: widget.uid),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildReportContainer(
                    title: 'Health Summary',
                    icon: Icons.bar_chart,
                    color: Colors.teal,
                    cardHeight: 250,
                    child: isLoadingSummary
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.teal),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SingleChildScrollView(
                              child: Text(
                                summaryText ?? 'No summary available.',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                  ),
                  // Add some padding at the bottom to ensure content isn't hidden behind the navigation bar
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 1,
        items: const [
          Icon(Icons.person, size: 30, color: Colors.white),
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.settings, size: 30, color: Colors.white),
        ],
        color: Colors.teal,
        buttonBackgroundColor: Colors.tealAccent,
        backgroundColor: const Color.fromARGB(255, 216, 248, 243),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePage(uid: widget.uid)),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SettingsPage(uid: widget.uid)),
            );
          }
        },
      ),
    );
  }

  Widget _buildFeatureCard({
        required String title,
        IconData? icon,
        String? imagePath, // New parameter for image path
        required Color color,
        Widget? content,
        Widget? destination,
      }) {
        return GestureDetector(
          onTap: () {
            if (destination != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destination),
              );
            }
          },
          child: Container(
            height: 150,
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
            child: content ?? 
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      imagePath != null
                          ? Image.asset(imagePath, height: 100, fit: BoxFit.contain)
                          : Icon(icon, size: 80, color: color),
                      const SizedBox(height: 4),
                      
                    ],
                  ),
                ),
          ),
        );
      }

  Widget _buildReportContainer({
    required String title,
    required IconData icon,
    required Color color,
    double cardHeight = 100,
    Widget? child,
  }) {
    // Map of supported languages for translation
    final Map<String, String> supportedLanguages = {
      'English': 'en',
      'Spanish': 'es',
      'French': 'fr',
      'German': 'de',
      'Chinese': 'zh',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Add/Translate Buttons Row
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      // Text controller for the input field
                      final TextEditingController textController =
                          TextEditingController();

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Update'),
                            content: TextField(
                              controller: textController,
                              decoration: const InputDecoration(
                                hintText: 'Describe your condition',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (textController.text.isNotEmpty) {
                                    setState(() {
                                      summaryText = textController.text;
                                    });
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Update'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.translate, color: Colors.white),
                    onPressed: () {
                      // Show dropdown for language selection
                      String? selectedLanguage;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter setDialogState) {
                              return AlertDialog(
                                title: const Text('Select Language'),
                                content: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedLanguage,
                                  hint: const Text('Select Language'),
                                  items: supportedLanguages.entries
                                      .map((entry) => DropdownMenuItem<String>(
                                            value: entry.value,
                                            child: Container(
                                              height: 50, // Fixed height for dropdown items
                                              alignment: Alignment.centerLeft, // Align text consistently
                                              child: Text(
                                                '${entry.key} (${entry.value})',
                                                style: const TextStyle(fontSize: 16), // Uniform text size
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    setDialogState(() {
                                      selectedLanguage = newValue;
                                    });
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (selectedLanguage != null &&
                                          summaryText != null &&
                                          summaryText!.isNotEmpty) {
                                        String translatedText = await translateText(
                                          summaryText!,
                                          selectedLanguage!,
                                        );
                                        setState(() {
                                          summaryText = translatedText;
                                        });
                                      }
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Translate'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        // Original Card Container
        Container(
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
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(15)),
                ),
                child: Icon(icon, color: color, size: 40),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: child ??
                      Text(
                        (summaryText != null && summaryText!.isNotEmpty) ? summaryText! : title,
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
        ),
      ],
    );
  }
}