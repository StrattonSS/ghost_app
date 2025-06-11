import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ghost_app/pages/terminal_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationDetailPage extends StatelessWidget {
  final Map<String, dynamic> locationData;

  const LocationDetailPage({super.key, required this.locationData});

  void _launchMap({
    required BuildContext context,
    required String street,
    required String city,
    required String state,
    required GeoPoint? coordinates,
  }) async {
    Uri mapUri;

    if (street.isNotEmpty && city.isNotEmpty && state.isNotEmpty) {
      final address = Uri.encodeComponent('$street, $city, $state');
      mapUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$address');
    } else if (coordinates != null) {
      mapUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${coordinates.latitude},${coordinates.longitude}',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location data is incomplete.')),
      );
      return;
    }

    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to launch map.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = locationData['name'] ?? 'Unknown';
    final String description = locationData['description'] ?? 'No description provided.';
    final String history = locationData['history'] ?? 'No historical information available.';
    final String evidence = locationData['evidence'] ?? 'No evidence reports logged.';
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

            // 📍 Name + Address
            Card(
              color: Colors.black,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(name, style: TerminalTextStyles.heading, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      street.isNotEmpty ? '$street, $city, $state' : '$city, $state',
                      style: TerminalTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📝 Description
            _buildCard('Description', description),
            const SizedBox(height: 16),

            // 🕰️ History
            _buildCard('Brief History', history),
            const SizedBox(height: 16),

            // 👻 Evidence
            _buildCard('Evidence Reported', evidence),
            const SizedBox(height: 16),

            // 🗺️ Navigation Button
            if (coordinates != null)
              GestureDetector(
                onTap: () => _launchMap(
                  context: context,
                  street: street,
                  city: city,
                  state: state,
                  coordinates: coordinates,
                ),
                child: Card(
                  color: Colors.black,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.map, color: TerminalColors.green),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Tap to Navigate to Location',
                            style: TerminalTextStyles.body,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
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

  Widget _buildCard(String title, String content) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TerminalTextStyles.heading, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(content, style: TerminalTextStyles.body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
