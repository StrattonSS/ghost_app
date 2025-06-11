import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../terminal_theme.dart';

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

  Widget _buildSignalMeter(double value, double scaleFactor) {
    final int level = (value / 20).clamp(0, 5).toInt();

    final colors = [
      TerminalColors.green.withOpacity(0.3),
      TerminalColors.green.withOpacity(0.5),
      TerminalColors.green.withOpacity(0.7),
      TerminalColors.green.withOpacity(0.85),
      TerminalColors.green,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4 * scaleFactor),
          width: 20 * scaleFactor,
          height: (index + 1) * 20.0 * scaleFactor,
          decoration: BoxDecoration(
            color: index < level ? colors[index] : TerminalColors.greyDark,
            borderRadius: BorderRadius.circular(4),
            boxShadow: index < level
                ? [
                    BoxShadow(
                      color: colors[index].withOpacity(0.8),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
        );
      }),
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
        title:
            const Text('>> EMF_READER.EXE', style: TerminalTextStyles.heading),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'EMF READER',
                style: TerminalTextStyles.heading,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: TerminalColors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: TerminalColors.green.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _emfValue.toStringAsFixed(1),
                      style: TerminalTextStyles.heading.copyWith(
                        fontSize: 64 * scaleFactor,
                        color: TerminalColors.green,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: TerminalColors.green,
                            offset: Offset(0, 0),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'mG',
                      style: TerminalTextStyles.label.copyWith(
                        fontSize: 18 * scaleFactor,
                        color: TerminalColors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'STRENGTH',
                      style: TerminalTextStyles.body,
                    ),
                    const Text(
                      'MAGNETIC FIELD',
                      style: TerminalTextStyles.body,
                    ),
                    const SizedBox(height: 16),
                    _buildSignalMeter(_emfValue, scaleFactor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
