import 'package:flutter/material.dart';
import 'package:ghost_app/pages/terminal_theme.dart' as terminal_theme;

class LocationTile extends StatelessWidget {
  final Map<String, dynamic> location;

  const LocationTile({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          location['name'] ?? 'Unknown',
          style: terminal_theme.TerminalTextStyles.body,
        ),
        subtitle: Text(
          '${location['city']}, ${location['state']}',
          style: terminal_theme.TerminalTextStyles.body,
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/location_detail',
            arguments: location,
          );
        },
      ),
    );
  }
}
