import 'package:flutter/material.dart';
import 'package:ghost_app/pages/terminal_theme.dart';

class LocationTile extends StatelessWidget {
  final Map<String, dynamic> location;

  const LocationTile({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: TerminalColors.transparentGreen,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: ListTile(
        title: Text(
          location['name'] ?? 'Unknown Location',
          style: TerminalTextStyles.heading,
        ),
        subtitle: Text(
          location['shortDescription'] ?? '',
          style: TerminalTextStyles.body.copyWith(fontSize: 16),
        ),
        onTap: () {
          if (location['id'] != null) {
            Navigator.pushNamed(
              context,
              '/location_detail',
              arguments: {
                'id': location['id'], // Ensure this exists in the map
                ...location, // Pass the rest of the fields too
              },
            );
          } else {
            debugPrint('Location missing ID: $location');
          }
        },
      ),
    );
  }
}
