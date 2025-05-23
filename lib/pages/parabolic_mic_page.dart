import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

class ParabolicMicPage extends StatefulWidget {
  const ParabolicMicPage({super.key});

  @override
  State<ParabolicMicPage> createState() => _ParabolicMicPageState();
}

class _ParabolicMicPageState extends State<ParabolicMicPage>
    with SingleTickerProviderStateMixin {
  double? _heading;
  double? _bearingToHotspot;
  double? _distanceToHotspot;
  late AnimationController _radarController;
  Timer? _locationTimer;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlayingAudio = false;

  final List<String> whispers = [
    'assets/sounds/whisper1.mp3',
    'assets/sounds/whisper2.mp3',
    'assets/sounds/whisper3.mp3',
  ];

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _listenToCompass();
    _startLocationTracking();
  }

  void _listenToCompass() {
    magnetometerEvents.listen((event) {
      final heading = atan2(event.y, event.x) * (180 / pi);
      setState(() {
        _heading = (heading + 360) % 360;
      });
    });
  }

  void _startLocationTracking() {
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final position = await Geolocator.getCurrentPosition();
      final allLocations =
          await FirebaseFirestore.instance.collection('locations').get();

      double closestDistance = double.infinity;
      double? bearingToClosest;

      for (var doc in allLocations.docs) {
        final hotspot = doc['hotspot'].split(';');
        final lat = double.parse(hotspot[0]);
        final lng = double.parse(hotspot[1]);

        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          lat,
          lng,
        );

        double bearing = _calculateBearing(
          position.latitude,
          position.longitude,
          lat,
          lng,
        );

        if (distance < closestDistance) {
          closestDistance = distance;
          bearingToClosest = bearing;
        }
      }

      setState(() {
        _distanceToHotspot = closestDistance;
        _bearingToHotspot = bearingToClosest;
      });

      _handleAudioLogic();
    });
  }

  void _handleAudioLogic() async {
    if (_distanceToHotspot == null ||
        _bearingToHotspot == null ||
        _heading == null) {
      return;
    }

    double diff = (_bearingToHotspot! - _heading!).abs();
    if (diff > 180) diff = 360 - diff;

    if (_distanceToHotspot! < 150 && diff < 15) {
      if (!_isPlayingAudio) {
        final sound = whispers[Random().nextInt(whispers.length)];
        await _player.play(AssetSource(sound));
        _isPlayingAudio = true;
      }
    } else {
      if (_isPlayingAudio) {
        await _player.stop();
        _isPlayingAudio = false;
      }
    }
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    double dLon = lon2 - lon1;
    double y = sin(dLon * pi / 180) * cos(lat2 * pi / 180);
    double x = cos(lat1 * pi / 180) * sin(lat2 * pi / 180) -
        sin(lat1 * pi / 180) * cos(lat2 * pi / 180) * cos(dLon * pi / 180);
    double bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _radarController.dispose();
    _player.dispose();
    super.dispose();
  }

  void _logEvidence(String type) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evidence logged!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Parabolic Microphone"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.greenAccent,
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: CustomPaint(
                painter: RadarPainter(_radarController),
              ),
            ),
            const Positioned(
              bottom: 100,
              child: Text(
                "Rotate device to find the signal...",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: _isPlayingAudio ? () => _logEvidence('evp') : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isPlayingAudio ? Colors.blue : Colors.grey,
                  ),
                  child: const Text("Log Evidence"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final Animation<double> animation;

  RadarPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (double r = radius / 4; r <= radius; r += radius / 4) {
      canvas.drawCircle(center, r, paint);
    }

    final sweepPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final sweepAngle = 0.3;
    final startAngle = animation.value * 2 * pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      true,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) => true;
}
