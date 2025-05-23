import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class EMFReaderPage extends StatefulWidget {
  const EMFReaderPage({Key? key}) : super(key: key);

  @override
  _EMFReaderPageState createState() => _EMFReaderPageState();
}

class _EMFReaderPageState extends State<EMFReaderPage>
    with SingleTickerProviderStateMixin {
  double _emfValue = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _startMagnetometerStream();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
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
    if (_emfValue >= 80 && index >= 4) return Colors.red;
    if (_emfValue >= 60 && index >= 3) return Colors.orange;
    if (_emfValue >= 40 && index >= 2) return Colors.yellow;
    if (_emfValue >= 20 && index >= 1) return Colors.green;
    return Colors.grey[800]!;
  }

  Widget _buildEMFBars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 20,
          height: (index + 1) * 20.0,
          decoration: BoxDecoration(
            color: _getBarColor(index),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: _getBarColor(index).withOpacity(0.7),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      }),
    );
  }

  void _logEvidence() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evidence logged!')),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCircuitBackground() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _CircuitFlowPainter(_animation.value),
          child: Container(),
        );
      },
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.greenAccent, width: 2),
            color: Colors.black.withOpacity(0.5),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.arrow_back, color: Colors.greenAccent),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAlarm = _emfValue > 50.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildAnimatedCircuitBackground(),
          Container(color: Colors.black.withOpacity(0.4)),
          _buildBackButton(context),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'EMF Strength',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                ),
                Text(
                  '$_emfValue µT',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 48,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.green,
                        blurRadius: 12,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildEMFBars(),
                const SizedBox(height: 30),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isAlarm ? Colors.red : Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: isAlarm ? Colors.redAccent : Colors.grey,
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    isAlarm ? 'ALARM' : 'NORMAL',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _logEvidence,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.greenAccent,
                    side: const BorderSide(color: Colors.greenAccent),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('LOG EVIDENCE'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircuitFlowPainter extends CustomPainter {
  final double animationValue;

  _CircuitFlowPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..color = Colors.greenAccent.withOpacity(0.15);

    final spacing = 40.0;
    final shift = animationValue * spacing * 2;

    for (double y = -spacing * 2; y < size.height + spacing * 2; y += spacing) {
      final offsetY = y + shift;
      canvas.drawLine(
        Offset(0, offsetY),
        Offset(size.width, offsetY + spacing / 2),
        paint,
      );
    }

    for (double x = -spacing * 2; x < size.width + spacing * 2; x += spacing) {
      final offsetX = x + shift;
      canvas.drawLine(
        Offset(offsetX, 0),
        Offset(offsetX - spacing / 2, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitFlowPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
