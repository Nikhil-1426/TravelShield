import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'settings_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid; // User's unique ID
  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String name, age, gender, photoUrl;
  bool profileUpdated = false;
  List<String> selectedVaccinations = [];
  final List<String> vaccinationOptions = [
    'Hepatitis A', 'Hepatitis B', 'Typhoid', 'DTaP', 'MMR', 'Malaria', 
    'Polio', 'Yellow Fever', 'Influenza', 'COVID - 19'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(widget.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Error fetching profile data.",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            }

            var userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
            name = userData['name'] ?? 'Guest User';
            age = userData['age'] ?? 'Unknown';
            gender = userData['gender'] ?? 'Unknown';
            photoUrl = userData['photoUrl'] ?? '';

            return Column(
              children: [
                // Top Header Section
                Container(
                  height: 60,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.teal, Colors.tealAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          "Travel Shield",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 18,
                        child: IconButton(
                          icon: const Icon(
                            Icons.logout,
                            size: 24,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Implement logout functionality
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Picture
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.teal, width: 2),
                        ),
                        child: photoUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.grey,
                              )
                            : ClipOval(
                                child: Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      // Profile Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name: $name",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Age: $age",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Gender: $gender",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 24,
                          color: Colors.teal,
                        ),
                        onPressed: () {
                          _showUpdateProfileDialog();
                        },
                      ),
                    ],
                  ),
                ),

                // Travel History Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Travel History",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          size: 24,
                          color: Colors.teal,
                        ),
                        onPressed: () {
                          // Implement refresh functionality if needed
                        },
                      ),
                    ],
                  ),
                ),

                // Fetching Travel History from Firestore
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .collection('travelHistory')
                      .orderBy('timestamp') // Ensure we fetch by the timestamp
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading travel history.'));
                    }
                    var travelHistory = snapshot.data?.docs ?? [];

                    return Expanded(
                      child: travelHistory.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: travelHistory.length,
                              itemBuilder: (context, index) {
                                var trip = travelHistory[index];
                                var tripData = trip.data() as Map<String, dynamic>;
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${tripData['currentCity'] ?? 'Unknown'} → ${tripData['destinationCity'] ?? 'Unknown'}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tripData['date'] ?? 'N/A',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text(
                                "No travel history available.",
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ),
                    );
                  },
                ),

                // Vaccinations Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Vaccinations",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 24,
                          color: Colors.teal,
                        ),
                        onPressed: _showVaccinationDialog,
                      ),
                    ],
                  ),
                ),

                // Fetching Vaccinations from Firestore
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .collection('vaccinations')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading vaccinations.'));
                    }
                    var vaccinations = snapshot.data?.docs ?? [];

                    return Expanded(
                      child: vaccinations.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: vaccinations.length,
                              itemBuilder: (context, index) {
                                var vaccination = vaccinations[index];
                                var vaccinationData = vaccination.data() as Map<String, dynamic>;
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vaccinationData['vaccineName'] ?? 'Unknown Vaccine',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        vaccinationData['dateAdministered'] ?? 'N/A',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text(
                                "No vaccination records available.",
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ),
                    );
                  },
                ),

                // Curved Bottom Navigation Bar
                CurvedNavigationBar(
                  index: 0,
                  items: const [
                    Icon(Icons.person, size: 30, color: Colors.white),
                    Icon(Icons.home, size: 30, color: Colors.white),
                    Icon(Icons.settings, size: 30, color: Colors.white),
                  ],
                  color: Colors.teal,
                  buttonBackgroundColor: Colors.tealAccent,
                  backgroundColor: Colors.white,
                  animationCurve: Curves.easeInOut,
                  animationDuration: const Duration(milliseconds: 300),
                  onTap: (index) {
                    if (index == 0) {
                      //Already on profile page
                    } else if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage(uid: widget.uid)),
                      );
                    } else if (index == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage(uid: widget.uid)),
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showVaccinationDialog() async {
    final updatedVaccinations = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Vaccinations"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: vaccinationOptions.map((vac) {
                return CheckboxListTile(
                  title: Text(vac),
                  value: selectedVaccinations.contains(vac),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedVaccinations.add(vac);
                      } else {
                        selectedVaccinations.remove(vac);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, selectedVaccinations);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (updatedVaccinations != null && updatedVaccinations.isNotEmpty) {
      setState(() {
        selectedVaccinations = updatedVaccinations;
      });

      // Update Firebase with selected vaccinations
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('vaccinations')
          .get()
          .then((snapshot) {
            snapshot.docs.forEach((doc) {
              doc.reference.delete(); // Remove existing vaccinations
            });

            // Add the selected vaccinations to Firestore
            for (var vaccine in selectedVaccinations) {
              FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('vaccinations').add({
                'vaccineName': vaccine,
                'dateAdministered': DateTime.now().toString(),
              });
            }
          });
    }
  }

    void _showUpdateProfileDialog() {
    final ageController = TextEditingController();
    final genderController = TextEditingController();
    final photoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "Age", hintText: "Enter Age"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: genderController,
                decoration: const InputDecoration(labelText: "Gender", hintText: "Enter Gender"),
              ),
              TextField(
                controller: photoController,
                decoration: const InputDecoration(labelText: "Photo URL (optional)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (ageController.text.isEmpty || genderController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Age and Gender are required")),
                  );
                  return;
                }
                // Update the Firestore data
                FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
                  'age': ageController.text,
                  'gender': genderController.text,
                  'photoUrl': photoController.text.isNotEmpty ? photoController.text : photoUrl,
                }).then((_) {
                  setState(() {
                    age = ageController.text;
                    gender = genderController.text;
                    if (photoController.text.isNotEmpty) {
                      photoUrl = photoController.text;
                    }
                    profileUpdated = true;
                  });
                  Navigator.of(context).pop();
                });
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }
}