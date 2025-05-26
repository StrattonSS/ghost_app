import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';
import 'terminal_theme.dart';

class SubmitLocationPage extends StatefulWidget {
  const SubmitLocationPage({super.key});

  @override
  State<SubmitLocationPage> createState() => _SubmitLocationPageState();
}

class _SubmitLocationPageState extends State<SubmitLocationPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'city': TextEditingController(),
    'state': TextEditingController(),
    'locationType': TextEditingController(),
    'shortDescription': TextEditingController(),
    'description': TextEditingController(),
    'activity': TextEditingController(),
    'coordinates': TextEditingController(),
  };

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final data = {
        'name': _controllers['name']!.text,
        'city': _controllers['city']!.text,
        'state': _controllers['state']!.text,
        'locationType': _controllers['locationType']!.text,
        'shortDescription': _controllers['shortDescription']!.text,
        'description': _controllers['description']!.text,
        'activity': _controllers['activity']!.text,
        'coordinates': _controllers['coordinates']!.text,
        'status': 'pending',
        'submittedBy': UserService.instance.userId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await FirebaseFirestore.instance.collection('submissions').add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location submitted for review."),
          backgroundColor: TerminalColors.background,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title:
            const Text(">> SUBMIT_LOC.TXT", style: TerminalTextStyles.heading),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Form(
                key: _formKey,
                child: Column(
                  children: _controllers.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        controller: entry.value,
                        style: TerminalTextStyles.body,
                        cursorColor: TerminalColors.green,
                        decoration: InputDecoration(
                          labelText: entry.key
                              .replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')
                              .capitalize(),
                          labelStyle: TerminalTextStyles.body.copyWith(
                            color: TerminalColors.green.withOpacity(0.7),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: TerminalColors.green),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: TerminalColors.green),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "Required" : null,
                      ),
                    );
                  }).toList()
                    ..add(
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TerminalColors.green,
                            foregroundColor: Colors.black,
                            textStyle: TerminalTextStyles.body,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Submit Location"),
                        ),
                      ),
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

extension on String {
  String capitalize() =>
      isNotEmpty ? this[0].toUpperCase() + substring(1) : this;
}
