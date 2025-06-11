import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../terminal_theme.dart';

class UVSensorPage extends StatefulWidget {
  const UVSensorPage({super.key});

  @override
  State<UVSensorPage> createState() => _UvSensorPageState();
}

class _UvSensorPageState extends State<UVSensorPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isNearHotspot = false;
  Timer? _proximityTimer;
  String? revealedImage;
  Offset? imagePosition;

  final List<String> uvAssets = [
    'assets/uv/handprint.png',
    'assets/uv/footprint.png',
    'assets/uv/message1.png',
    'assets/uv/stain1.png',
    'assets/uv/message2.png',
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
    _startProximityCheck();
  }

  void _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  void _startProximityCheck() {
    _proximityTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
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
        isNearHotspot = closestDistance <= 100;
      });
    });
  }

  void _onScanTap(BuildContext context) {
    if (!isNearHotspot) return;

    if (revealedImage != null) {
      setState(() {
        revealedImage = null;
        imagePosition = null;
      });
    } else {
      final random = Random();
      final asset = uvAssets[random.nextInt(uvAssets.length)];
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final pos = Offset(
        random.nextDouble() * (screenWidth - 150),
        random.nextDouble() * (screenHeight - 300),
      );

      setState(() {
        revealedImage = asset;
        imagePosition = pos;
        HapticFeedback.mediumImpact();
      });
    }
  }

  void _logEvidence(BuildContext context) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Evidence logged!"),
        backgroundColor: TerminalColors.background,
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Positioned(
      top: top + 8,
      left: 12,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: TerminalColors.green, width: 2),
                color: Colors.black.withOpacity(0.5),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back, color: TerminalColors.green),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _proximityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onScanTap(context),
      child: Scaffold(
        backgroundColor: TerminalColors.background,
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  CameraPreview(_controller),
                  Container(color: Colors.deepPurple.withOpacity(0.3)),
                  _buildBackButton(context),
                  if (isNearHotspot &&
                      revealedImage != null &&
                      imagePosition != null)
                    Positioned(
                      left: imagePosition!.dx,
                      top: imagePosition!.dy,
                      child: Image.asset(
                        revealedImage!,
                        width: 120,
                        color: Colors.purpleAccent.withOpacity(0.9),
                        colorBlendMode: BlendMode.screen,
                      ),
                    ),
                  if (isNearHotspot && revealedImage == null)
                    const Center(
                      child: Text(
                        ">> Tap to scan with UV light...",
                        style: TerminalTextStyles.muted,
                      ),
                    ),
                  if (isNearHotspot && revealedImage != null)
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _logEvidence(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: TerminalColors.green,
                            textStyle: TerminalTextStyles.button,
                            side: const BorderSide(color: TerminalColors.green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text("Log Evidence"),
                        ),
                      ),
                    ),
                  if (!isNearHotspot)
                    const Center(
                      child: Text(
                        ">> No paranormal evidence nearby...",
                        style: TerminalTextStyles.muted,
                      ),
                    ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(color: TerminalColors.green),
              );
            }
          },
        ),
      ),
    );
  }
}
