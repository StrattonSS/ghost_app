import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main_scaffold.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Color terminalGreen = const Color(0xFF00FF00);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  void _toggleFormType() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<void> _submit() async {
    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScaffold()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Authentication failed.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          '>> ERROR: $message',
          style: TextStyle(color: terminalGreen, fontFamily: 'Courier'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  isLogin ? '>> LOGIN_SYS.TXT' : '>> REGISTER_NEW.TXT',
                  style: TextStyle(
                    color: terminalGreen,
                    fontFamily: 'Courier',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                _buildInputField("Email", _emailController),
                const SizedBox(height: 16),
                _buildInputField("Password", _passwordController,
                    obscure: true),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: isLoading ? null : _submit,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: terminalGreen),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: terminalGreen)
                      : Text(
                          isLogin ? ">> LOGIN" : ">> REGISTER",
                          style: TextStyle(
                              color: terminalGreen, fontFamily: 'Courier'),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: isLoading ? null : _toggleFormType,
                  child: Text(
                    isLogin
                        ? "> Need to register?"
                        : "> Already have an account?",
                    style:
                        TextStyle(color: terminalGreen, fontFamily: 'Courier'),
                  ),
                ),
              ],
            ),
          ),
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
          style: TextStyle(
              color: terminalGreen, fontFamily: 'Courier', fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(color: terminalGreen, fontFamily: 'Courier'),
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
      ],
    );
  }
}
