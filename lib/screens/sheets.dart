import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SubjectsPage extends StatefulWidget {
  final String subjectName;

  SubjectsPage(this.subjectName);

  @override
  _SubjectsPageState createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  late Future<ListResult> _futureFiles;

  @override
  void initState() {
    super.initState();
    _futureFiles = FirebaseStorage.instance
        .ref('futurex-19db0.appspot.com')
        .listAll(); // Fetch files for the given subject
  }

  Future<void> _downloadFile(Reference ref) async {
    try {
      // Request storage permissions
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Storage permission not granted');
        return;
      }

      // Get app's local directory
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${ref.name}';
      final file = File(filePath);

      // Download file
      await ref.writeToFile(file);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded ${ref.name}')),
      );
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        title: Text('${widget.subjectName}', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<ListResult>(
        future: _futureFiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading files'));
          } else if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
            return Center(child: Text('No files found'));
          } else {
            final files = snapshot.data!.items;

            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];

                return ListTile(
                  title: Text(file.name, style: TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: Icon(Icons.download, color: Colors.white),
                    onPressed: () => _downloadFile(file),
                  ),
                );
              },
            );
          }
        },
      ),
      backgroundColor: const Color(0xFF0A0E21),
    );
  }
}
