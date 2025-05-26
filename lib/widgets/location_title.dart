import 'package:flutter/material.dart';
import 'package:ghost_app/pages/terminal_theme.dart';

class LocationTile extends StatelessWidget {
  final Map<String, dynamic> location;

  const LocationTile({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: TerminalColors.card,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        title: Text(
          location['name'] ?? 'Unknown Location',
          style: TerminalTextStyles.heading,
        ),
        subtitle: Text(
          location['shortDescription'] ?? '',
          style: TerminalTextStyles.body,
        ),
        onTap: () {
          // Add navigation to detail page if desired
        },
      ),
    );
  }
}

class TerminalColors {
  // existing color definitions

  static const Color card =
      Color(0xFF222222); // Replace with your desired card color
}
