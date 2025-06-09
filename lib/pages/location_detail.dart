import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ghost_app/pages/terminal_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationDetailPage extends StatelessWidget {
  final Map<String, dynamic> locationData;

  const LocationDetailPage({super.key, required this.locationData});

  void _launchMap(double latitude, double longitude) async {
    final Uri mapUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch map';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = locationData['name'] ?? 'Unknown';
    final String description =
        locationData['description'] ?? 'No description provided.';
    final String history =
        locationData['history'] ?? 'No historical information available.';
    final String evidence =
        locationData['evidence'] ?? 'No evidence reports logged.';
    final String city = locationData['city'] ?? 'N/A';
    final String state = locationData['state'] ?? 'N/A';
    final String street = locationData['street'] ?? '';
    final String? imageUrl = locationData['imageurl'];
    final GeoPoint? coordinates = locationData['coordinates'];

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: TerminalColors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 📸 Image Section
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),

            // 📍 Name + Address Section
            Card(
              color: Colors.black,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(name,
                        style: TerminalTextStyles.heading,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      street.isNotEmpty
                          ? '$street, $city, $state'
                          : '$city, $state',
                      style: TerminalTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📝 Description Section
            Card(
              color: Colors.black,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Description',
                        style: TerminalTextStyles.heading,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(description,
                        style: TerminalTextStyles.body,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🕰️ History Section
            Card(
              color: Colors.black,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Brief History',
                        style: TerminalTextStyles.heading,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(history,
                        style: TerminalTextStyles.body,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 👻 Evidence Reported Section
            Card(
              color: Colors.black,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Evidence Reported',
                        style: TerminalTextStyles.heading,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(evidence,
                        style: TerminalTextStyles.body,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🗺️ Map Preview Section
            if (coordinates != null)
              GestureDetector(
                onTap: () =>
                    _launchMap(coordinates.latitude, coordinates.longitude),
                child: Card(
                  color: Colors.black,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.map, color: TerminalColors.green),
                        const SizedBox(width: 12),
                        Text(
                          'Tap to Navigate to Location',
                          style: TerminalTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
