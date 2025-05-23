import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThermalVisionPage extends StatefulWidget {
  const ThermalVisionPage({super.key});

  @override
  State<ThermalVisionPage> createState() => _ThermalVisionPageState();
}

class _ThermalVisionPageState extends State<ThermalVisionPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  double? _heading;
  double? _bearingToHotspot;
  double? _distanceToHotspot;
  bool _showColdVisuals = false;
  Timer? _positionTimer;

  final List<String> coldVisuals = [
    'assets/thermal/cold_orb1.png',
    'assets/thermal/cold_orb2.png',
    'assets/thermal/silhouette.png',
  ];

  String? _currentColdVisual;
  Offset? _visualPosition;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _startCompassListener();
    _startLocationTracking();
  }

  void _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _controller = CameraController(camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  void _startCompassListener() {
    magnetometerEvents.listen((event) {
      final heading = atan2(event.y, event.x) * (180 / pi);
      setState(() {
        _heading = (heading + 360) % 360;
      });
    });
  }

  void _startLocationTracking() {
    _positionTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
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

      double? diff = (_heading != null && bearingToClosest != null)
          ? _bearingDifference(_heading!, bearingToClosest)
          : null;

      final isAligned = (closestDistance < 100 && diff != null && diff < 20);

      if (isAligned) {
        if (closestDistance < 20) {
          HapticFeedback.heavyImpact();
        } else if (closestDistance < 50) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
      }

      setState(() {
        _distanceToHotspot = closestDistance;
        _bearingToHotspot = bearingToClosest;
        _showColdVisuals = isAligned;
        _currentColdVisual = isAligned
            ? coldVisuals[Random().nextInt(coldVisuals.length)]
            : null;
        _visualPosition = isAligned
            ? Offset(
                Random().nextDouble() * 200 + 100,
                Random().nextDouble() * 300 + 200,
              )
            : null;
      });
    });
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    double dLon = lon2 - lon1;
    double y = sin(dLon * pi / 180) * cos(lat2 * pi / 180);
    double x = cos(lat1 * pi / 180) * sin(lat2 * pi / 180) -
        sin(lat1 * pi / 180) * cos(lat2 * pi / 180) * cos(dLon * pi / 180);
    double bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  double _bearingDifference(double heading, double bearing) {
    double diff = (bearing - heading).abs();
    return diff > 180 ? 360 - diff : diff;
  }

  @override
  void dispose() {
    _controller.dispose();
    _positionTimer?.cancel();
    super.dispose();
  }

  void _logEvidence(String evidenceType) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Evidence logged: $evidenceType')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    1.5, 0.0, 0.0, 0.0, 0.0, // red
                    0.0, 1.2, 0.0, 0.0, 0.0, // green
                    0.0, 0.0, 0.5, 0.0, 0.0, // blue
                    0.0, 0.0, 0.0, 1.0, 0.0, // alpha
                  ]),
                  child: CameraPreview(_controller),
                ),
                if (_showColdVisuals &&
                    _currentColdVisual != null &&
                    _visualPosition != null)
                  Positioned(
                    left: _visualPosition!.dx,
                    top: _visualPosition!.dy,
                    child: Image.asset(
                      _currentColdVisual!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      color: Colors.cyanAccent.withOpacity(0.7),
                      colorBlendMode: BlendMode.screen,
                    ),
                  ),
                const Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Thermal Vision Active",
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ),
                ),
                if (_showColdVisuals && _currentColdVisual != null)
                  Positioned(
                    bottom: 70,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () => _logEvidence(
                          _currentColdVisual!
                              .split('/')
                              .last
                              .replaceAll('.png', ''),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Log Thermal Evidence"),
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
