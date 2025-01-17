import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class CreateReminderPage extends StatefulWidget {
  final String uid;
  const CreateReminderPage({Key? key, required this.uid}) : super(key: key);

  @override
  _CreateReminderPageState createState() => _CreateReminderPageState();
}

class _CreateReminderPageState extends State<CreateReminderPage> {
  String? currentCity;
  String? destinationCity;
  String? departureDate;
  String? returnDate;
  String analysisResult = "";
  double? travelHealthScore;
  bool isApproved = false;

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Plan a Trip"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Current City",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.flight_takeoff),
                title: Text(currentCity ?? "From",
                    style: TextStyle(color: Colors.black54)),
                onTap: () {
                  showCitySelectionDialog(true);
                },
              ),
            ),
            SizedBox(height: 24),
            Text("Destination City",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.flight_land),
                title: Text(destinationCity ?? "To",
                    style: TextStyle(color: Colors.black54)),
                onTap: () {
                  showCitySelectionDialog(false);
                },
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Departure Date",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.calendar_today),
                          title: Text("Select Date",
                              style: TextStyle(color: Colors.black54)),
                          onTap: () {
                            // Add date picker functionality
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Add Return Date",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.calendar_today),
                          title: Text("Select Date",
                              style: TextStyle(color: Colors.black54)),
                          onTap: () {
                            // Add date picker functionality
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (currentCity != null && destinationCity != null) {
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
                      SnackBar(content: Text("Please select both cities!")),
                    );
                  }
                },
                child: Text("SUBMIT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
            if (travelHealthScore != null) ...[
              Center(
                child: Column(
                  children: [
                    Text("From -> To",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    Text("Approved",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.green)),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "${travelHealthScore?.toStringAsFixed(1)}",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 32),
            Text("Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(16),
              child: Text(analysisResult.isEmpty
                  ? "Summary details go here..."
                  : analysisResult),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
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

  // Process the form data and send it to the /travel-health-score endpoint

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
Future<void> calculateTravelHealthScore() async {
  if (currentCity == null || destinationCity == null) {
    throw Exception("Both current and destination cities must be selected.");
  }

  try {
    // Create a single document with all required fields
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
          'travelID': null  // Will be updated with the document ID
        });

    // Update the document with its ID
    await travelHistoryRef.update({
      'travelID': travelHistoryRef.id,
    });

    final String travelID = travelHistoryRef.id;

    // Rest of your existing code...
    final responses = await fetchUserResponses();
    final jsonFilePath = await generateJsonFile(responses);
    final currentCityTempFile = await loadAssetToTempFile(cityToFileMap[currentCity]!);
    final destinationCityTempFile = await loadAssetToTempFile(cityToFileMap[destinationCity]!);

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error calculating travel health score: ${e.toString()}")),
    );
  }
}


// Send the request to the /travel-health-score endpoint
  Future<void> sendTravelHealthScoreRequest({
    required String currentCity,
    required String destinationCity,
    required String jsonFilePath,
    required String currentCityXlsxPath,
    required String destinationCityXlsxPath,
    required String travelID,
  }) async {
    try {
      final uri = Uri.parse("http://192.168.76.29:5000/travel-health-score");
      final request = http.MultipartRequest('POST', uri);

      // Attach fields
      request.fields['current_city'] = currentCity;
      request.fields['destination_city'] = destinationCity;

      // Attach files
      request.files.add(await http.MultipartFile.fromPath('responses', jsonFilePath));
      request.files.add(await http.MultipartFile.fromPath('current_city_diet', currentCityXlsxPath));
      request.files.add(await http.MultipartFile.fromPath('destination_city_diet', destinationCityXlsxPath));

      // Send the request
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final healthScore = jsonDecode(responseData.body)['travelHealthScore'];

        // Update the existing document with the health score
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .collection('travelHistory')
            .doc(travelID)
            .update({
          'travelHealthScore': healthScore,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Show the health score in a dialog
        showAnalysisDialog(context, "Your Travel Health Score: $healthScore");
      } else {
        throw Exception("Failed to calculate travel health score. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print('Error in sendTravelHealthScoreRequest: $e');
      throw Exception("Error saving travel health score: ${e.toString()}");
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
  final uri = Uri.parse("http://192.168.76.29:5000/analyze-travel-health"); // Updated endpoint
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

    // Update the analysis result and display it in the summary container
    setState(() {
      this.analysisResult = analysisResult;
    });
  } else {
    throw Exception("Failed to send data to Gemini. Status code: ${response.statusCode}");
  }
}

}