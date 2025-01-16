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
  String analysisResult = ""; // Variable to store the analysis result
  String travelHealthScore = ""; // Variable to store the travel health score

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
        title: const Text("Create Reminder"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Current City",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              value: currentCity,
              items: cities.map((city) {
                return DropdownMenuItem<String>(value: city, child: Text(city));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  currentCity = value;
                });
              },
              hint: const Text("Select Current City"),
            ),
            const SizedBox(height: 16),
            const Text("Destination City",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              value: destinationCity,
              items: cities.map((city) {
                return DropdownMenuItem<String>(value: city, child: Text(city));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  destinationCity = value;
                });
              },
              hint: const Text("Select Destination City"),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (currentCity != null &&
                      destinationCity != null &&
                      cityToFileMap.containsKey(currentCity!) &&
                      cityToFileMap.containsKey(destinationCity!)) {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Data successfully submitted for analysis!")),
                      );
                      await processAndSendData();
                      await calculateTravelHealthScore();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select both cities!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text("Submit"),
              ),
            ),
            const SizedBox(height: 32),
            const Text("Analysis Result",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: analysisResult.isEmpty
                  ? const Center(child: Text("No analysis yet"))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        analysisResult,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
            ),
            const SizedBox(height: 32),
            const Text("Travel Health Score",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: travelHealthScore.isEmpty
                    ? const Text("No health score calculated yet")
                    : Text(
                        "Your Travel Health Score: $travelHealthScore",
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File> loadAssetToTempFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    return tempFile;
  }

  Future<void> processAndSendData() async {
    final responses = await fetchUserResponses();
    final jsonFilePath = await generateJsonFile(responses);
    final currentCityTempFile =
        await loadAssetToTempFile(cityToFileMap[currentCity]!);
    final destinationCityTempFile =
        await loadAssetToTempFile(cityToFileMap[destinationCity]!);

    await sendToGemini(
      currentCity: currentCity!,
      destinationCity: destinationCity!,
      jsonFilePath: jsonFilePath,
      currentCityXlsxPath: currentCityTempFile.path,
      destinationCityXlsxPath: destinationCityTempFile.path,
    );
  }

  Future<Map<String, dynamic>> fetchUserResponses() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('questionnaireResponses')
        .orderBy('completedAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data();
      return {
        'success': true,
        'responses': data['responses'] ?? [],
      };
    } else {
      throw Exception("No questionnaire responses found.");
    }
  }

  Future<String> generateJsonFile(Map<String, dynamic> responses) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/user_responses.json';
    final file = File(filePath);
    await file.writeAsString(jsonEncode(responses));
    return filePath;
  }

  Future<void> calculateTravelHealthScore() async {
    final responses = await fetchUserResponses();
    final jsonFilePath = await generateJsonFile(responses);
    final currentCityTempFile =
        await loadAssetToTempFile(cityToFileMap[currentCity]!);
    final destinationCityTempFile =
        await loadAssetToTempFile(cityToFileMap[destinationCity]!);

    final uri = Uri.parse("http://192.168.76.29:5000/travel-health-score");
    final request = http.MultipartRequest('POST', uri);

    request.fields['current_city'] = currentCity!;
    request.fields['destination_city'] = destinationCity!;
    request.files.add(await http.MultipartFile.fromPath('responses', jsonFilePath));
    request.files.add(await http.MultipartFile.fromPath(
        'current_city_diet', currentCityTempFile.path));
    request.files.add(await http.MultipartFile.fromPath(
        'destination_city_diet', destinationCityTempFile.path));

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      setState(() {
        travelHealthScore = jsonDecode(responseData.body)['travelHealthScore'];
      });
    } else {
      throw Exception(
          "Failed to calculate travel health score. Status code: ${response.statusCode}");
    }
  }

  Future<void> sendToGemini({
    required String currentCity,
    required String destinationCity,
    required String jsonFilePath,
    required String currentCityXlsxPath,
    required String destinationCityXlsxPath,
  }) async {
    final uri = Uri.parse("http://192.168.76.29:5000/analyze-travel-health");
    final request = http.MultipartRequest('POST', uri);

    request.fields['current_city'] = currentCity;
    request.fields['destination_city'] = destinationCity;
    request.files
        .add(await http.MultipartFile.fromPath('responses', jsonFilePath));
    request.files.add(await http.MultipartFile.fromPath(
        'current_city_diet', currentCityXlsxPath));
    request.files.add(await http.MultipartFile.fromPath(
        'destination_city_diet', destinationCityXlsxPath));

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      setState(() {
        analysisResult = jsonDecode(responseData.body)['analysis'];
      });
    } else {
      throw Exception("Failed to send data to Gemini.");
    }
  }
}
