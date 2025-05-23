import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CompassWidget extends StatefulWidget {
  const CompassWidget({super.key});

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  double _azimuth = 0.0;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    magnetometerEvents.listen((MagnetometerEvent event) {
      final angle = atan2(event.y, event.x) * (180 / pi);
      setState(() {
        _azimuth = (angle + 360) % 360;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: -_azimuth * (pi / 180),
        child: Image.asset(
          'assets/compass.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
