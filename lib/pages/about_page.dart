import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About G.H.O.S.T.'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'G.H.O.S.T. - Geolocated Haunting Observation & Survey Tracker',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'This app allows you to explore reported paranormal locations, collect ghostly evidence, and rank up on the leaderboard.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Developed by Stratton Software Solutions'),
            SizedBox(height: 8),
            Text('Support: strattonsoftwaresolutions@gmail.com'),
          ],
        ),
      ),
    );
  }
}
