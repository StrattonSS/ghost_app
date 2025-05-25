import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_user.dart';
import 'terminal_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginUserScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        title:
            const Text('>> PROFILE_SYS.TXT', style: TerminalTextStyles.heading),
        backgroundColor: TerminalColors.background,
        foregroundColor: TerminalColors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Logged in as: ${user?.email ?? "Unknown"}',
              style: TerminalTextStyles.body,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: TerminalColors.green,
                foregroundColor: TerminalColors.background,
                textStyle: TerminalTextStyles.button,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
