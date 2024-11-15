import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Instruction extends StatefulWidget {
  final String subjectname;
  Instruction({required this.subjectname, Key? key}) : super(key: key);

  @override
  State<Instruction> createState() => _InstructionState();
}

class _InstructionState extends State<Instruction> {
  String? p1, p2, p3;
  String? p1ImageUrl, p2ImageUrl, p3ImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchInstructionData();
  }

  Future<void> _fetchInstructionData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('instructions')
          .doc(widget.subjectname)
          .get();

      setState(() {
        p1 = snapshot['p1'];
        p1ImageUrl = snapshot['p1ImageUrl'];
        p2 = snapshot['p2'];
        p2ImageUrl = snapshot['p2ImageUrl'];
        p3 = snapshot['p3'];
        p3ImageUrl = snapshot['p3ImageUrl'];
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        title: Text(widget.subjectname, style: const TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: const Color(0xFF0A0E21),
        padding: const EdgeInsets.all(16),
        child: p1 != null && p2 != null && p3 != null
            ? ListView(
          children: [
            _buildBlogSection("Introduction", p1!, p1ImageUrl),
            const SizedBox(height: 24),
            _buildBlogSection("Details", p2!, p2ImageUrl),
            const SizedBox(height: 24),
            _buildBlogSection("Conclusion", p3!, p3ImageUrl),
          ],
        )
            : const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      ),
    );
  }

  Widget _buildBlogSection(String title, String content, String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.green,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 16),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
