import 'package:flutter/material.dart';

import '../pages/emf_reader_page.dart';
import 'terminal_theme.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  Widget _buildScannerCard({
    required BuildContext context,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: TerminalColors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        title: Text(
          title,
          style: TerminalTextStyles.heading,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            description,
            style: TerminalTextStyles.muted,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: TerminalColors.green,
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: TerminalColors.green),
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '>> SCANNER_STATUS',
            style: TerminalTextStyles.heading,
          ),
          SizedBox(height: 10),
          Text(
            'Use your phone magnetometer to monitor magnetic field changes while investigating a haunted location.',
            style: TerminalTextStyles.body,
          ),
          SizedBox(height: 10),
          Text(
            'This tool depends on device hardware support and should be treated as a field-use magnetic sensor, not a certified professional EMF instrument.',
            style: TerminalTextStyles.muted,
          ),
        ],
      ),
    );
  }

  void _openMagneticFieldReader(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EMFReaderPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: const Text(
          '>> SCANNER_SYS',
          style: TerminalTextStyles.heading,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildInfoPanel(),
          _buildScannerCard(
            context: context,
            title: 'Magnetic Field Reader',
            description:
            'Open the live scanner, monitor magnetic changes, and use readings during field reports.',
            onTap: () => _openMagneticFieldReader(context),
          ),
        ],
      ),
    );
  }
}