import 'package:flutter/material.dart';
import 'package:futurex/screens/Settings.dart';
import 'package:futurex/screens/bot_selection.dart';
import 'package:futurex/screens/home.dart';
 // Assuming these are imported from another file


class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 1; // Home is initially selected

  // List of pages for the navigation bar
  final List<Widget> _pages = [
    BotSelectionPage(),  // Index 0
    Home(),       // Index 1 (center button)
    Settings(),   // Index 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21), // Same background color as your design
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141A2E), // Darker background for the bottom bar
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // Keep background transparent
          elevation: 0,
          currentIndex: _selectedIndex, // Track the currently selected item
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // Prevent shifting between tabs
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.list,
                color: _selectedIndex == 0 ? Colors.white : Colors.grey[400],
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _selectedIndex == 1 ? Color(0xFF00D084) : Colors.transparent, // Green color for the selected icon
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home,
                  color: _selectedIndex == 1 ? Colors.white : Colors.grey[400],
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: _selectedIndex == 2 ? Colors.white : Colors.grey[400],
              ),
              label: '',
            ),
          ],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: false, // Hide labels
          showUnselectedLabels: false, // Hide labels
        ),
      ),
    );
  }
}
