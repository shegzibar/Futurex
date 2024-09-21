import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21), // Dark theme color
        centerTitle: true,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        title: const Text(
          "Gemini Chat", style: TextStyle(color: Colors.white),
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
          // Customize the send icon button
          trailing: [
            IconButton(
              onPressed: _sendMediaMessage,
              icon: const Icon(
                Icons.image,
                color: Colors.white, // Icon color to match theme
              ),
            )
          ],
        ),
        messageOptions: MessageOptions(
          currentUserTextColor: Colors.white,
          textColor: Colors.white,
          // Bubble color for current user
          currentUserContainerColor: const Color(0xFF1D1E33),
          // Bubble color for Gemini
          containerColor: const Color(0xFF141A2E),
        ),
        // Customization for chat avatar and profile images

        // Custom chat user and messages
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
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini.streamGenerateContent(
        question,
        images: images,
      ).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
              "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(
                () {
              messages = [lastMessage!, ...messages];
            },
          );
        } else {
          String response = event.content?.parts?.fold(
              "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
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
        text: "Describe this picture?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          )
        ],
      );
      _sendMessage(chatMessage);
    }
  }
}
