import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage:
    "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  bool hasPendingMedia = false; // Flag to track if media is pending

  @override
  void initState() {
    super.initState();
    _loadMessagesFromSharedPreferences(); // Load saved messages
  }

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
            icon: Icon(Icons.arrow_back, color: Colors.white)),
        title: const Text(
          "Gemini Chat",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Container(
      color: const Color(0xFF0A0E21), // Dark background color for the chat screen
      child: DashChat(
        inputOptions: InputOptions(
          inputTextStyle: TextStyle(
            color: Colors.white, // Set the input text color to white
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
          trailing: [
            IconButton(
              onPressed: _sendMediaMessage,
              icon: const Icon(
                Icons.image,
                color: Colors.white, // Icon color to match theme
              ),
            ),
          ],
        ),
        messageOptions: MessageOptions(
          currentUserTextColor: Colors.white,
          textColor: Colors.white,
          currentUserContainerColor: const Color(0xFF1D1E33),
          containerColor: const Color(0xFF141A2E),
        ),
        currentUser: currentUser,
        onSend: _sendMessage,
        messages: messages,
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    // Save the message to SharedPreferences
    _saveMessageToSharedPreferences(chatMessage);

    if (hasPendingMedia) {
      _sendToGemini(chatMessage, true); // Media already sent, now send text
      hasPendingMedia = false; // Reset the flag
    } else {
      _sendToGemini(chatMessage, false); // Just a normal text message
    }
  }

  void _sendToGemini(ChatMessage chatMessage, bool mediaSent) {
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;

      if (mediaSent) {
        ChatMessage? mediaMessage = messages.firstWhere(
                (message) =>
            message.user.id == currentUser.id && message.medias?.isNotEmpty == true,
            );

        if (mediaMessage != null && mediaMessage.medias?.isNotEmpty == true) {
          images = [File(mediaMessage.medias!.first.url).readAsBytesSync()];
        }
      }

      gemini.streamGenerateContent(
        question,
        images: images,
      ).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts
              ?.fold("", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });

          _saveMessageToSharedPreferences(lastMessage!); // Save Gemini message
        } else {
          String response = event.content?.parts
              ?.fold("", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });

          _saveMessageToSharedPreferences(message); // Save Gemini message
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          )
        ],
      );
      setState(() {
        messages = [chatMessage, ...messages];
        hasPendingMedia = true; // Set flag to true when media is sent
      });
      _saveMessageToSharedPreferences(chatMessage); // Save media message to SharedPreferences
    }
  }

  Future<void> _saveMessageToSharedPreferences(ChatMessage message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedMessages = prefs.getStringList('messages') ?? [];

    Map<String, dynamic> messageData = {
      'text': message.text,
      'createdAt': message.createdAt.toIso8601String(),
      'userId': message.user.id,
      'medias': message.medias?.map((media) => media.url).toList() ?? [],
    };

    storedMessages.insert(0, jsonEncode(messageData));
    await prefs.setStringList('messages', storedMessages);
  }

  Future<void> _loadMessagesFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedMessages = prefs.getStringList('messages') ?? [];

    List<ChatMessage> loadedMessages = storedMessages.map((messageString) {
      Map<String, dynamic> data = jsonDecode(messageString);

      return ChatMessage(
        text: data['text'],
        createdAt: DateTime.parse(data['createdAt']),
        user: data['userId'] == currentUser.id ? currentUser : geminiUser,
        medias: (data['medias'] as List<dynamic>?)
            ?.map((mediaUrl) =>
            ChatMedia(url: mediaUrl as String, type: MediaType.image, fileName: ''))
            .toList(),
      );
    }).toList();

    setState(() {
      messages = loadedMessages;
    });
  }
}
