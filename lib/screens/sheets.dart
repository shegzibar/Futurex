import 'package:flutter/material.dart';
class SubjectsPage extends StatelessWidget {
  final String subjectName; // Subject name passed to the page

  SubjectsPage(this.subjectName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        title: Text('$subjectName', style: TextStyle(color: Colors.white)), // Display subject name in the title
      ),
      body: Center(
        child: Text(
          'This is the $subjectName page',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
