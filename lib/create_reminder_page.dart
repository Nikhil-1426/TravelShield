import 'package:flutter/material.dart';

class CreateReminderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Reminder"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          "Create health-related reminders.",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
