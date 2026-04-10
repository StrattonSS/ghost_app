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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'G.H.O.S.T.',
                      style: TerminalTextStyles.heading,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Geolocated Haunting Observation & Survey Tracker',
                      style: TerminalTextStyles.body,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'G.H.O.S.T. helps investigators explore haunted locations, monitor magnetic field changes with their phone, and log field findings in one place.',
                      style: TerminalTextStyles.body,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Core features include location discovery, magnetic field scanning, and a journal for saving observations, spikes, and investigation notes.',
                      style: TerminalTextStyles.body,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Scanner readings should be used to watch for unusual spikes or repeatable changes, not to treat a baseline reading by itself as evidence.',
                      style: TerminalTextStyles.muted,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Version: 1.0.0',
                      style: TerminalTextStyles.muted,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Developed by Stratton Software Solutions',
                      style: TerminalTextStyles.muted,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Support: strattonsoftwaresolutions@gmail.com',
                      style: TerminalTextStyles.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}