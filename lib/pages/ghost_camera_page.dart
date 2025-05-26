import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'terminal_theme.dart';

class GhostCameraPage extends StatefulWidget {
  const GhostCameraPage({super.key});

  @override
  State<GhostCameraPage> createState() => _GhostCameraPageState();
}

class _GhostCameraPageState extends State<GhostCameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _showGhost = false;
  String? _capturedImagePath;
  String? _ghostOverlayUsed;

  final List<String> ghostFullImages = [
    'assets/ghosts/full/ghost1.png',
    'assets/ghosts/full/ghost2.png',
  ];
  final List<String> ghostOrbs = [
    'assets/ghosts/orbs/orb1.png',
    'assets/ghosts/orbs/orb2.png',
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _checkProximity();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _controller = CameraController(camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  void _checkProximity() async {
    final position = await Geolocator.getCurrentPosition();
    final allLocations =
        await FirebaseFirestore.instance.collection('locations').get();

    double closestDistance = double.infinity;

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

      if (distance < closestDistance) {
        closestDistance = distance;
      }
    }

    setState(() {
      _showGhost = closestDistance < 100;
    });
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      String? ghostOverlay;
      if (_showGhost) {
        double roll = Random().nextDouble();
        if (roll < 0.3) {
          ghostOverlay =
              ghostFullImages[Random().nextInt(ghostFullImages.length)];
        } else if (roll < 0.7) {
          ghostOverlay = ghostOrbs[Random().nextInt(ghostOrbs.length)];
        }
      }

      setState(() {
        _capturedImagePath = image.path;
        _ghostOverlayUsed = ghostOverlay;
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 400 ? 0.85 : 1.0;

    return Scaffold(
      backgroundColor: TerminalColors.background,
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  _capturedImagePath == null
                      ? CameraPreview(_controller)
                      : Image.file(
                          File(_capturedImagePath!),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                  if (_ghostOverlayUsed != null)
                    Positioned.fill(
                      child: Image.asset(
                        _ghostOverlayUsed!,
                        fit: BoxFit.cover,
                        color: Colors.white.withOpacity(0.5),
                        colorBlendMode: BlendMode.plus,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: TerminalColors.green, width: 2),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TerminalColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "REC",
                        style: TerminalTextStyles.label.copyWith(
                          color: TerminalColors.red,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100 * scaleFactor,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TerminalColors.accent,
                          foregroundColor: TerminalColors.text,
                          textStyle: TerminalTextStyles.button.copyWith(
                            fontSize: 16 * scaleFactor,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24 * scaleFactor,
                            vertical: 12 * scaleFactor,
                          ),
                        ),
                        onPressed: _takePicture,
                        icon: Icon(Icons.camera_alt, size: 20 * scaleFactor),
                        label: const Text("Capture"),
                      ),
                    ),
                  ),
                  if (_ghostOverlayUsed != null)
                    Positioned(
                      bottom: 30 * scaleFactor,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _ghostOverlayUsed = null;
                              _capturedImagePath = null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TerminalColors.backgroundLight,
                            foregroundColor: TerminalColors.text,
                            textStyle: TerminalTextStyles.button.copyWith(
                              fontSize: 16 * scaleFactor,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24 * scaleFactor,
                              vertical: 12 * scaleFactor,
                            ),
                          ),
                          child: const Text("Reset View"),
                        ),
                      ),
                    ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: TerminalColors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
