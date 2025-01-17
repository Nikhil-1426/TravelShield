import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_reminder_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchSummary();
    _fetchHealthScore();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Travel Shield',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
            colors: [Colors.teal, Colors.tealAccent],
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
                  _buildRectangularCard(
                    title: 'Your healthcare companion at your fingertips',
                    icon: Icons.health_and_safety,
                    color: Colors.purple,
                    cardHeight: 160,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          title: 'Health Score',
                          icon: Icons.favorite,
                          color: Colors.red,
                          content: healthScore == null
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Colors.red),
                                )
                              : CircularPercentIndicator(
                                  radius: 50.0,
                                  lineWidth: 8.0,
                                  percent: (healthScore != null
                                      ? (healthScore! / 10.0).clamp(0.0, 1.0)
                                      : 0.0),
                                  center: Text(
                                    "${healthScore?.toStringAsFixed(2) ?? '0.00'}",
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  progressColor: Colors.green,
                                  backgroundColor: Colors.white,
                                ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildFeatureCard(
                          title: 'Plan a Trip',
                          icon: Icons.airplanemode_active,
                          color: Colors.blue,
                          destination: CreateReminderPage(uid: widget.uid),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildReportContainer(
                    title: 'Health Summary',
                    icon: Icons.bar_chart,
                    color: Colors.green,
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
        backgroundColor: Colors.transparent,
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
    required IconData icon,
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
                  Icon(icon, size: 50, color: color),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildReportContainer({
    required String title,
    required IconData icon,
    required Color color,
    double cardHeight = 100,
    Widget? child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Add Button Row
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
                            hintText: 'Decsribe your condition',
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
        ),
      ],
    );
  }
}
