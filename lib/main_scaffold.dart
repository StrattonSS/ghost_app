import 'package:flutter/material.dart';
import 'package:ghost_app/pages/home_page.dart';
import 'package:ghost_app/pages/journal_page.dart';
import 'package:ghost_app/pages/profile_page.dart';
import 'package:ghost_app/pages/tools_page.dart';

import 'pages/terminal_theme.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  late final List<Widget> _pages = const [
    HomePage(),
    JournalPage(),
    ToolsPage(),
    ProfilePage(),
  ];

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: TerminalColors.background,
        selectedItemColor: TerminalColors.green,
        unselectedItemColor: TerminalColors.greyDark,
        selectedLabelStyle: TerminalTextStyles.muted.copyWith(
          color: TerminalColors.green,
        ),
        unselectedLabelStyle: TerminalTextStyles.muted.copyWith(
          color: TerminalColors.greyDark,
        ),
        onTap: _onTabSelected,
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