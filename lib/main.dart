import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loading_page.dart';
import 'signin_page.dart';
import 'signup_page.dart';
import 'track_health_page.dart';
import 'settings_page.dart';
import 'health_history_page.dart';
// import 'profile_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? 'default-uid';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => LoadingPage(),
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/trackHealth': (context) => TrackHealthPage(uid: uid),
        '/settings': (context) => SettingsPage(uid: uid),
        '/healthHistory': (context) => HealthHistoryPage(uid: uid),
        '/home': (context) {
          // Check if the user is logged in
          User? user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            // If no user is logged in, navigate to the SignInPage
            return SignInPage();
          }
          // Pass the uid if the user is authenticated
          return HomePage(uid: user.uid);
        },
      },
    );
  }
}
