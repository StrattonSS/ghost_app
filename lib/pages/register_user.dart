import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCred.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-created',
          message: 'User account could not be created.',
        );
      }

      await user.updateDisplayName(username);
      await user.reload();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'dateOfBirth': _dob?.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Registration failed.');
    } catch (_) {
      _showError('Something went wrong while creating your account.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

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

    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TerminalTextStyles.body,
      filled: true,
      fillColor: TerminalColors.background,
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: TerminalColors.green),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: TerminalColors.green),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: TerminalColors.red),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: TerminalColors.red),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('> $label:', style: TerminalTextStyles.body),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: TerminalTextStyles.body,
          cursorColor: TerminalColors.green,
          decoration: _inputDecoration(label),
          validator: validator,
          enabled: !_loading,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        title: const Text(
          '>> REGISTER_NEW.TXT',
          style: TerminalTextStyles.heading,
        ),
        backgroundColor: TerminalColors.background,
        foregroundColor: TerminalColors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            color: TerminalColors.green,
            onPressed: _loading
                ? null
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginUserScreen(),
                ),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInputField(
                        label: 'Username',
                        controller: _usernameController,
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) {
                            return 'Username is required.';
                          }
                          if (text.length < 3) {
                            return 'Username must be at least 3 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) {
                            return 'Email is required.';
                          }
                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );
                          if (!emailRegex.hasMatch(text)) {
                            return 'Enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Password',
                        controller: _passwordController,
                        obscure: true,
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) {
                            return 'Password is required.';
                          }
                          if (text.length < 6) {
                            return 'Password must be at least 6 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
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
                          onPressed: _loading ? null : _selectDateOfBirth,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TerminalColors.green,
                          foregroundColor: TerminalColors.background,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          textStyle: TerminalTextStyles.button,
                        ),
                        child: _loading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: TerminalColors.background,
                          ),
                        )
                            : const Text('>> REGISTER'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginUserScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Already registered? Sign in',
                          style: TerminalTextStyles.body,
                        ),
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