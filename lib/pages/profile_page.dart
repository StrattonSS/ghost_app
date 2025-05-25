import 'package:flutter/material.dart';
import '../pages/terminal_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController =
      TextEditingController(text: "Ghost Hunter");
  final TextEditingController _dobController =
      TextEditingController(text: "01/01/2000");
  final String _email = "ghost@example.com";
  final int _ghostCoins = 120;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: const Text('>> PROFILE_SYS.TXT'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader("USER INFO"),
            _terminalInputField("Full Name", _nameController),
            _terminalInputField("Date of Birth", _dobController),
            _terminalReadOnlyField("Email", _email),
            const SizedBox(height: 16),
            _terminalButton("Change Password", Icons.lock, () {
              _showMessage("Change password clicked.");
            }),
            const SizedBox(height: 24),
            _sectionHeader("ACCOUNT STATS"),
            _terminalReadOnlyField("Ghost Coins", '$_ghostCoins'),
            const SizedBox(height: 24),
            _sectionHeader("ACCOUNT ACTIONS"),
            _terminalButton("Log Out", Icons.exit_to_app, () {
              _showMessage("Logging out...");
            }),
            _terminalButton("Delete Account", Icons.delete_forever, () {
              _showMessage("Delete account requested.");
            }),
            const SizedBox(height: 24),
            _sectionHeader("SUPPORT & INFO"),
            _terminalButton("Contact Support", Icons.support_agent, () {
              _showMessage("Support contact opened.");
            }),
            _terminalReadOnlyField("App Version", "v1.0.0"),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        '>> $title',
        style: TerminalTextStyles.heading.copyWith(fontSize: 16),
      ),
    );
  }

  Widget _terminalInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('> $label:',
            style: TerminalTextStyles.body.copyWith(fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TerminalTextStyles.body,
          cursorColor: TerminalColors.green,
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _terminalReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('> $label:',
            style: TerminalTextStyles.body.copyWith(fontSize: 14)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: TerminalColors.green),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value, style: TerminalTextStyles.body),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _terminalButton(String label, IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, color: TerminalColors.green),
        label: Text(label, style: TerminalTextStyles.body),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: TerminalColors.green),
          backgroundColor: TerminalColors.background,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: TerminalColors.background,
        content: Text(msg, style: TerminalTextStyles.body),
      ),
    );
  }
}
