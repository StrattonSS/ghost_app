import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/user_service.dart';
import 'terminal_theme.dart';

class SubmitLocationPage extends StatefulWidget {
  const SubmitLocationPage({super.key});

  @override
  State<SubmitLocationPage> createState() => _SubmitLocationPageState();
}

class _SubmitLocationPageState extends State<SubmitLocationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _typeController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _activityController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
    });

    final latitudeText = _latitudeController.text.trim();
    final longitudeText = _longitudeController.text.trim();

    final latitude = latitudeText.isEmpty ? null : double.tryParse(latitudeText);
    final longitude =
    longitudeText.isEmpty ? null : double.tryParse(longitudeText);

    if ((latitudeText.isNotEmpty && latitude == null) ||
        (longitudeText.isNotEmpty && longitude == null)) {
      _showSnackBar('Latitude and longitude must be valid numbers.');
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final data = {
      'name': _nameController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'type': _typeController.text.trim(),
      'shortDescription': _shortDescriptionController.text.trim(),
      'description': _descriptionController.text.trim(),
      'activity': _activityController.text.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'status': 'pending',
      'submittedBy': UserService.instance.userId,
      'submittedAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('submissions').add(data);

      if (!mounted) return;

      _showSnackBar('Location submitted for review.');
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      _showSnackBar('Failed to submit location.');
      setState(() {
        _isSubmitting = false;
      });
      return;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: TerminalColors.background,
        content: Text(
          message,
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
      fillColor: Colors.black,
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
      alignLabelWithHint: true,
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    int minLines = 1,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: TerminalTextStyles.body,
        cursorColor: TerminalColors.green,
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        decoration: _inputDecoration(label),
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _typeController.dispose();
    _shortDescriptionController.dispose();
    _descriptionController.dispose();
    _activityController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: const Text(
          '>> SUBMIT_LOC.TXT',
          style: TerminalTextStyles.heading,
        ),
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
                  children: [
                    const Text(
                      'Submit a haunted location for review. Approved submissions can be added to the shared location database.',
                      style: TerminalTextStyles.body,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _nameController,
                      label: 'Location name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Location name is required.';
                        }
                        return null;
                      },
                    ),
                    _buildField(
                      controller: _cityController,
                      label: 'City',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'City is required.';
                        }
                        return null;
                      },
                    ),
                    _buildField(
                      controller: _stateController,
                      label: 'State',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'State is required.';
                        }
                        return null;
                      },
                    ),
                    _buildField(
                      controller: _typeController,
                      label: 'Location type',
                    ),
                    _buildField(
                      controller: _shortDescriptionController,
                      label: 'Short description',
                      minLines: 2,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                    ),
                    _buildField(
                      controller: _descriptionController,
                      label: 'Full description',
                      minLines: 4,
                      maxLines: 6,
                      keyboardType: TextInputType.multiline,
                    ),
                    _buildField(
                      controller: _activityController,
                      label: 'Reported activity',
                      minLines: 2,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                    ),
                    _buildField(
                      controller: _latitudeController,
                      label: 'Latitude (optional)',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                    _buildField(
                      controller: _longitudeController,
                      label: 'Longitude (optional)',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TerminalColors.green,
                          foregroundColor: Colors.black,
                          textStyle: TerminalTextStyles.body,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          _isSubmitting ? 'Submitting...' : 'Submit Location',
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