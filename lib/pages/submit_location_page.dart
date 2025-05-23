import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';

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

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Location submitted for review."),
      ));

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
      appBar: AppBar(title: const Text("Submit a Haunted Location")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: _controllers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: entry.key.replaceAll(
                        RegExp(r'([a-z])([A-Z])'), r'\$1 \$2').capitalize(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Required" : null,
                ),
              );
            }).toList()
              ..add(
                  Padding(
                    padding:const EdgeInsets.all(8.0),
                    child:ElevatedButton(
                onPressed: _submit,
                child: const Text("Submit Location"),
              )),
          ),
        ),
      ),
    ));
  }
}

extension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}