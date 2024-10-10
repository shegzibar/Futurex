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
late String name;


  @override
  void initState() {
    super.initState();
    name = widget.subjectName.trim();
    _futureFiles = FirebaseStorage.instance
        .ref('$name/')
        .listAll(); // Fetch files for the given subject
  }

  // Method to check and request storage permission before downloading
  Future<bool> _checkAndRequestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  Future<void> _downloadFile(Reference ref) async {
    try {
      // Check and request permission first
      bool permissionGranted = await _checkAndRequestStoragePermission();
      if (!permissionGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission not granted')),
        );
        return;
      }

      // If permission is granted, proceed with downloading the file
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

            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Display 2 items per row
                childAspectRatio: 2, // Adjust as needed for item sizing
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];

                return Card(

                  color: const Color(0xFF1D1E33),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          file.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        IconButton(
                          icon: Icon(Icons.download, color: Colors.white),
                          onPressed: () => _downloadFile(file),
                        ),
                      ],
                    ),
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
