import 'package:flutter/material.dart';
import 'package:ghost_app/pages/home_page.dart';
import 'package:ghost_app/pages/journal_page.dart';
import 'package:ghost_app/pages/profile_page.dart';
import 'package:ghost_app/pages/tools_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const HomePage(),
    const JournalPage(),
    const ToolsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label: 'Locations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Findings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}