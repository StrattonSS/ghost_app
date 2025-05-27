import 'package:flutter/material.dart';
import 'package:ghost_app/pages/home_page.dart';
import 'package:ghost_app/pages/journal_page.dart';
import 'package:ghost_app/pages/tools_page.dart';
import 'package:ghost_app/pages/profile_page.dart'; // ✅ Import the real profile screen

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const JournalPage(),
    const ToolsPage(),
    const ProfilePage(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Home'),
    const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
    const BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Tools'),
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
