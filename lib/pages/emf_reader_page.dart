import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'terminal_theme.dart';

class EMFReaderPage extends StatefulWidget {
  const EMFReaderPage({Key? key}) : super(key: key);

  @override
  _EMFReaderPageState createState() => _EMFReaderPageState();
}

class _EMFReaderPageState extends State<EMFReaderPage> {
  double _emfValue = 0.0;

  @override
  void initState() {
    super.initState();
    _startMagnetometerStream();
  }

  void _startMagnetometerStream() {
    magnetometerEvents.listen((MagnetometerEvent event) {
      final x = event.x;
      final y = event.y;
      final z = event.z;
      final magnitude = sqrt(x * x + y * y + z * z);

      setState(() {
        _emfValue = double.parse(magnitude.toStringAsFixed(1));
      });
    });
  }

  Color _getBarColor(int index) {
    if (_emfValue >= 80 && index >= 4) return TerminalColors.red;
    if (_emfValue >= 60 && index >= 3) return TerminalColors.orange;
    if (_emfValue >= 40 && index >= 2) return TerminalColors.yellow;
    if (_emfValue >= 20 && index >= 1) return TerminalColors.green;
    return TerminalColors.greyDark;
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

  @override
  Widget build(BuildContext context) {
    final isAlarm = _emfValue > 50.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 400 ? 0.8 : 1.0;

    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title:
            const Text('>> EMF_READER.EXE', style: TerminalTextStyles.heading),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('EMF Strength', style: TerminalTextStyles.body),
                    const SizedBox(height: 12),
                    Text(
                      '$_emfValue µT',
                      style: TerminalTextStyles.heading
                          .copyWith(fontSize: 48 * scaleFactor),
                    ),
                    const SizedBox(height: 20),
                    _buildEMFBars(scaleFactor),
                    const SizedBox(height: 30),
                    Text(
                      isAlarm ? 'ALARM' : 'NORMAL',
                      style: TerminalTextStyles.label.copyWith(
                        color:
                            isAlarm ? TerminalColors.red : TerminalColors.green,
                        fontSize: 20 * scaleFactor,
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
