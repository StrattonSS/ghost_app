import 'package:flutter/material.dart';

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

  final Color terminalGreen = const Color(0xFF00FF00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '>> PROFILE_SYS.TXT',
          style: TextStyle(
            color: terminalGreen,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        ),
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
        style: TextStyle(
          color: terminalGreen,
          fontFamily: 'Courier',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _terminalInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '> $label:',
          style: TextStyle(
            color: terminalGreen,
            fontFamily: 'Courier',
            fontSize: 14,
          ),
        ),
        TextField(
          controller: controller,
          style: TextStyle(
            color: terminalGreen,
            fontFamily: 'Courier',
          ),
          cursorColor: terminalGreen,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: terminalGreen),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: terminalGreen),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _terminalReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '> $label:',
          style: TextStyle(
            color: terminalGreen,
            fontFamily: 'Courier',
            fontSize: 14,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: terminalGreen),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: terminalGreen,
              fontFamily: 'Courier',
            ),
          ),
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
        icon: Icon(icon, color: terminalGreen),
        label: Text(
          label,
          style: TextStyle(
            color: terminalGreen,
            fontFamily: 'Courier',
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: terminalGreen),
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          msg,
          style: TextStyle(color: terminalGreen, fontFamily: 'Courier'),
        ),
      ),
    );
  }
}
