import 'package:flutter/material.dart';
import 'package:health_passport/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Question {
  final String questionText;
  final List<Question> followUps;
  final String category; // Added category for better organization
  final String? description; // Optional description/help text
  bool isFollowUp;
  String? userResponse;
  DateTime? answeredAt; // Track when question was answered

  Question({
    required this.questionText,
    this.followUps = const [],
    this.isFollowUp = false,
    this.userResponse,
    this.category = 'general',
    this.description,
    this.answeredAt,
  });
}

class DynamicQuestionnaire extends StatefulWidget {
  final String uid;
  final VoidCallback? onComplete; // Callback for completion

  DynamicQuestionnaire({
    required this.uid,
    this.onComplete,
  });

  @override
  _DynamicQuestionnaireState createState() => _DynamicQuestionnaireState();
}

class _DynamicQuestionnaireState extends State<DynamicQuestionnaire> {
  final List<Question> questions = [
    Question(
      questionText: "Do you have any heart disease?",
      category: "cardiovascular",
      description: "Include any diagnosed heart conditions or related issues",
      followUps: [
        Question(
          questionText: "Have you undergone any heart-related surgeries?",
          isFollowUp: true,
          category: "cardiovascular",
        ),
        Question(
          questionText: "Are you currently taking heart-related medications?",
          isFollowUp: true,
          category: "cardiovascular",
        ),
      ],
    ),
    // Add more questions as needed
  ];

  int currentQuestionIndex = 0;
  List<Question> displayedQuestions = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isSubmitting = false;
  
  // Track progress
  double get progress {
    return currentQuestionIndex / displayedQuestions.length;
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    // Check if there's a saved session
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('currentQuestionIndex') ?? 0;
    
    setState(() {
      displayedQuestions.add(questions[0]);
      currentQuestionIndex = savedIndex;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentQuestionIndex', currentQuestionIndex);
  }

  void onAnswer(String response) async {
    try {
      HapticFeedback.lightImpact(); // Provide tactile feedback
      
      setState(() {
        displayedQuestions[currentQuestionIndex].userResponse = response;
        displayedQuestions[currentQuestionIndex].answeredAt = DateTime.now();

        if (response.toLowerCase() == 'yes' &&
            displayedQuestions[currentQuestionIndex].followUps.isNotEmpty) {
          displayedQuestions.addAll(displayedQuestions[currentQuestionIndex].followUps);
        }

        currentQuestionIndex++;
      });

      await _saveProgress(); // Save progress after each answer

      if (currentQuestionIndex >= displayedQuestions.length) {
        await _submitResponses();
      }
    } catch (e) {
      _showError("Failed to process answer. Please try again.");
    }
  }

  Future<void> _submitResponses() async {
    if (isSubmitting) return; // Prevent double submission

    setState(() {
      isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedQuestionnaire', true);

      // Prepare data with categories and timestamps
      List<Map<String, dynamic>> responses = displayedQuestions.map((question) => {
        'questionText': question.questionText,
        'userResponse': question.userResponse,
        'category': question.category,
        'answeredAt': question.answeredAt?.toIso8601String(),
        'isFollowUp': question.isFollowUp,
      }).toList();

      // Store responses with metadata
      await _firestore
          .collection('users')
          .doc(widget.uid)
          .collection('questionnaireResponses')
          .add({
        'responses': responses,
        'completedAt': Timestamp.now(),
        'deviceInfo': await _getDeviceInfo(),
      });

      widget.onComplete?.call(); // Trigger completion callback

      // Show success message before navigation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Responses saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Delayed navigation
      await Future.delayed(Duration(seconds: 2));
      _navigateToNextScreen();
    } catch (e) {
      _showError("Failed to save responses. Please try again.");
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // Add relevant device info for analytics
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Theme.of(context).platform.toString(),
    };
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog before leaving
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Leave Questionnaire?'),
            content: Text('Your progress will be saved, but you\'ll need to complete the questionnaire later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('STAY'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('LEAVE'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Health Check-In",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent.shade100],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.teal.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade700),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (currentQuestionIndex < displayedQuestions.length) ...[
                                _buildQuestionContent(),
                              ] else ...[
                                _buildCompletionContent(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    final question = displayedQuestions[currentQuestionIndex];
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: Column(
        key: ValueKey<int>(currentQuestionIndex),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.questionText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade900,
            ),
          ),
          if (question.description != null) ...[
            SizedBox(height: 8),
            Text(
              question.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAnswerButton("Yes", Colors.teal),
              _buildAnswerButton("No", Colors.grey.shade400),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(String text, Color color) {
    return ElevatedButton(
      onPressed: isSubmitting ? null : () => onAnswer(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(text, style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildCompletionContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSubmitting)
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.teal))
          else ...[
            Icon(
              Icons.check_circle_outline,
              color: Colors.teal,
              size: 60,
            ),
            SizedBox(height: 20),
            Text(
              "Thank you for completing the questionnaire!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}