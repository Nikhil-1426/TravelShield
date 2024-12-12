import 'package:flutter/material.dart';

class HealthHistoryPage extends StatelessWidget {
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
    );
  }
}
