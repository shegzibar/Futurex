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
  bool _storagePermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  // Request storage permissions before displaying files
  Future<void> _requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      setState(() {
        _storagePermissionGranted = true;
        _futureFiles = FirebaseStorage.instance.ref('/').listAll(); // Fetch files for the given subject
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission not granted')),
      );
    }
  }

  Future<void> _downloadFile(Reference ref) async {
    try {
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
      body: _storagePermissionGranted
          ? FutureBuilder<ListResult>(
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
                );
              },
            );
          }
        },
      )
          : Center(child: Text('Waiting for storage permission')),
      backgroundColor: const Color(0xFF0A0E21),
    );
  }
}
