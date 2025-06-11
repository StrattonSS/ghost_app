import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:ghost_app/pages/terminal_theme.dart';
import 'package:ghost_app/widgets/high_tech_frame.dart';

class TestEMFReaderPage extends StatefulWidget {
  const TestEMFReaderPage({super.key});

  @override
  State<TestEMFReaderPage> createState() => _TestEMFReaderPageState();
}

class _TestEMFReaderPageState extends State<TestEMFReaderPage>
    with SingleTickerProviderStateMixin {
  double _emfStrength = 0.0;
  int _emfLevel = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    magnetometerEvents.listen((event) {
      final strength =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      final level = (strength / 100).clamp(0, 11).floor();

      setState(() {
        _emfStrength = strength;
        _emfLevel = level;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(12, (i) {
        final isActive = i <= _emfLevel;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 10,
          height: 30 + (i % 4) * 6,
          decoration: BoxDecoration(
            color: isActive ? TerminalColors.green : TerminalColors.greyDark,
            borderRadius: BorderRadius.circular(4),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: TerminalColors.green.withOpacity(0.8),
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

  Widget _buildTerminalBackButton() {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('>> PRESS  BACK TO RETURN TO TOOLS MENU',
          style: TerminalTextStyles.body),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      body: SafeArea(
        child: HighTechFrame(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  children: const [
                    Text('>> EMF_READER.EXE',
                        style: TerminalTextStyles.heading),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EMF\nREADER',
                      style: TerminalTextStyles.heading,
                    ),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: GhostPainter(_controller.value),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Reading Display
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: TerminalColors.background,
                    border: Border.all(color: TerminalColors.green, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: TerminalColors.green.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _emfStrength.toStringAsFixed(1),
                        style: TerminalTextStyles.heading.copyWith(
                          fontSize: 48,
                          shadows: const [
                            Shadow(color: TerminalColors.green, blurRadius: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('mG', style: TerminalTextStyles.body),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Labels
                const Text('STRENGTH', style: TerminalTextStyles.body),
                const Text('MAGNETIC FIELD', style: TerminalTextStyles.body),
                const SizedBox(height: 24),

                // Bar Graph
                _buildBars(),
                const SizedBox(height: 4),

                // Graph Labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    12,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '$i',
                        style: TerminalTextStyles.body.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                ),

                const Spacer(),
                _buildTerminalBackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GhostPainter extends CustomPainter {
  final double progress;
  GhostPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TerminalColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final ghostPath = Path();
    ghostPath.moveTo(centerX, centerY - 20);
    ghostPath.quadraticBezierTo(
        centerX + 14, centerY - 10, centerX + 10, centerY + 10);
    ghostPath.arcToPoint(
      Offset(centerX - 10, centerY + 10),
      radius: Radius.circular(14),
      clockwise: false,
    );
    ghostPath.quadraticBezierTo(
        centerX - 14, centerY - 10, centerX, centerY - 20);

    // Animate sway
    canvas.save();
    canvas.translate(sin(progress * 2 * pi) * 2, sin(progress * pi * 2) * 1.5);
    canvas.drawPath(ghostPath, paint);

    // Eyes
    double eyeRadius = 2.5;
    canvas.drawCircle(Offset(centerX - 5, centerY - 4), eyeRadius, paint);
    canvas.drawCircle(Offset(centerX + 5, centerY - 4), eyeRadius, paint);

    // Grid lines
    for (int i = -10; i <= 10; i += 4) {
      canvas.drawLine(
        Offset(centerX + i.toDouble(), centerY - 12),
        Offset(centerX + i.toDouble(), centerY + 10),
        paint,
      );
    }

    for (int i = -12; i <= 10; i += 4) {
      canvas.drawLine(
        Offset(centerX - 10, centerY + i.toDouble()),
        Offset(centerX + 10, centerY + i.toDouble()),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GhostPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
