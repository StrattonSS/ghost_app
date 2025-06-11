import 'package:flutter/material.dart';
import '../pages/test_tools/test_emf.dart';
import 'prod_tools/uv_sensor_page.dart';
import 'prod_tools/spirit_box_page.dart';
import 'prod_tools/parabolic_mic_page.dart';
import 'prod_tools/ghost_camera_page.dart';
import 'terminal_theme.dart' as theme;

class ToolTutorialPage extends StatelessWidget {
  const ToolTutorialPage({Key? key}) : super(key: key);

  Widget buildToolTile({
    required BuildContext context,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: theme.TerminalColors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        title: Text(
          title,
          style: theme.TerminalTextStyles.heading,
        ),
        subtitle: Text(
          description,
          style: theme.TerminalTextStyles.muted.copyWith(fontSize: 14),
        ),
        trailing:
            const Icon(Icons.play_arrow, color: theme.TerminalColors.green),
      ),
    );
  }

  Widget buildTutorialHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 16,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.TerminalColors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.TerminalColors.green),
      ),
      child: const Text(
        '>> Tutorial Mode Activated\n'
        'All tools are unlocked for simulation.\n'
        'No ghost coins or rewards will be earned.',
        style: theme.TerminalTextStyles.body,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.TerminalColors.background,
      appBar: AppBar(
        backgroundColor: theme.TerminalColors.background,
        title: const Text(
          '>> TOOL_TUTORIAL.EXE',
          style: theme.TerminalTextStyles.heading,
        ),
      ),
      body: ListView(
        children: [
          buildTutorialHeader(context),
          buildToolTile(
            context: context,
            title: '📡 EMF Reader',
            description: 'Try the electromagnetic scanner.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TestEMFReaderPage()),
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
                MaterialPageRoute(builder: (_) => const UVSensorPage()),
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
                MaterialPageRoute(builder: (_) => const SpiritBoxPage()),
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
                MaterialPageRoute(builder: (_) => const ParabolicMicPage()),
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
                MaterialPageRoute(builder: (_) => const GhostCameraPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
