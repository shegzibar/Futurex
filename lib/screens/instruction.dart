import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Instruction extends StatefulWidget {
  final String subjectname;
  Instruction({required this.subjectname, Key? key}) : super(key: key);

  @override
  State<Instruction> createState() => _InstructionState();
}

class _InstructionState extends State<Instruction> {
  String? p1;
  String? p2;
  String? p3;

  @override
  void initState() {
    super.initState();
    _fetchInstructionData();
  }

  Future<void> _fetchInstructionData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('instructions')
          .doc(widget.subjectname) // Assuming each document is named after subjectname
          .get();

      setState(() {
        p1 = snapshot['p1'];
        p2 = snapshot['p2'];
        p3 = snapshot['p3'];
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21), // Dark theme color
        title: Text(widget.subjectname, style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: const Color(0xFF0A0E21), // Dark background color
        padding: EdgeInsets.all(16),
        child: p1 != null && p2 != null && p3 != null
            ? ListView(
          children: [
            _buildParagraphCard("Introduction", p1!),
            SizedBox(height: 16),
            _buildParagraphCard("Details", p2!),
            SizedBox(height: 16),
            _buildParagraphCard("Conclusion", p3!),
          ],
        )
            : Center(
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildParagraphCard(String title, String content) {
    return Card(
      color: const Color(0xFF1D1E33), // Dark card background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.green, // Accent color
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                color: Colors.white, // Main text color
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
