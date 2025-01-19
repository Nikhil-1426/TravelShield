import 'dart:async';
import 'package:flutter/material.dart';
import 'signup_page.dart'; // Import your auth screen file

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    // Initialize fade-in animation
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Start the animation when the screen is loaded
    _controller.forward();

    // Simulate a loading period, then navigate to AuthScreen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignUpPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Loading image at the center with fade-in animation
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 - 180,
            child: FadeTransition(
              opacity: _animation,
              child: Container(
                width: 300,
                height: 300,
                child: Image.asset('assets/App_logo2.png'),
              ),
            ),
          ),
          // Loading indicator centered between the image and notification box
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 + 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          // Notification box at the bottom
          Positioned(
            bottom: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(89, 95, 94, 94).withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Hang tight, it may take a few seconds to load.",
                style: TextStyle(fontSize: 14, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}