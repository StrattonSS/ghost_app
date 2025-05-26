import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScaffold()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Login failed');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: TerminalColors.background,
        content: Text(
          '>> ERROR: Login failed',
          style: TerminalTextStyles.body,
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '> $label:',
          style: TerminalTextStyles.body.copyWith(fontSize: 14),
        ),
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
        title:
            const Text('>> LOGIN_SYS.TXT', style: TerminalTextStyles.heading),
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
                    _buildInputField('Email', _emailController),
                    const SizedBox(height: 16),
                    _buildInputField('Password', _passwordController,
                        obscure: true),
                    const SizedBox(height: 24),
                    ElevatedButton(
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
                          ? const CircularProgressIndicator(
                              color: TerminalColors.background,
                            )
                          : const Text('>> LOGIN',
                              style: TerminalTextStyles.button),
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
