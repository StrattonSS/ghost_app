import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/ghost_animation.mp4')
      ..initialize().then((_) {
        debugPrint("✅ Video initialized");
        setState(() {});
        _controller.play();

        // Only start listening AFTER it's initialized
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
        // Fallback if video fails
        Navigator.of(context).pushReplacementNamed('/auth');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
