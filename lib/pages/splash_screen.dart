import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _navigated = false;
  bool _isConnected = true;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivityAndInit();
  }

  Future<void> _checkConnectivityAndInit() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final connected = connectivityResult != ConnectivityResult.none;

    if (connected) {
      _initializeVideo();
    } else {
      setState(() {
        _isConnected = false;
      });
    }
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset('assets/ghost_animation.mp4')
      ..initialize().then((_) {
        debugPrint("✅ Video initialized");
        setState(() {
          _videoReady = true;
          _isConnected = true;
        });
        _controller.play();

        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration &&
              !_navigated) {
            _navigated = true;
            debugPrint("✅ Video completed, navigating to /auth");
            Navigator.of(context).pushReplacementNamed('/auth');
          }
        });
      }).catchError((error) {
        debugPrint("❌ Error initializing video: $error");
        Navigator.of(context).pushReplacementNamed('/auth');
      });
  }

  @override
  void dispose() {
    if (_videoReady) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: !_isConnected
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 100, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'No internet connection.\nPlease connect to Wi-Fi or cellular data.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isConnected = true; // optimistically try again
                      });
                      _checkConnectivityAndInit();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              )
            : _videoReady
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
