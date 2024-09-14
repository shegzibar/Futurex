import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:futurex/screens/login.dart';
import 'package:futurex/screens/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
      apiKey: "AIzaSyC6cP0weJdtHSiMZXJxXnQziXweSzx25s4", // your api key here
      appId: "1:826402051210:android:f1cad09a3cd64260f30973", // your app id here
      messagingSenderId: "826402051210", // your messagingSenderId here
      projectId: "futurex-19db0", // your project id here
  ));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp( MyApp(isLoggedIn: isLoggedIn,));
}
class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLoggedIn ? Navbar() : LoginPage(),
    );
  }
}

