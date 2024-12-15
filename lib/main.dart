import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'loading_page.dart';
import 'signin_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'track_health_page.dart';
import 'create_reminder_page.dart';
import 'settings_page.dart';
import 'health_history_page.dart';

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
        '/loading': (context) => LoadingPage(),
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/trackHealth': (context) => TrackHealthPage(),
        '/createReminder': (context) => CreateReminderPage(),
        '/settings': (context) => SettingsPage(),
        '/healthHistory': (context) => HealthHistoryPage(),
      },
    );
  }
}
