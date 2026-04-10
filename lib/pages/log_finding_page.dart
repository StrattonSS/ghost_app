import 'package:flutter/material.dart';

import 'terminal_theme.dart';

class LogFindingPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const LogFindingPage({
    super.key,
    this.initialData,
  });

  @override
  State<LogFindingPage> createState() => _LogFindingPageState();
}

class _LogFindingPageState extends State<LogFindingPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _locationNameController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _notesController;
  late final TextEditingController _magneticReadingController;

  String _evidenceType = 'Observation';
  bool _isSubmitting = false;

  final List<String> _evidenceTypes = const [
    'Observation',
    'Magnetic Spike',
    'Audio',
    'Visual',
    'Environmental Change',
  ];

  @override
  void initState() {
    super.initState();

    final data = widget.initialData ?? {};

    _locationNameController = TextEditingController(
      text: (data['locationName'] ?? '').toString(),
    );
    _cityController = TextEditingController(
      text: (data['city'] ?? '').toString(),
    );
    _stateController = TextEditingController(
      text: (data['state'] ?? '').toString(),
    );
    _notesController = TextEditingController();
    _magneticReadingController = TextEditingController(
      text: data['magneticReading'] != null
          ? data['magneticReading'].toString()
          : '',
    );

    final incomingType = (data['evidenceType'] ?? 'Observation').toString();
    if (_evidenceTypes.contains(incomingType)) {
      _evidenceType = incomingType;
    }
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _notesController.dispose();
    _magneticReadingController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final result = {
      'locationId': widget.initialData?['locationId'],
      'locationName': _locationNameController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'notes': _notesController.text.trim(),
      'evidenceType': _evidenceType,
      'magneticReading': double.tryParse(_magneticReadingController.text.trim()),
      'latitude': widget.initialData?['latitude'],
      'longitude': widget.initialData?['longitude'],
    };

    if (!mounted) return;

    Navigator.pop(context, result);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TerminalTextStyles.body,
      filled: true,
      fillColor: Colors.black,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: TerminalColors.green,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: TerminalColors.green,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: TerminalColors.red,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: TerminalColors.red,
          width: 1.8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: const Text(
          '>> LOG_FINDING',
          style: TerminalTextStyles.heading,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Record what you observed at this location. Save spikes, repeated anomalies, and field notes you want in your journal.',
                  style: TerminalTextStyles.body,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _locationNameController,
                  style: TerminalTextStyles.body,
                  decoration: _inputDecoration('Location name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Location name is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityController,
                  style: TerminalTextStyles.body,
                  decoration: _inputDecoration('City'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stateController,
                  style: TerminalTextStyles.body,
                  decoration: _inputDecoration('State'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _evidenceType,
                  dropdownColor: Colors.black,
                  style: TerminalTextStyles.body,
                  decoration: _inputDecoration('Evidence type'),
                  items: _evidenceTypes
                      .map(
                        (type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _evidenceType = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _magneticReadingController,
                  style: TerminalTextStyles.body,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('Magnetic reading (µT)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  style: TerminalTextStyles.body,
                  minLines: 4,
                  maxLines: 8,
                  decoration: _inputDecoration('What happened?'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your field notes.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tip: log repeated spikes, unusual changes, and what was happening around you. Do not treat a normal baseline by itself as evidence.',
                  style: TerminalTextStyles.muted,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TerminalColors.green,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _isSubmitting ? 'Saving...' : 'Save Finding',
                      style: TerminalTextStyles.button.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}