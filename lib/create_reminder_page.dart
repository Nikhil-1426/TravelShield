import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:health_passport/profile_page.dart';
import 'package:health_passport/settings_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class CreateReminderPage extends StatefulWidget {
  final String uid;
  const CreateReminderPage({Key? key, required this.uid}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CreateReminderPageState createState() => _CreateReminderPageState();
}

class _CreateReminderPageState extends State<CreateReminderPage> {
  String? currentCity;
  String? destinationCity;
  DateTime? departureDate;
  DateTime? returnDate;
  String analysisResult = "";
  double? travelHealthScore;
  bool isApproved = false;

  final Map<String, String> cityToFileMap = {
    'Mumbai': "assets/mumbai_diet.xlsx",
    'Washington': "assets/washington_diet.xlsx",
    'Cape Town': "assets/capetown_diet.xlsx",
  };
  final List<String> cities = ['Washington', 'Mumbai', 'Cape Town'];

  Color _getScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Plan a Trip", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,  // Make AppBar transparent
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [ Colors.tealAccent,Colors.teal],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  ),
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                "Current City",
                Icon(Icons.flight_takeoff, color: Colors.teal),
                currentCity ?? "From",
                () => showCitySelectionDialog(true),
              ),
              SizedBox(height: 20),
              _buildSection(
                "Destination City",
                Icon(Icons.flight_land, color: Colors.teal),
                destinationCity ?? "To",
                () => showCitySelectionDialog(false),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSection2(
                      "Departure",
                      Icon(Icons.calendar_today, color: Colors.teal),
                      departureDate != null
                          ? "${departureDate!.day}/${departureDate!.month}/${departureDate!.year}"
                          : "Select Date",
                      () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            departureDate = picked;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildSection2(
                      "Return",
                      Icon(Icons.calendar_today, color: Colors.teal),
                      returnDate != null
                          ? "${returnDate!.day}/${returnDate!.month}/${returnDate!.year}"
                          : "Select Date",
                      () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: departureDate ?? DateTime.now(),
                          firstDate: departureDate ?? DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            returnDate = picked;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (currentCity != null && destinationCity != null &&
                        departureDate != null && returnDate != null) {
                      try {
                        await processAndSendData();
                        await calculateTravelHealthScore();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill in all fields!")),
                      );
                    }
                  },
                  child: Text("ANALYZE TRIP",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
_buildResultCard(
  "Travel Health Score",
  travelHealthScore != null
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Score: ${travelHealthScore!.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(travelHealthScore!),
                ),
              ),
              SizedBox(height: 8),
                          Text(
                            isApproved
                                ? "This trip is approved based on your health score."
                                : "This trip is not recommended based on your health score.",
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      )
                    : Text(
                        "Travel health score details will appear here after submission.",
                        style: TextStyle(color: Colors.black54),
                      ),
                travelHealthScore != null
                    ? "Score: ${travelHealthScore!.toStringAsFixed(2)}\n" +
                        (isApproved
                            ? "This trip is approved based on your health score."
                            : "This trip is not recommended based on your health score.")
                    : "Travel health score details will appear here after submission.",
              ),
              SizedBox(height: 20),
              _buildResultCard(
                "Summary",
                Text(
                  analysisResult.isEmpty
                      ? "Summary details will appear here..."
                      : analysisResult,
                  style: TextStyle(fontSize: 16),
                ),
                analysisResult.isEmpty
                    ? "Summary details will appear here..."
                    : analysisResult,
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
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(uid: widget.uid)),
            );
          } else if (index == 1) {
            Navigator.pop(context);
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

  Widget _buildSection(String title, Icon icon, String value, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: icon,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSection2(String title, Icon icon, String value, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: icon,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  final Map<String, String> supportedLanguages = {
  "English": "en",
  "French": "fr",
  "Spanish": "es",
  "German": "de",
  "Chinese": "zh",
};

  Widget _buildResultCard(String title, Widget content, String initialContent) {
  String currentContent = initialContent; // Holds the current content for translation

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.translate, color: Colors.teal),
                    onPressed: () {
                      String? selectedLanguage;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter dialogSetState) {
                              return AlertDialog(
                                title: const Text('Select Language'),
                                content: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedLanguage,
                                  hint: const Text('Select Language'),
                                  items: supportedLanguages.entries
                                      .map((entry) => DropdownMenuItem<String>(
                                            value: entry.value,
                                            child: Text(
                                              '${entry.key} (${entry.value})',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    dialogSetState(() {
                                      selectedLanguage = newValue;
                                    });
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (selectedLanguage != null && initialContent.isNotEmpty) {
                                        String translatedText = await translateText(
                                          initialContent,
                                          selectedLanguage!,
                                        );
                                        setState(() {
                                          currentContent = translatedText;
                                        });
                                      }
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Translate'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(currentContent, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      );
    },
  );
}

  void showAnalysisDialog(BuildContext context, String analysisResult) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height *
                    0.75), // Limit dialog height
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Analysis Result",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      analysisResult,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      },
    );
  }

  void showCitySelectionDialog(bool isCurrentCity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCurrentCity ? "Select Current City" : "Select Destination City"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: cities
                .map((city) => ListTile(
                      title: Text(city),
                      onTap: () {
                        setState(() {
                          if (isCurrentCity) {
                            currentCity = city;
                          } else {
                            destinationCity = city;
                          }
                        });
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Future<String> translateText(String text, String languageCode) async {
  const String flaskServerUrl = 'http://192.168.156.197:5000/translate';

  try {
    final Map<String, dynamic> payload = {
      'text': text,
      'to': [languageCode], // `to` must be a list as expected by Flask
      'from': 'en', // Optionally include the source language
    };

    final http.Response response = await http.post(
      Uri.parse(flaskServerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List translations = responseData['translations'];
      return translations.isNotEmpty ? translations[0]['translatedText'] : 'Translation unavailable.';
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      return 'Translation failed. Please try again.';
    }
  } catch (e) {
    print('Exception occurred: $e');
    return 'An error occurred. Please try again.';
  }
}

  // Helper function to load asset to a temporary file
  Future<File> loadAssetToTempFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath); // Load the asset
    final tempDir = await getTemporaryDirectory(); // Get temporary directory
    final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    return tempFile;
  }

  // Process the form data and send to the server
  Future<void> processAndSendData() async {
    // 1. Fetch responses from Firestore
    final responses = await fetchUserResponses();

    // 2. Convert to JSON file
    final jsonFilePath = await generateJsonFile(responses);

    // 3. Get city-specific diet files based on the selected cities
    final currentCityTempFile =
        await loadAssetToTempFile(cityToFileMap[currentCity]!);
    final destinationCityTempFile =
        await loadAssetToTempFile(cityToFileMap[destinationCity]!);

    // 4. Send data to Gemini
    await sendToGemini(
      currentCity: currentCity!,
      destinationCity: destinationCity!,
      jsonFilePath: jsonFilePath,
      currentCityXlsxPath: currentCityTempFile.path,
      destinationCityXlsxPath: destinationCityTempFile.path,
    );
  }

  // Fetch user responses from Firestore
  Future<Map<String, dynamic>> fetchUserResponses() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('questionnaireResponses')
          .orderBy('completedAt',
              descending: true) // Order by completion timestamp
          .limit(1) // Get most recent document
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return {
          'success': true,
          'responses': data['responses'] ?? [],
        };
      } else {
        print('No documents found for UID: ${widget.uid}'); // Debug print
        throw Exception("No questionnaire responses found.");
      }
    } catch (e) {
      print('Error fetching responses: $e'); // Debug print
      throw Exception("Error fetching responses: ${e.toString()}");
    }
  }

  // Generate a JSON file from the responses
  Future<String> generateJsonFile(Map<String, dynamic> responses) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/user_responses.json';
      final file = File(filePath);

      // Check if the file already exists
      if (file.existsSync()) {
        print("File already exists at $filePath");
      } else {
        print("File does not exist. Creating file at $filePath");
      }

      // Write the responses to the file
      await file.writeAsString(jsonEncode(responses));

      // Log the file path to confirm
      print("JSON file created at: $filePath");

      // Check if the file was created successfully
      if (file.existsSync()) {
        print("File successfully created at $filePath");
      } else {
        print("Failed to create file at $filePath");
      }

      return filePath;
    } catch (e) {
      print('Error generating JSON file: $e');
      throw Exception("Error generating JSON file: ${e.toString()}");
    }
  }

  // Update the calculateTravelHealthScore method:
