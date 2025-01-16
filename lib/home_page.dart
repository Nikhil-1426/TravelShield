// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart'; // Import percent_indicator package
// import 'track_health_page.dart';
// import 'create_reminder_page.dart';
// import 'settings_page.dart';
// import 'health_history_page.dart';

// class HomePage extends StatefulWidget {
//   final String uid;

//   const HomePage({Key? key, required this.uid}) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String? summaryText; // To store the fetched summary
//   bool isLoadingSummary = true; // To show a loading indicator
//   double? healthScore; // To store the health score

//   @override
//   void initState() {
//     super.initState();
//     _fetchSummary();
//     _fetchHealthScore();
//   }

//   Future<void> _fetchSummary() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.uid)
//           .collection('summaries')
//           .orderBy('generatedAt', descending: true)
//           .limit(1)
//           .get();

//       if (snapshot.docs.isNotEmpty) {
//         setState(() {
//           summaryText = snapshot.docs.first['summary'] as String;
//           isLoadingSummary = false;
//         });
//       } else {
//         setState(() {
//           summaryText = "No summary available yet.";
//           isLoadingSummary = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         summaryText = "Failed to load summary.";
//         isLoadingSummary = false;
//       });
//     }
//   }

//   Future<void> _fetchHealthScore() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.uid)
//           .collection('healthScores')
//           .orderBy('generatedAt', descending: true)
//           .limit(1)
//           .get();

//       if (snapshot.docs.isNotEmpty) {
//         setState(() {
//           healthScore = snapshot.docs.first['healthScore'] as double?;
//         });
//       } else {
//         setState(() {
//           healthScore = 0.0; // If no score available
//         });
//       }
//     } catch (e) {
//       setState(() {
//         healthScore = 0.0; // In case of failure to fetch health score
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(
//           'Health Passport',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.teal,
//         centerTitle: true,
//         elevation: 4,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () {
//               Navigator.pushReplacementNamed(context, '/signin');
//             },
//             tooltip: 'Sign Out',
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.teal, Colors.tealAccent],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 55,
//                       backgroundColor: Colors.white,
//                       child: Icon(
//                         Icons.health_and_safety,
//                         size: 55,
//                         color: Colors.teal,
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       'Welcome Back!',
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       'Your health companion at your fingertips',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white70,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               // Health Score Section (Circular Graph)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 20.0),
//                 child: healthScore == null
//                     ? CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation(Colors.white),
//                       )
//                     : CircularPercentIndicator(
//                         radius: 100.0,
//                         lineWidth: 10.0,
//                         percent: healthScore! / 100,
//                         center: Text(
//                           "${healthScore?.toStringAsFixed(1)}%",
//                           style: TextStyle(
//                             fontSize: 20.0,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.teal,
//                           ),
//                         ),
//                         progressColor: Colors.green,
//                         backgroundColor: Colors.white,
//                       ),
//               ),
//               // Summary Section
//               if (isLoadingSummary)
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation(Colors.white),
//                   ),
//                 )
//               else
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                   child: Card(
//                     color: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     elevation: 6,
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Latest Summary',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.teal,
//                             ),
//                           ),
//                           SizedBox(height: 10),
//                           Container(
//                             height: 200, // Adjust height as needed
//                             child: SingleChildScrollView(
//                               child: Text(
//                                 summaryText ?? 'No summary available.',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                   child: GridView.count(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 20,
//                     mainAxisSpacing: 20,
//                     children: [
//                       _buildFeatureCard(
//                         context,
//                         title: 'Track Health',
//                         icon: Icons.fitness_center,
//                         color: Colors.orange,
//                         destination: TrackHealthPage(),
//                       ),
//                       _buildFeatureCard(
//                         context,
//                         title: 'Create Reminder',
//                         icon: Icons.alarm_add,
//                         color: Colors.purple,
//                         destination: CreateReminderPage(uid: widget.uid),
//                       ),
//                       _buildFeatureCard(
//                         context,
//                         title: 'Settings',
//                         icon: Icons.settings,
//                         color: Colors.blue,
//                         destination: SettingsPage(),
//                       ),
//                       _buildFeatureCard(
//                         context,
//                         title: 'Health History',
//                         icon: Icons.history,
//                         color: Colors.green,
//                         destination: HealthHistoryPage(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureCard(BuildContext context,
//       {required String title,
//       required IconData icon,
//       required Color color,
//       required Widget destination}) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => destination),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 6,
//               offset: Offset(2, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 40,
//               color: color,
//             ),
//             SizedBox(height: 15),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.teal,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'track_health_page.dart';
import 'create_reminder_page.dart';
import 'settings_page.dart';
import 'health_history_page.dart';
import 'profile_page.dart';

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
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/signin');
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
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildRectangularCard(
                        context,
                        title: 'Your healthcare companion at your fingertips',
                        icon: Icons.health_and_safety,
                        color: Colors.purple,
                        destination: SettingsPage(uid: '',),
                        cardHeight: 160,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeatureCard(
                              context,
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
                                      percent: healthScore! / 100,
                                      center: Text(
                                        "${healthScore?.toStringAsFixed(1)}%",
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
                              context,
                              title: 'Plan a Trip',
                              icon: Icons.airplanemode_active,
                              color: Colors.blue,
                              destination: CreateReminderPage(uid: widget.uid),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildRectangularCard(
                        context,
                        title: 'Health Summary',
                        icon: Icons.bar_chart,
                        color: Colors.green,
                        destination: const HealthHistoryPage(uid: '',),
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
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(uid: widget.uid)),
            );
          } else if (index == 1) {
            // Already on Home Page
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage(uid: widget.uid)),
            );
          }
        },
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      Widget? content,
      Widget? destination}) {
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
          boxShadow: [
            const BoxShadow(
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
                  Icon(
                    icon,
                    size: 50,
                    color: color,
                  ),
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

  Widget _buildRectangularCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required Widget destination,
      double cardHeight = 100,
      Widget? child}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Container(
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
              child: Icon(
                icon,
                color: color,
                size: 40,
              ),
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
    );
  }
}
