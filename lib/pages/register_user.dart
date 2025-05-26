import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main_scaffold.dart';
import 'login_user.dart';
import 'terminal_theme.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime? _dob;

  bool _loading = false;

  Future<bool> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    final notifStatus = await Permission.notification.request();

    return cameraStatus.isGranted &&
        micStatus.isGranted &&
        notifStatus.isGranted;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      _showError(
          'Camera, microphone, and notification permissions are required.');
      setState(() => _loading = false);
      return;
    }

    try {
      UserCredential userCred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'dateOfBirth': _dob?.toIso8601String(),
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScaffold()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Registration failed');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: TerminalColors.background,
        content: Text(
          '>> ERROR: $message',
          style: TerminalTextStyles.body,
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('> $label:', style: TerminalTextStyles.body),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: TerminalTextStyles.body,
          cursorColor: TerminalColors.green,
          decoration: InputDecoration(
            filled: true,
            fillColor: TerminalColors.background,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: TerminalColors.green),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: TerminalColors.green),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        title: const Text('>> REGISTER_NEW.TXT',
            style: TerminalTextStyles.heading),
        backgroundColor: TerminalColors.background,
        foregroundColor: TerminalColors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            color: TerminalColors.green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginUserScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Form(
                key: _formKey,
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildInputField('Username', _usernameController),
                      const SizedBox(height: 16),
                      _buildInputField('Email', _emailController),
                      const SizedBox(height: 16),
                      _buildInputField('Password', _passwordController,
                          obscure: true),
                      const SizedBox(height: 24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Date of Birth (Optional)',
                          style: TerminalTextStyles.body,
                        ),
                        subtitle: Text(
                          _dob == null
                              ? 'Not selected'
                              : DateFormat.yMMMd().format(_dob!),
                          style: TerminalTextStyles.body,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          color: TerminalColors.green,
                          onPressed: _selectDateOfBirth,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TerminalColors.green,
                          foregroundColor: TerminalColors.background,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          textStyle: TerminalTextStyles.button,
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: TerminalColors.background,
                              )
                            : const Text('>> REGISTER'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