// Update both methods to properly handle state updates

Future<void> calculateTravelHealthScore() async {
  if (currentCity == null || destinationCity == null) {
    throw Exception("Both current and destination cities must be selected.");
  }

  try {
    // Show loading state
    setState(() {
      travelHealthScore = null;
      analysisResult = "Calculating...";
    });

    // Create travel history document
    final travelHistoryRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('travelHistory')
        .add({
      'currentCity': currentCity,
      'destinationCity': destinationCity,
      'timestamp': FieldValue.serverTimestamp(),
      'travelHealthScore': null,
      'lastUpdated': FieldValue.serverTimestamp(),
      'travelID': null,
    });

    // Update the document with its ID
    await travelHistoryRef.update({
      'travelID': travelHistoryRef.id,
    });

    final String travelID = travelHistoryRef.id;

    final responses = await fetchUserResponses();
    final jsonFilePath = await generateJsonFile(responses);
    final currentCityTempFile = await loadAssetToTempFile(cityToFileMap[currentCity]!);
    final destinationCityTempFile = await loadAssetToTempFile(cityToFileMap[destinationCity]!);

    // First, get the analysis
    await sendToGemini(
      currentCity: currentCity!,
      destinationCity: destinationCity!,
      jsonFilePath: jsonFilePath,
      currentCityXlsxPath: currentCityTempFile.path,
      destinationCityXlsxPath: destinationCityTempFile.path,
    );

    // Then calculate score
    await sendTravelHealthScoreRequest(
      currentCity: currentCity!,
      destinationCity: destinationCity!,
      jsonFilePath: jsonFilePath,
      currentCityXlsxPath: currentCityTempFile.path,
      destinationCityXlsxPath: destinationCityTempFile.path,
      travelID: travelID,
    );

  } catch (e) {
    print('Error in calculateTravelHealthScore: $e');
    setState(() {
      analysisResult = "Error calculating score: ${e.toString()}";
      travelHealthScore = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error calculating travel health score: ${e.toString()}")),
    );
  }
}

Future<void> sendTravelHealthScoreRequest({
  required String currentCity,
  required String destinationCity,
  required String jsonFilePath,
  required String currentCityXlsxPath,
  required String destinationCityXlsxPath,
  required String travelID,
}) async {
  try {
    final uri = Uri.parse("http://192.168.156.197:5000/travel-health-score");
    final request = http.MultipartRequest('POST', uri);

    // Add fields
    request.fields['current_city'] = currentCity;
    request.fields['destination_city'] = destinationCity;

    // Add files
    request.files.add(await http.MultipartFile.fromPath('responses', jsonFilePath));
    request.files.add(await http.MultipartFile.fromPath('current_city_diet', currentCityXlsxPath));
    request.files.add(await http.MultipartFile.fromPath('destination_city_diet', destinationCityXlsxPath));

    // Send request and await response
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      // Print debug information
      print('Received response: ${response.body}');
      print('Parsed score: ${data['travelHealthScore']}');

      // Convert to double and handle potential null/invalid values
      final String healthScore = (data['travelHealthScore'].toString());

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('travelHistory')
          .doc(travelID)
          .update({
        'travelHealthScore': healthScore,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update state - Only update the score and approval status, keep existing analysis
      setState(() {
        print('Updating state with score: $healthScore'); // Debug print
        travelHealthScore = double.parse(healthScore);
        isApproved = double.parse(healthScore) >= 7.00;
      });
    } else {
      print('Error response: ${response.statusCode} - ${response.body}');
      throw Exception("Failed to calculate travel health score. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print('Error in sendTravelHealthScoreRequest: $e');
    setState(() {
      travelHealthScore = null;
      // Don't update analysisResult here to preserve the Gemini analysis
    });
    throw Exception("Error saving travel health score: ${e.toString()}");
  }
}

Future<void> sendToGemini({
  required String currentCity,
  required String destinationCity,
  required String jsonFilePath,
  required String currentCityXlsxPath,
  required String destinationCityXlsxPath,
}) async {
  final uri = Uri.parse("http://192.168.156.197:5000/analyze-travel-health");
  final request = http.MultipartRequest('POST', uri);

  // Attach cities info
  request.fields['current_city'] = currentCity;
  request.fields['destination_city'] = destinationCity;

  // Attach files
  request.files.add(await http.MultipartFile.fromPath('responses', jsonFilePath));
  request.files.add(await http.MultipartFile.fromPath('current_city_diet', currentCityXlsxPath));
  request.files.add(await http.MultipartFile.fromPath('destination_city_diet', destinationCityXlsxPath));

  try {
    // Send the request
    final response = await request.send();
    final responseData = await http.Response.fromStream(response);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      final analysis = data['analysis'];
      
      // Update only the analysis result
      setState(() {
        analysisResult = analysis;
      });
    } else {
      throw Exception("Failed to get analysis from Gemini. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print('Error in sendToGemini: $e');
    setState(() {
      analysisResult = "Error getting analysis: ${e.toString()}";
    });
    throw e;
  }
}

}