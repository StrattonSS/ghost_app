import 'package:flutter/material.dart';
import '../pages/emf_reader_page.dart';
import '../pages/uv_sensor_page.dart';
import '../pages/spirit_box_page.dart';
import '../pages/parabolic_mic_page.dart';
import '../pages/ghost_camera_page.dart';
import '../pages/tool_tutorial_page.dart';

class ToolTutorialPage extends StatelessWidget {
  const ToolTutorialPage({Key? key}) : super(key: key);

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
        trailing: const Icon(Icons.play_arrow, color: Colors.greenAccent),
      ),
    );
  }

  Widget buildTutorialHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.greenAccent),
      ),
      child: const Text(
        'Tutorial Mode: All tools are unlocked for simulation purposes. '
        'No ghost coins or rewards will be earned in this mode.',
        style: TextStyle(
          color: Colors.greenAccent,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tool Tutorial'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          buildTutorialHeader(),
          buildToolTile(
            context: context,
            title: '📡 EMF Reader',
            description: 'Try the electromagnetic scanner.',
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
            description: 'Test the ultraviolet tool.',
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
            description: 'Simulate spirit communications.',
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
            description: 'Practice sound detection.',
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
            description: 'Try capturing ghost evidence.',
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
