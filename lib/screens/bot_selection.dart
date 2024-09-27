import 'package:flutter/material.dart';
import 'package:futurex/screens/bot_screens/assistance_screen.dart';
import 'package:futurex/screens/bot_screens/gemini.dart';

class BotSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21), // Same background color
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Choose Your Bot',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Bard Button
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Chatscreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/bard.png', // Use the Bard bot image
                                width: 80,
                                height: 80, // Reduced size to fit the screen
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'gemini',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    // Assistant Button
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context,  MaterialPageRoute<void>(
                              builder: (BuildContext context) =>  AssistanceChatbot(),
                            ),);
                            // Handle the action for selecting Assistant
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/assistance.png', // Use the Assistant bot image
                                width: 80,
                                height: 80, // Reduced size to fit the screen
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Assistant',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Text("Choose gemini for explanation ",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                Text("Choose Fuassitance for inquary ",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
