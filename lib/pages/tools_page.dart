import 'package:flutter/material.dart';
import 'prod_tools/emf_reader_page.dart';
import 'prod_tools/uv_sensor_page.dart';
import 'prod_tools/spirit_box_page.dart';
import 'prod_tools/parabolic_mic_page.dart';
import 'prod_tools/ghost_camera_page.dart';
import '../pages/tool_tutorial_page.dart';
import 'terminal_theme.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({Key? key}) : super(key: key);

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
        border: Border.all(color: TerminalColors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        title: Text(title, style: TerminalTextStyles.heading),
        subtitle: Text(description, style: TerminalTextStyles.muted),
        trailing:
            const Icon(Icons.arrow_forward_ios, color: TerminalColors.green),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title:
            const Text(">> TOOLS_SYS.TXT", style: TerminalTextStyles.heading),
      ),
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
