import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart'; // Import the profile page
import 'home_page.dart';    // Import the home page
import 'settings_page.dart'; // Import the settings page

class CreateReminderPage extends StatefulWidget {
  final String uid; 
  const CreateReminderPage({Key? key, required this.uid}) : super(key: key);

  @override
  _CreateReminderPageState createState() => _CreateReminderPageState();
}

class _CreateReminderPageState extends State<CreateReminderPage> {
  String? currentCity;
  String? destinationCity;
  String analysisResult = "";  // Variable to store the response

  final Map<String, String> cityToFileMap = {
    'Mumbai': "assets/mumbai_diet.xlsx",
    'Washington': "assets/washington_diet.xlsx",
    'Cape Town': "assets/capetown_diet.xlsx",
  };
  final List<String> cities = ['Washington', 'Mumbai', 'Cape Town'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Reminder"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdowns for selecting cities
            Text("Current City", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(border: OutlineInputBorder()),
              value: currentCity,
              items: cities.map((city) {
                return DropdownMenuItem<String>(value: city, child: Text(city));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  currentCity = value;
                });
              },
              hint: Text("Select Current City"),
            ),
            SizedBox(height: 16),
            Text("Destination City", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(border: OutlineInputBorder()),
              value: destinationCity,
              items: cities.map((city) {
                return DropdownMenuItem<String>(value: city, child: Text(city));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  destinationCity = value;
                });
              },
              hint: Text("Select Destination City"),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (currentCity != null &&
                      destinationCity != null &&
                      cityToFileMap.containsKey(currentCity!) &&
                      cityToFileMap.containsKey(destinationCity!)) {
                    try {
                      await processAndSendData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Data successfully submitted to Gemini for analysis!")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select both cities!")),
                    );
                  }
                },
                child: Text("Submit"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 1, // Keep Home page selected by default
        items: <Widget>[
          Icon(Icons.person, size: 30, color: Colors.white), // Profile icon
          Icon(Icons.home, size: 30, color: Colors.white),   // Home icon
          Icon(Icons.settings, size: 30, color: Colors.white), // Settings icon
        ],
        color: Colors.teal,
        buttonBackgroundColor: Colors.tealAccent,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
       onTap: (index) {
          String uid = FirebaseAuth.instance.currentUser?.uid ?? 'default-uid';

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage(uid: uid)),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage(uid: uid)),
            );
          }
        },
      ),
    );
  }

  // Show the result in a Dialog (Popup)
  void showAnalysisDialog(BuildContext context, String analysisResult) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75), // Limit dialog height
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
    final currentCityTempFile = await loadAssetToTempFile(cityToFileMap[currentCity]!);
    final destinationCityTempFile = await loadAssetToTempFile(cityToFileMap[destinationCity]!);

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
          .orderBy('completedAt', descending: true)  // Order by completion timestamp
          .limit(1)  // Get most recent document
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return {
          'success': true,
          'responses': data['responses'] ?? [],
        };
      } else {
        print('No documents found for UID: ${widget.uid}');  // Debug print
        throw Exception("No questionnaire responses found.");
      }
    } catch (e) {
      print('Error fetching responses: $e');  // Debug print
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

  // Send the data to Gemini for analysis
  Future<void> sendToGemini({
  required String currentCity,
  required String destinationCity,
  required String jsonFilePath,
  required String currentCityXlsxPath,
  required String destinationCityXlsxPath,
}) async {
  final uri = Uri.parse("http://192.168.156.197:5000/analyze-travel-health"); // Updated endpoint
  final request = http.MultipartRequest('POST', uri);

  // Attach cities info
  request.fields['current_city'] = currentCity;
  request.fields['destination_city'] = destinationCity;

  // Attach JSON file with user responses
  request.files.add(await http.MultipartFile.fromPath('responses', jsonFilePath));

  // Attach the city-specific diet files
  request.files.add(await http.MultipartFile.fromPath('current_city_diet', currentCityXlsxPath));
  request.files.add(await http.MultipartFile.fromPath('destination_city_diet', destinationCityXlsxPath));

  // Send the request
  final response = await request.send();
  if (response.statusCode == 200) {
    // Process the response from the server
    final responseData = await http.Response.fromStream(response);
    final analysisResult = jsonDecode(responseData.body)['analysis'];

    // Show the analysis result in a dialog
    showAnalysisDialog(context, analysisResult);
  } else {
    throw Exception("Failed to send data to Gemini. Status code: ${response.statusCode}");
  }
}

}
