import 'package:flutter/material.dart';
import '../pages/emf_reader_page.dart';
import '../pages/uv_sensor_page.dart';
import '../pages/spirit_box_page.dart';
import '../pages/parabolic_mic_page.dart';
import '../pages/ghost_camera_page.dart';
import 'terminal_theme.dart';

class ToolTutorialPage extends StatelessWidget {
  const ToolTutorialPage({Key? key}) : super(key: key);

  Widget buildToolTile({
    required BuildContext context,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: TerminalColors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        title: Text(
          title,
          style: TerminalTextStyles.heading,
        ),
        subtitle: Text(
          description,
          style: TerminalTextStyles.muted.copyWith(fontSize: 14),
        ),
        trailing: const Icon(Icons.play_arrow, color: TerminalColors.green),
      ),
    );
  }

  Widget buildTutorialHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TerminalColors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TerminalColors.green),
      ),
      child: const Text(
        '>> Tutorial Mode Activated\n'
        'All tools are unlocked for simulation.\n'
        'No ghost coins or rewards will be earned.',
        style: TerminalTextStyles.body,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: const Text('>> TOOL_TUTORIAL.EXE',
            style: TerminalTextStyles.heading),
      ),
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
