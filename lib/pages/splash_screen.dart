import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/ghost_animation.mp4');
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();

      if (!mounted) return;

      _controller.addListener(_handleVideoProgress);
      setState(() {});
      await _controller.play();
    } catch (error) {
      debugPrint('❌ Error initializing video: $error');
      _goToAuth();
    }
  }

  void _handleVideoProgress() {
    final value = _controller.value;

    if (!value.isInitialized || _navigated) return;

    final isFinished =
        value.duration > Duration.zero && value.position >= value.duration;

    if (isFinished) {
      _goToAuth();
    }
  }

  void _goToAuth() {
    if (!mounted || _navigated) return;

    _navigated = true;
    _controller.removeListener(_handleVideoProgress);

    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  void dispose() {
    _controller.removeListener(_handleVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: isReady
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : const CircularProgressIndicator(),
      ),
    );
  }
}