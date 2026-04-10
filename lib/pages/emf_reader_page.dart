import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ghost_app/pages/log_finding_page.dart';
import 'package:ghost_app/services/journal_service.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'terminal_theme.dart';

class EMFReaderPage extends StatefulWidget {
  const EMFReaderPage({super.key});

  @override
  State<EMFReaderPage> createState() => _EMFReaderPageState();
}

class _EMFReaderPageState extends State<EMFReaderPage> {
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  double _x = 0.0;
  double _y = 0.0;
  double _z = 0.0;
  double _magnitude = 0.0;
  double _peakReading = 0.0;

  bool _sensorActive = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startMagnetometerStream();
  }

  void _startMagnetometerStream() {
    _magnetometerSubscription = magnetometerEventStream().listen(
          (MagnetometerEvent event) {
        final x = event.x;
        final y = event.y;
        final z = event.z;
        final magnitude = sqrt(x * x + y * y + z * z);

        if (!mounted) return;

        setState(() {
          _x = double.parse(x.toStringAsFixed(1));
          _y = double.parse(y.toStringAsFixed(1));
          _z = double.parse(z.toStringAsFixed(1));
          _magnitude = double.parse(magnitude.toStringAsFixed(1));
          if (_magnitude > _peakReading) {
            _peakReading = _magnitude;
          }
          _sensorActive = true;
          _errorMessage = null;
        });
      },
      onError: (_) {
        if (!mounted) return;

        setState(() {
          _sensorActive = false;
          _errorMessage =
          'Magnetometer unavailable on this device or sensor stream failed.';
        });
      },
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _magnetometerSubscription?.cancel();
    super.dispose();
  }

  String _getStatusLabel() {
    if (!_sensorActive) return 'NO SENSOR DATA';
    if (_magnitude >= 80) return 'SIGNAL SPIKE';
    if (_magnitude >= 60) return 'MINOR CHANGE';
    return 'STABLE BASELINE';
  }

  String _getSuggestedEvidenceType() {
    if (!_sensorActive) return 'Observation';
    if (_magnitude >= 80) return 'Magnetic Spike';
    return 'Observation';
  }

  Color _getStatusColor() {
    if (!_sensorActive) return TerminalColors.greyDark;
    if (_magnitude >= 80) return TerminalColors.red;
    if (_magnitude >= 60) return TerminalColors.orange;
    return TerminalColors.green;
  }

  Color _getBarColor(int index) {
    if (_magnitude >= 80 && index >= 4) return TerminalColors.red;
    if (_magnitude >= 60 && index >= 3) return TerminalColors.orange;
    if (_magnitude >= 40 && index >= 2) return TerminalColors.yellow;
    if (_magnitude >= 20 && index >= 1) return TerminalColors.green;
    return TerminalColors.greyDark;
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled.');
        return null;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permission not granted.');
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (_) {
      _showSnackBar('Could not get current location.');
      return null;
    }
  }

  Future<void> _logCurrentReading() async {
    if (!_sensorActive) {
      _showSnackBar('No active magnetic reading available.');
      return;
    }

    final position = await _getCurrentPosition();

    if (!mounted) return;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => LogFindingPage(
          initialData: {
            'locationId': '',
            'locationName': 'Unknown Location',
            'city': '',
            'state': '',
            'latitude': position?.latitude,
            'longitude': position?.longitude,
            'magneticReading': _magnitude,
            'evidenceType': _getSuggestedEvidenceType(),
          },
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await JournalService.instance.logEntry(
        locationId: (result['locationId'] ?? '').toString(),
        locationName: (result['locationName'] ?? 'Unknown Location').toString(),
        city: (result['city'] ?? '').toString(),
        state: (result['state'] ?? '').toString(),
        evidenceType: (result['evidenceType'] ?? 'Observation').toString(),
        notes: (result['notes'] ?? '').toString(),
        magneticReading: result['magneticReading'] as double?,
        latitude: (result['latitude'] as num?)?.toDouble(),
        longitude: (result['longitude'] as num?)?.toDouble(),
      );

      if (!mounted) return;

      _showSnackBar('Reading saved to your journal.');
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Failed to save reading.');
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _resetPeak() {
    setState(() {
      _peakReading = _magnitude;
    });
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

  Widget _buildEMFBars(double scaleFactor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4 * scaleFactor),
          width: 20 * scaleFactor,
          height: (index + 1) * 20.0 * scaleFactor,
          decoration: BoxDecoration(
            color: _getBarColor(index),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildAxisRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$label: $value µT',
        style: TerminalTextStyles.body,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black),
        label: Text(
          label,
          style: TerminalTextStyles.button.copyWith(color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: TerminalColors.green,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 400 ? 0.8 : 1.0;

    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: const Text(
          '>> MAGNETIC_READER.EXE',
          style: TerminalTextStyles.heading,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Magnetic Field Reader',
                    style: TerminalTextStyles.body,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Look for spikes and sudden changes, not the baseline number.',
                    textAlign: TextAlign.center,
                    style: TerminalTextStyles.muted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$_magnitude µT',
                    style: TerminalTextStyles.heading.copyWith(
                      fontSize: 48 * scaleFactor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Peak: $_peakReading µT',
                    style: TerminalTextStyles.body,
                  ),
                  const SizedBox(height: 20),
                  _buildEMFBars(scaleFactor),
                  const SizedBox(height: 24),
                  Text(
                    _getStatusLabel(),
                    style: TerminalTextStyles.label.copyWith(
                      color: _getStatusColor(),
                      fontSize: 20 * scaleFactor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAxisRow('X', _x),
                  _buildAxisRow('Y', _y),
                  _buildAxisRow('Z', _z),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TerminalTextStyles.body.copyWith(
                        color: TerminalColors.red,
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Watch for sudden spikes or sharp changes while you move through a location. A steady baseline reading is normal because your phone is always detecting Earth’s magnetic field and nearby environmental interference.',
                    textAlign: TextAlign.center,
                    style: TerminalTextStyles.muted,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Best practice: compare one room or area to another, and note unusual jumps that repeat in the same spot. Do not treat a normal baseline value by itself as evidence.',
                    textAlign: TextAlign.center,
                    style: TerminalTextStyles.muted,
                  ),
                  const SizedBox(height: 24),
                  _buildActionButton(
                    icon: Icons.edit_note,
                    label: _isSaving ? 'Saving...' : 'Log This Reading',
                    onPressed: _isSaving ? null : _logCurrentReading,
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: 'Reset Peak Reading',
                    onPressed: _resetPeak,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}