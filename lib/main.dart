import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:futurex/screens/login.dart';
import 'package:futurex/screens/navbar.dart';
import 'package:futurex/screens/onboardingpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
 // Import the onboarding page

void main() async {
  Gemini.init(
    apiKey: 'AIzaSyCnkcuYgtMSvcvcGHkN3ok0-ClSXnfg9V4',
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC6cP0weJdtHSiMZXJxXnQziXweSzx25s4",
      appId: "1:826402051210:android:f1cad09a3cd64260f30973",
      messagingSenderId: "826402051210",
      projectId: "futurex-19db0",
    ),
  );
//login
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  bool isOnboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    isOnboardingCompleted: isOnboardingCompleted,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isOnboardingCompleted;

  MyApp({required this.isLoggedIn, required this.isOnboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // If the user hasn't completed onboarding, show OnboardingPage first
      home: isOnboardingCompleted
          ? (isLoggedIn ? Navbar() : LoginPage())
          : OnboardingPage(),
    );
  }
}
