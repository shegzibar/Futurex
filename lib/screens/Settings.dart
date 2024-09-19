import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futurex/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? userIndex;

  @override
  void initState() {
    super.initState();
    _loadUserIndex();
  }

  // Load the user's index from SharedPreferences
  Future<void> _loadUserIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userIndex = prefs.getString('studentIndex'); // Assuming 'index' is the key
    });
  }

  // Function to fetch the user data by index from Firestore
  Future<Map<String, dynamic>> _getUserDataByIndex() async {
    if (userIndex == null) {
      throw Exception("User index not found");
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Students')
        .where('index', isEqualTo: userIndex) // Compare with user's index
        .get();

    if (snapshot.docs.isNotEmpty) {
      // If a user with the given index is found, return the first user's data
      return snapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      throw Exception("User not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // User logo - Circle Avatar
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
              child: CircleAvatar(
                radius: 60.0,
                backgroundImage: AssetImage('assets/user.png'),
                backgroundColor: Colors.transparent,
              ),
            ),

            const SizedBox(height: 10),

            // Display user name below the logo
            FutureBuilder<Map<String, dynamic>>(
              future: _getUserDataByIndex(), // Fetch user data by index
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading spinner
                } else if (snapshot.hasError) {
                  return const Text(
                    'Error loading user data',
                    style: TextStyle(color: Colors.white),
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Text(
                    'User not found',
                    style: TextStyle(color: Colors.white),
                  );
                } else {
                  // Extract user's name from the snapshot
                  String userName = snapshot.data!['fullName'] ?? 'Unknown User';
                  return Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 30),

            // Logout button
            ElevatedButton(
              onPressed: () async {
                // Clear SharedPreferences to log out
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Navigate to LoginPage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: const Color(0xFF141A2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
