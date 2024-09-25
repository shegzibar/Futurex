import 'package:flutter/material.dart';
import 'package:futurex/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildOnboardingPage(
                  title: "Welcome to Futurex",
                  description: "its a platform for Future university students to help them study online ",
                  imageAsset: "assets/future 1.png",
                ),
                _buildOnboardingPage(
                  title: "NEWS",
                  description: "getting all of the university news in one place",
                  imageAsset: "assets/news.png",
                ),
                _buildOnboardingPage(
                  title: "Personal assitance",
                  description: "having your own personal assistance that will help you do your tasks",
                  imageAsset: "assets/assistance1.png",
                ),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  // Onboarding Page UI
  Widget _buildOnboardingPage({required String title, required String description, required String imageAsset}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imageAsset, height: 300),
          const SizedBox(height: 30),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation with Skip and Next/Done buttons
  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage == 2
              ? Container() // Empty container for the last page (no skip button)
              : TextButton(
            onPressed: _skipOnboarding,
            child: const Text(
              "Skip",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          _currentPage == 2
              ? ElevatedButton(
            onPressed: _completeOnboarding,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Done",style: TextStyle(color: Colors.white),),
          )
              : ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Next",style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Skip the onboarding
  void _skipOnboarding() {
    _completeOnboarding();
  }

  // Move to the next page
  void _nextPage() {
    _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  // Complete the onboarding and navigate to login
  void _completeOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true); // Mark onboarding as completed
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) =>  LoginPage(),
    ),); // Navigate to login
  }
}
