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
  int currentQuestionIndex = 0;
  List<Question> displayedQuestions = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isSubmitting = false;

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
  Question(
    questionText: "Have you ever had heart surgery?",
    category: "cardiovascular",
    description: "",
    followUps: [
      Question(
        questionText: "Was the surgery within the last 5 years?",
        isFollowUp: true,
        category: "cardiovascular",
      ),
      Question(
        questionText: "Do you experience any ongoing symptoms?",
        isFollowUp: true,
        category: "cardiovascular",
      ),
    ],
  ),
  Question(
    questionText: "Are you currently taking medication for heart disease?",
    category: "cardiovascular",
    description: "",
    followUps: [
      Question(
        questionText: "Do you experience any side effects from the medication?",
        isFollowUp: true,
        category: "cardiovascular",
      ),
    ],
  ),
  Question(
    questionText: "Do you have diabetes?",
    category: "endocrine",
    description: "",
    followUps: [
      Question(
        questionText: "Are you taking insulin?",
        isFollowUp: true,
        category: "endocrine",
      ),
      Question(
        questionText: "Do you monitor your blood sugar levels regularly?",
        isFollowUp: true,
        category: "endocrine",
      ),
    ],
  ),
  Question(
    questionText: "Are you on insulin therapy?",
    category: "endocrine",
    description: "",
    followUps: [
      Question(
        questionText: "Do you administer insulin daily?",
        isFollowUp: true,
        category: "endocrine",
      ),
      Question(
        questionText: "Have you experienced any severe drops in blood sugar levels recently?",
        isFollowUp: true,
        category: "endocrine",
      ),
    ],
  ),
  Question(
    questionText: "Have you been diagnosed with high blood pressure?",
    category: "cardiovascular",
    description: "",
    followUps: [
      Question(
        questionText: "Are you taking medication for it?",
        isFollowUp: true,
        category: "cardiovascular",
      ),
      Question(
        questionText: "Do you monitor your blood pressure regularly?",
        isFollowUp: true,
        category: "cardiovascular",
      ),
    ],
  ),
  Question(
    questionText: "Do you have chronic kidney issues?",
    category: "renal",
    description: "",
    followUps: [
      Question(
        questionText: "Have you undergone any medical procedures for this condition?",
        isFollowUp: true,
        category: "renal",
      ),
      Question(
        questionText: "Are you on a special diet?",
        isFollowUp: true,
        category: "renal",
      ),
    ],
  ),
  Question(
    questionText: "Have you been diagnosed with liver disease?",
    category: "hepatic",
    description: "",
    followUps: [
      Question(
        questionText: "Do you avoid alcohol due to this condition?",
        isFollowUp: true,
        category: "hepatic",
      ),
      Question(
        questionText: "Are you taking any medications for it?",
        isFollowUp: true,
        category: "hepatic",
      ),
    ],
  ),
  Question(
    questionText: "Have you ever had a stroke?",
    category: "neurological",
    description: "",
    followUps: [
      Question(
        questionText: "Are you undergoing therapy or rehabilitation?",
        isFollowUp: true,
        category: "neurological",
      ),
      Question(
        questionText: "Do you have mobility challenges as a result?",
        isFollowUp: true,
        category: "neurological",
      ),
    ],
  ),
  Question(
    questionText: "Do you have asthma?",
    category: "respiratory",
    description: "",
    followUps: [
      Question(
        questionText: "Do you use an inhaler?",
        isFollowUp: true,
        category: "respiratory",
      ),
      Question(
        questionText: "Have you had an asthma attack in the last 6 months?",
        isFollowUp: true,
        category: "respiratory",
      ),
    ],
  ),
  Question(
    questionText: "Have you been diagnosed with COPD?",
    category: "respiratory",
    description: "",
    followUps: [
      Question(
        questionText: "Are you using oxygen therapy?",
        isFollowUp: true,
        category: "respiratory",
      ),
      Question(
        questionText: "Do you experience breathlessness during routine activities?",
        isFollowUp: true,
        category: "respiratory",
      ),
    ],
  ),
  Question(
    questionText: "Do you have any allergies?",
    category: "immunological",
    description: "",
    followUps: [
      Question(
        questionText: "Are your allergies triggered by specific foods?",
        isFollowUp: true,
        category: "immunological",
      ),
      Question(
        questionText: "Do you carry emergency medication for allergies?",
        isFollowUp: true,
        category: "immunological",
      ),
    ],
  ),
  Question(
    questionText: "Have you ever been diagnosed with cancer?",
    category: "oncology",
    description: "",
    followUps: [
      Question(
        questionText: "Are you currently undergoing treatment?",
        isFollowUp: true,
        category: "oncology",
      ),
      Question(
        questionText: "Are there any dietary restrictions due to the treatment?",
        isFollowUp: true,
        category: "oncology",
      ),
    ],
  ),
  Question(
    questionText: "Do you have chronic back pain?",
    category: "musculoskeletal",
    description: "",
    followUps: [
      Question(
        questionText: "Have you undergone physiotherapy for it?",
        isFollowUp: true,
        category: "musculoskeletal",
      ),
      Question(
        questionText: "Do you take painkillers regularly for this condition?",
        isFollowUp: true,
        category: "musculoskeletal",
      ),
    ],
  ),
  Question(
    questionText: "Have you ever had a major surgery?",
    category: "general",
    description: "",
    followUps: [
      Question(
        questionText: "Was it within the last 3 years?",
        isFollowUp: true,
        category: "general",
      ),
      Question(
        questionText: "Are there ongoing complications related to the surgery?",
        isFollowUp: true,
        category: "general",
      ),
    ],
  ),
  Question(
    questionText: "Have you been hospitalized in the last year?",
    category: "general",
    description: "",
    followUps: [
      Question(
        questionText: "Was the hospitalization for an emergency condition?",
        isFollowUp: true,
        category: "general",
      ),
      Question(
        questionText: "Are you still recovering from that condition?",
        isFollowUp: true,
        category: "general",
      ),
    ],
  ),
  Question(
    questionText: "Have you ever had seizures?",
    category: "neurological",
    description: "",
    followUps: [
      Question(
        questionText: "Are you on medication for seizures?",
        isFollowUp: true,
        category: "neurological",
      ),
      Question(
        questionText: "Do you have regular neurological check-ups?",
        isFollowUp: true,
        category: "neurological",
      ),
    ],
  ),
  Question(
    questionText: "Do you have joint pain or arthritis?",
    category: "musculoskeletal",
    description: "",
    followUps: [
      Question(
        questionText: "Is it severe enough to restrict your movement?",
        isFollowUp: true,
        category: "musculoskeletal",
      ),
      Question(
        questionText: "Do you take medication for the pain?",
        isFollowUp: true,
        category: "musculoskeletal",
      ),
    ],
  ),
  Question(
    questionText: "Do you experience frequent headaches or migraines?",
    category: "neurological",
    description: "",
    followUps: [
      Question(
        questionText: "Do you take medication for them?",
        isFollowUp: true,
        category: "neurological",
      ),
      Question(
        questionText: "Do certain foods or environments trigger your headaches?",
        isFollowUp: true,
        category: "neurological",
      ),
    ],
  ),
  Question(
    questionText: "Do you have sleep apnea?",
    category: "respiratory",
    description: "",
    followUps: [
      Question(
        questionText: "Do you use a CPAP machine?",
        isFollowUp: true,
        category: "respiratory",
      ),
      Question(
        questionText: "Does sleep apnea affect your daily activities?",
        isFollowUp: true,
        category: "respiratory",
      ),
    ],
  ),
  Question(
    questionText: "Have you been diagnosed with a thyroid disorder?",
    category: "endocrine",
    description: "",
    followUps: [
      Question(
        questionText: "Is it hypothyroidism?",
        isFollowUp: true,
        category: "endocrine",
      ),
      Question(
        questionText: "Are you on hormone replacement therapy?",
        isFollowUp: true,
        category: "endocrine",
      ),
    ],
  ),
  Question(
    questionText: "Do you experience chronic fatigue?",
    category: "general",
    description: "",
    followUps: [
      Question(
        questionText: "Have you consulted a doctor for this condition?",
        isFollowUp: true,
        category: "general",
      ),
      Question(
        questionText: "Is it linked to another diagnosed condition?",
        isFollowUp: true,
        category: "general",
      ),
    ],
  ),
  Question(
    questionText: "Have you ever been diagnosed with anemia?",
    category: "hematology",
    description: "",
    followUps: [
      Question(
        questionText: "Do you take iron supplements?",
        isFollowUp: true,
        category: "hematology",
      ),
      Question(
        questionText: "Are there dietary restrictions associated with it?",
        isFollowUp: true,
        category: "hematology",
      ),
    ],
  ),
  Question(
    questionText: "Do you have vision problems?",
    category: "ophthalmology",
    description: "",
    followUps: [
      Question(
        questionText: "Are you using prescription glasses or contact lenses?",
        isFollowUp: true,
        category: "ophthalmology",
      ),
      Question(
        questionText: "Do you have an eye condition like cataracts or glaucoma?",
        isFollowUp: true,
        category: "ophthalmology",
      ),
    ],
  ),
  Question(
    questionText: "Do you have hearing loss?",
    category: "audiology",
    description: "",
    followUps: [
      Question(
        questionText: "Do you use hearing aids?",
        isFollowUp: true,
        category: "audiology",
      ),
      Question(
        questionText: "Has it worsened in the past year?",
        isFollowUp: true,
        category: "audiology",
      ),
    ],
  ),
  Question(
    questionText: "Have you ever been treated for mental health issues?",
    category: "mental_health",
    description: "",
    followUps: [
      Question(
        questionText: "Are you currently under therapy or medication?",
        isFollowUp: true,
        category: "mental_health",
      ),
      Question(
        questionText: "Do you experience any stress-related symptoms?",
        isFollowUp: true,
        category: "mental_health",
      ),
    ],
  ),
  Question(
    questionText: "Have you been diagnosed with osteoporosis?",
    category: "musculoskeletal",
    description: "",
    followUps: [
      Question(
        questionText: "Are you on calcium or vitamin D supplements?",
        isFollowUp: true,
        category: "musculoskeletal",
      ),
      Question(
        questionText: "Have you experienced fractures in the last year?",
        isFollowUp: true,
        category: "musculoskeletal",
      ),
    ],
  ),
  Question(
    questionText: "Do you have digestive disorders like IBS or GERD?",
    category: "gastroenterology",
    description: "",
    followUps: [
      Question(
        questionText: "Are you on a restricted diet for this condition?",
        isFollowUp: true,
        category: "gastroenterology",
      ),
      Question(
        questionText: "Are you taking any medications?",
        isFollowUp: true,
        category: "gastroenterology",
      ),
    ],
  ),
  Question(
    questionText: "Do you experience shortness of breath during physical activity?",
    category: "respiratory",
    description: "",
    followUps: [
      Question(
        questionText: "Have you been diagnosed with a respiratory condition?",
        isFollowUp: true,
        category: "respiratory",
      ),
      Question(
        questionText: "Do you avoid certain activities due to this issue?",
        isFollowUp: true,
        category: "respiratory",
      ),
    ],
  ),
  Question(
    questionText: "Do you have skin conditions like eczema or psoriasis?",
    category: "dermatology",
    description: "",
    followUps: [
      Question(
        questionText: "Are you on any topical or oral medications for it?",
        isFollowUp: true,
        category: "dermatology",
      ),
      Question(
        questionText: "Do specific triggers worsen your condition?",
        isFollowUp: true,
        category: "dermatology",
      ),
    ],
  ),
];
  
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
      displayedQuestions = questions.where((q) => !q.isFollowUp).toList();
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
          displayedQuestions.insertAll(currentQuestionIndex + 1, displayedQuestions[currentQuestionIndex].followUps);
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
      MaterialPageRoute(builder: (context) => HomePage(uid: widget.uid)),
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