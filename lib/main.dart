import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loading_page.dart';
import 'signin_page.dart';
import 'signup_page.dart';
import 'track_health_page.dart';
import 'settings_page.dart';
import 'health_history_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => LoadingScreen(),
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/trackHealth': (context) => _buildPage(context, TrackHealthPage as Widget Function(String p1)),
        '/settings': (context) => _buildPage(context, SettingsPage as Widget Function(String p1)),
        '/healthHistory': (context) => _buildPage(context, HealthHistoryPage as Widget Function(String p1)),
        '/home': (context) {
          User? user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            return SignInPage();
          }
          return HomePage(uid: user.uid);
        },
      },
    );
  }

  /// Helper method to handle routes requiring `uid`.
  Widget _buildPage(BuildContext context, Widget Function(String) pageBuilder) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return SignInPage();
    }
    return pageBuilder(user.uid);
  }
}
