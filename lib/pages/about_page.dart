import 'package:flutter/material.dart';
import 'terminal_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: const Text(
          '>> ABOUT_GHOST.TXT',
          style: TerminalTextStyles.heading,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'G.H.O.S.T. - Geolocated Haunting Observation & Survey Tracker',
              style: TerminalTextStyles.heading,
            ),
            SizedBox(height: 16),
            Text(
              'This app allows you to explore reported paranormal locations, collect ghostly evidence, and rank up on the leaderboard.',
              style: TerminalTextStyles.body,
            ),
            SizedBox(height: 24),
            Text('Version: 1.0.0', style: TerminalTextStyles.muted),
            SizedBox(height: 8),
            Text('Developed by Stratton Software Solutions',
                style: TerminalTextStyles.muted),
            SizedBox(height: 8),
            Text('Support: strattonsoftwaresolutions@gmail.com',
                style: TerminalTextStyles.muted),
          ],
        ),
      ),
    );
  }
}
