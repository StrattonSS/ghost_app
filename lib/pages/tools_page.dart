import 'package:flutter/material.dart';
import '../pages/emf_reader_page.dart';
import '../pages/uv_sensor_page.dart';
import '../pages/spirit_box_page.dart';
import '../pages/parabolic_mic_page.dart';
import '../pages/ghost_camera_page.dart';
import '../pages/tool_tutorial_page.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({Key? key}) : super(key: key);

  Widget buildToolTile({
    required BuildContext context,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.black87,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, color: Colors.greenAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghost Tools'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          buildToolTile(
            context: context,
            title: '🛠️ Tool Tutorial',
            description: 'Try all tools in simulation mode.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ToolTutorialPage()),
              );
            },
          ),
          buildToolTile(
            context: context,
            title: '📡 EMF Reader',
            description: 'Detect electromagnetic fluctuations.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EMFReaderPage()),
              );
            },
          ),
          buildToolTile(
            context: context,
            title: '🔦 UV Sensor',
            description: 'Reveal hidden UV clues.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UVSensorPage()),
              );
            },
          ),
          buildToolTile(
            context: context,
            title: '📻 Spirit Box',
            description: 'Listen for spirit voices in static.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SpiritBoxPage()),
              );
            },
          ),
          buildToolTile(
            context: context,
            title: '🎤 Parabolic Mic',
            description: 'Capture distant paranormal sounds.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ParabolicMicPage()),
              );
            },
          ),
          buildToolTile(
            context: context,
            title: '📸 Ghost Camera',
            description: 'Photograph supernatural entities.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GhostCameraPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
