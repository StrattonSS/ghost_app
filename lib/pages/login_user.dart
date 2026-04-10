import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main_scaffold.dart';
import 'terminal_theme.dart';

class LoginUserScreen extends StatefulWidget {
  const LoginUserScreen({super.key});

  @override
  State<LoginUserScreen> createState() => _LoginUserScreenState();
}

class _LoginUserScreenState extends State<LoginUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _login() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showError(_mapAuthError(e));
    } catch (_) {
      _showError('Unable to log in right now. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return e.message ?? 'Login failed.';
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TerminalTextStyles.body.copyWith(
        color: TerminalColors.green.withOpacity(0.7),
      ),
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

  Widget _buildInputField(
      String label,
      TextEditingController controller, {
        bool obscure = false,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '> $label:',
          style: TerminalTextStyles.body.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: TerminalTextStyles.body,
          cursorColor: TerminalColors.green,
          decoration: _inputDecoration(label),
          validator: validator,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        title: const Text(
          '>> LOGIN_SYS.TXT',
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInputField(
                      'Email',
                      _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Email is required.';
                        }
                        if (!text.contains('@')) {
                          return 'Enter a valid email.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      'Password',
                      _passwordController,
                      obscure: true,
                      validator: (value) {
                        final text = value ?? '';
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TerminalColors.green,
                          foregroundColor: TerminalColors.background,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: TerminalColors.background,
                          ),
                        )
                            : const Text(
                          '>> LOGIN',
                          style: TerminalTextStyles.button,
                        ),
                      ),
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
}