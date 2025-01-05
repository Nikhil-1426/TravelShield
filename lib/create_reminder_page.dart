import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class CreateReminderPage extends StatefulWidget {
  final String uid; // User's UID
  const CreateReminderPage({Key? key, required this.uid}) : super(key: key);

  @override
  _CreateReminderPageState createState() => _CreateReminderPageState();
}

class _CreateReminderPageState extends State<CreateReminderPage> {
  String? currentCity;
  String? destinationCity;
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
            Text(
              "Current City",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: currentCity,
              items: cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  currentCity = value;
                });
              },
              hint: Text("Select Current City"),
            ),
            SizedBox(height: 16),
            Text(
              "Destination City",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: destinationCity,
              items: cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
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
                  // Check if both cities are selected and valid
                  if (currentCity != null &&
                      destinationCity != null &&
                      cityToFileMap.containsKey(currentCity!) &&
                      cityToFileMap.containsKey(destinationCity!)) {
                    try {
                      await processAndSendData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Data successfully submitted to Gemini for analysis!"),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: ${e.toString()}"),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please select both cities!"),
                      ),
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
          ],
        ),
      ),
    );
  }

  Future<File> loadAssetToTempFile(String assetPath) async {
  final byteData = await rootBundle.load(assetPath); // Load the asset
  final tempDir = await getTemporaryDirectory(); // Get temporary directory
  final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
  await tempFile.writeAsBytes(byteData.buffer.asUint8List());
  return tempFile;
}

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
      jsonFilePath: jsonFilePath,
      currentCityXlsxPath: currentCityTempFile.path,
    destinationCityXlsxPath: destinationCityTempFile.path,
    );
  }

  Future<Map<String, dynamic>> fetchUserResponses() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc('84p0YtbVEVNpzwgOcOokGJWz0Wf2')
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


  Future<void> sendToGemini({
    required String jsonFilePath,
    required String currentCityXlsxPath,
    required String destinationCityXlsxPath,
  }) async {
    final uri = Uri.parse("http://127.0.0.1:5000/process-travel-health");
    final request = http.MultipartRequest('POST', uri);

    // Attach JSON file
    request.files
        .add(await http.MultipartFile.fromPath('responses', jsonFilePath));

    // Attach current and destination city dietary files
    request.files.add(
        await http.MultipartFile.fromPath('current_city', currentCityXlsxPath));
    request.files.add(await http.MultipartFile.fromPath(
        'destination_city', destinationCityXlsxPath));

    // Send the request
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception(
          "Failed to send data to Gemini. Status code: ${response.statusCode}");
    }
  }
}
