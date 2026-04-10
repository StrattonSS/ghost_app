import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_user.dart';
import 'terminal_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginUserScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Unknown';
    final uid = user?.uid ?? 'Unavailable';

    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        title: const Text(
          '>> PROFILE_SYS.TXT',
          style: TerminalTextStyles.heading,
        ),
        backgroundColor: TerminalColors.background,
        foregroundColor: TerminalColors.green,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.person,
                        color: TerminalColors.green,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Investigator Profile',
                      style: TerminalTextStyles.heading,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your account details for G.H.O.S.T.',
                      style: TerminalTextStyles.muted,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    _buildInfoCard(
                      title: 'Signed in email',
                      value: email,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      title: 'User ID',
                      value: uid,
                    ),
                    const SizedBox(height: 12),
                    const _ProfileInfoPanel(),
                    const Spacer(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _logout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TerminalColors.green,
                          foregroundColor: TerminalColors.background,
                          textStyle: TerminalTextStyles.button,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'You will be returned to the login screen.',
                      style: TerminalTextStyles.muted,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildInfoCard({
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: TerminalColors.green, width: 1.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TerminalTextStyles.muted),
          const SizedBox(height: 6),
          Text(value, style: TerminalTextStyles.body),
        ],
      ),
    );
  }
}

class _ProfileInfoPanel extends StatelessWidget {
  const _ProfileInfoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: TerminalColors.green, width: 1.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Status',
            style: TerminalTextStyles.heading,
          ),
          SizedBox(height: 10),
          Text(
            'You are signed in and can browse haunted locations, save favorites, and log findings to your journal.',
            style: TerminalTextStyles.body,
          ),
        ],
      ),
    );
  }
}