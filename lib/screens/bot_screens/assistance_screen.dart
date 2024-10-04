import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:futurex/screens/bot_screens/assistance_screen.dart';
import 'package:futurex/screens/sheets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firebase
import 'package:shared_preferences/shared_preferences.dart';

class AssistanceChatbot extends StatefulWidget {
  @override
  _AssistanceChatbotState createState() => _AssistanceChatbotState();
}

class _AssistanceChatbotState extends State<AssistanceChatbot> {
  String? userIndex;
  List<String> subjectNames = []; // List to store subject names from Firebase

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
    _fetchSubjectNames(); // Fetch subject names from Firebase
  }

  // Function to fetch subject names from Firebase collection 'sheets'
  Future<void> _fetchSubjectNames() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('sheets').get();

    setState(() {
      // Extract the subject names and store them in the subjectNames list
      subjectNames = querySnapshot.docs
          .map((doc) => doc['name'].toString().toLowerCase())
          .toList();
    });
  }

  List<ChatMessage> messages = [];
  final ChatUser currentUser = ChatUser(id: 'user');
  final ChatUser geminiUser = ChatUser(
    id: 'bot',
    firstName: 'Futurex',
    profileImage:
    'https://pbs.twimg.com/profile_images/1182918083641593856/VlcETqrt_400x400.jpg', // Optional: Gemini's avatar
  );

  final ScrollController _scrollController = ScrollController(); // ScrollController

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21), // Dark theme color
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
        color: const Color(0xFF0A0E21), // Dark background color
        child: DashChat(
          currentUser: currentUser,
          messages: messages,
          inputOptions: InputOptions(
            inputTextStyle: TextStyle(
              color: Colors.white, // Input text color to white
            ),
            inputDecoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF141A2E), // Input background color
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
            currentUserContainerColor: const Color(0xFF1D1E33), // Current user bubble color
            containerColor: const Color(0xFF141A2E), // Bot bubble color
          ),
          onSend: (ChatMessage message) async {
            // Add user message to the chat
            setState(() {
              messages = [message, ...messages];
            });

            _scrollToBottom(); // Scroll to bottom after sending

            // Send message to Flask backend and get response
            String response = await sendMessageToFlask(message.text);

            // Add Gemini's response to the chat
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

            _scrollToBottom(); // Scroll to bottom after receiving response

            // Check if the message contains any subject name from the 'sheets' collection
            String? detectedSubject = _detectSubjectInMessage(message.text);

            if (detectedSubject != null) {
              // Show the bottom alert box with the detected subject name after a 5-second delay
              Future.delayed(Duration(seconds: 5), () {
                _showSubjectBottomSheet(context, detectedSubject);
              });
            }
          },
        ),
      ),
    );
  }

  // Function to detect if the message contains any subject name
  String? _detectSubjectInMessage(String message) {
    for (String subject in subjectNames) {
      if (message.toLowerCase().contains(subject)) {
        return subject;
      }
    }
    return null; // No subject detected
  }

  // Function to show a bottom sheet with the detected subject name
  void _showSubjectBottomSheet(BuildContext context, String subjectName) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Curved edges
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E21), // Dark background color
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Curved edges
          ),
          height: 200,
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Green button color
              ),
              onPressed: () {
                // Navigate to the subjects page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubjectsPage(subjectName)),
                );
              },
              child: Text('Go to $subjectName'), // Update button text with subject name
            ),
          ),
        );
      },
    );
  }

  // Function to scroll to the bottom of the chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // Function to get flask data or backend
  Future<String> sendMessageToFlask(String userMessage) async {
    final response = await http.post(
      Uri.parse('https://c567-154-177-179-180.ngrok-free.app/ask'), // Replace with your Flask backend URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': userMessage,
        'index': '201902008', // Provide the user's student ID if needed
      }),
    );

    if (response.statusCode == 200) {
      // Parse the response from the Flask chatbot
      final responseData = jsonDecode(response.body);
      return responseData['answer'];
    } else {
      return 'Error: Could not connect to the chatbot';
    }
  }
}

// Dummy page for subjects
