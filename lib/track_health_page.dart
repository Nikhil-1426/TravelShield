import 'package:flutter/material.dart';

class TrackHealthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Health"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          "Track your health details here.",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
