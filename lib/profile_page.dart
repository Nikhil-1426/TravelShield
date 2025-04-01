import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'settings_page.dart';
import 'home_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String name, age, gender, photoUrl;
  bool profileUpdated = false;
  List<String> selectedVaccinations = [];
  final List<String> vaccinationOptions = [
    'Hepatitis A',
    'Hepatitis B',
    'Typhoid',
    'DTaP',
    'MMR',
    'Malaria',
    'Polio',
    'Yellow Fever',
    'Influenza',
    'COVID - 19'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
           style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        
          
        ),
        backgroundColor: Colors.transparent,  // Make AppBar transparent
  flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ Colors.tealAccent,Color.fromARGB(255, 19, 152, 152)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
        
        centerTitle: true,
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
        child: SafeArea(
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Error fetching profile data.",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                );
              }

              var userData =
                  snapshot.data?.data() as Map<String, dynamic>? ?? {};
              name = userData['name'] ?? 'Guest User';
              age = userData['age'] ?? 'Unknown';
              gender = userData['gender'] ?? 'Unknown';
              photoUrl = userData['photoUrl'] ?? '';

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.teal, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.teal.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: photoUrl.isEmpty
                                        ? const Icon(Icons.person,
                                            size: 80, color: Colors.teal)
                                        : Image.network(photoUrl,
                                            fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.teal,
                                    radius: 18,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit,
                                          size: 18, color: Colors.white),
                                      onPressed: _showUpdateProfileDialog,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildInfoChip(Icons.cake, age),
                                const SizedBox(width: 16),
                                _buildInfoChip(Icons.person, gender),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Travel History Section
                      _buildSectionCard(
                        "Travel History",
                        Icons.flight_takeoff,
                        _buildTravelHistory(),
                      ),

                      const SizedBox(height: 24),

                      // Vaccinations Section
                      _buildSectionCard(
                        "Vaccinations",
                        Icons.healing,
                        _buildVaccinations(),
                        action: IconButton(
                          icon:
                              const Icon(Icons.add_circle, color: Colors.teal),
                          onPressed: _showVaccinationDialog,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        items: const [
          Icon(Icons.person, size: 30, color: Colors.white),
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.settings, size: 30, color: Colors.white),
        ],
        color: Colors.teal,
        buttonBackgroundColor: Colors.tealAccent,
        backgroundColor: const Color.fromARGB(255, 216, 248, 243),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(uid: widget.uid)),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SettingsPage(uid: widget.uid)),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.teal),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content,
      {Widget? action}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                if (action != null) action,
              ],
            ),
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildTravelHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('travelHistory')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Error loading travel history.'),
          );
        }

        var travelHistory = snapshot.data?.docs ?? [];

        if (travelHistory.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                "No travel history available.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: travelHistory.length,
          itemBuilder: (context, index) {
            var trip = travelHistory[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flight, color: Colors.teal),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${trip['currentCity']} → ${trip['destinationCity']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trip['travelHealthScore'] ?? 'N/A' ,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVaccinations() {
    return StreamBuilder<QuerySnapshot>(
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
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Error loading vaccinations.'),
          );
        }

        var vaccinations = snapshot.data?.docs ?? [];

        if (vaccinations.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                "No vaccination records available.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vaccinations.length,
          itemBuilder: (context, index) {
            var vaccination =
                vaccinations[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccination['vaccineName'] ?? 'Unknown Vaccine',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vaccination['dateAdministered'] ?? 'N/A',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .collection('vaccinations')
              .add({
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
            decoration: const InputDecoration(
              labelText: "Age",
              hintText: "Enter Age",
            ),
            keyboardType: TextInputType.number,
          ),
          DropdownButtonFormField<String>(
            value: genderController.text.isNotEmpty ? genderController.text : null,
            items: ['Male', 'Female', 'Other'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              genderController.text = newValue!;
            },
            decoration: const InputDecoration(
              labelText: "Gender",
              hintText: "Select Gender",
            ),
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
            int? age = int.tryParse(ageController.text);
            if (age == null || age <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter a valid age greater than 0")),
              );
              return;
            }
            if (genderController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select a gender")),
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
                age = int.tryParse(ageController.text);
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