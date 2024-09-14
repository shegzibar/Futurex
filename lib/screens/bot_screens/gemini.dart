import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Import the plugin

class Chatscreen extends StatefulWidget {
  @override
  _ChatscreenState createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final List messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> recommendations = ["results", "schedule", "courses"];
  bool showRecommendations = true; // This will control when to show/hide the recommendations

  @override
  void initState() {
    super.initState();
  }

  // Function to send a request to Gemini
  Future<void> sendMessageToGemini(String userMessage) async {
    // Add the user's message to the chat
    setState(() {
      messages.add(userMessage);
      showRecommendations = false; // Hide recommendations once a message is sent
    });

    // Clear the input field
    _controller.clear();

    // Scroll to the bottom after adding a new message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      // Initialize the GenerativeModel from the google_generative_ai plugin with your API key
      final gemini = GenerativeModel(
        model: 'gemini-pro', // Use 'gemini-pro' model or adjust as needed
        apiKey: 'AIzaSyDt4BgKeSJL319J2Ynha6hpzM1tq9eSs2E', // Replace with your actual API key
      );

      // Generate a message using the Gemini API
      final content = [Content.text(userMessage)];
      final response = await gemini.generateContent(content);


      // Add Gemini's response to the chat
      setState(() {
         messages.add(response.text); // Gemini’s response added to the chat

      });

      // Scroll to the bottom after receiving the response
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 3),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      print('Error communicating with Gemini: $e');
    }
  }

  // Function to add a message to the chat and call Gemini
  void addMessage(String message) {
    sendMessageToGemini(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21), // Same background color
      appBar: AppBar(
        title: Text('Chat with Gemini'),
        backgroundColor: const Color(0xFF0A0E21),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUser = index % 2 == 0; // User's messages on the right, Gemini's on the left
                return Container(
                  padding: const EdgeInsets.all(10),
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green : Colors.blueGrey, // Color for user vs Gemini
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      messages[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          // Show recommendations only when the user has not yet interacted
          if (showRecommendations)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        addMessage(recommendations[index]);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.withOpacity(0.2),
                        shadowColor: Colors.black12,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        recommendations[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          // Input area
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    onTap: () {
                      setState(() {
                        showRecommendations = false; // Hide recommendations when typing starts
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      hintText: 'Send a message...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      addMessage(_controller.text); // Send the message to Gemini
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
