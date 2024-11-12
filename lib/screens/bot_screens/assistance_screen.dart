import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:futurex/screens/bot_screens/assistance_screen.dart';
import 'package:futurex/screens/instruction.dart';
import 'package:futurex/screens/sheets.dart'; // Import instructions widget
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Assistance chatbot
class AssistanceChatbot extends StatefulWidget {
  @override
  _AssistanceChatbotState createState() => _AssistanceChatbotState();
}

class _AssistanceChatbotState extends State<AssistanceChatbot> {
  String? userIndex;
  Map<String, String> subjectTypes = {}; // Map to store subject names with their types from Firebase

  Future<void> _loadUserIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userIndex = prefs.getString('studentIndex'); // Assuming 'studentIndex' is the key
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserIndex();
    _fetchSubjectNamesAndTypes(); // Fetch subject names and types from Firebase
  }

  // Function to fetch subject names and types from Firebase collection 'sheets'
  Future<void> _fetchSubjectNamesAndTypes() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('sheets').get();

    setState(() {
      // Extract the subject names and their types and store them in the subjectTypes map
      subjectTypes = {
        for (var doc in querySnapshot.docs)
          doc['name'].toString().toLowerCase(): doc['type'].toString().toLowerCase(),
      };
    });
  }

  List<ChatMessage> messages = [];
  final ChatUser currentUser = ChatUser(id: 'user');
  final ChatUser geminiUser = ChatUser(
    id: 'bot',
    firstName: 'Futurex',
    profileImage: 'https://pbs.twimg.com/profile_images/1182918083641593856/VlcETqrt_400x400.jpg',
  );

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Futurex",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: const Color(0xFF0A0E21),
        child: DashChat(
          currentUser: currentUser,
          messages: messages,
          inputOptions: InputOptions(
            inputTextStyle: TextStyle(color: Colors.white),
            inputDecoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF141A2E),
              hintText: 'Type a message...',
              hintStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          messageOptions: MessageOptions(
            currentUserTextColor: Colors.white,
            textColor: Colors.white,
            currentUserContainerColor: const Color(0xFF1D1E33),
            containerColor: const Color(0xFF141A2E),
          ),
          onSend: (ChatMessage message) async {
            setState(() {
              messages = [message, ...messages];
            });

            _scrollToBottom();

            String response = await sendMessageToFlask(message.text);

            setState(() {
              messages = [
                ChatMessage(
                  text: response,
                  user: geminiUser,
                  createdAt: DateTime.now(),
                ),
                ...messages,
              ];
            });

            _scrollToBottom();

            String? detectedSubject = _detectSubjectInMessage(message.text);

            if (detectedSubject != null) {
              Future.delayed(Duration(seconds: 5), () {
                _showSubjectBottomSheet(context, detectedSubject);
              });
            }
          },
        ),
      ),
    );
  }

  String? _detectSubjectInMessage(String message) {
    for (String subject in subjectTypes.keys) {
      if (message.toLowerCase().contains(subject)) {
        return subject;
      }
    }
    return null;
  }

  void _showSubjectBottomSheet(BuildContext context, String subjectName) {
    String? subjectType = subjectTypes[subjectName];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E21),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          height: 200,
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                if (subjectType == 'sheets') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SubjectsPage(subjectName)),
                  );
                } else if (subjectType == 'instruction') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Instruction(subjectname: subjectName,)),
                  );
                }
              },
              child: Text('Go to $subjectName', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<String> sendMessageToFlask(String userMessage) async {
    final response = await http.post(
      Uri.parse('https://8c15-154-177-195-39.ngrok-free.app/ask'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': userMessage,
        'index': '$userIndex',
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['answer'];
    } else {
      return 'Error: Could not connect to the chatbot';
    }
  }
}
