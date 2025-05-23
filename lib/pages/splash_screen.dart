import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _dataLoaded = false;
  bool _minimumTimePassed = false;

  @override
  void initState() {
    super.initState();
    // debugPrint("✅ SplashScreen loaded");

    _controller = VideoPlayerController.asset('assets/splash/GHOST_animation.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });

      final player1 = AudioPlayer();
      final player2 = AudioPlayer();

      player1.play(AssetSource('splash/startup1.mp3'));
      Future.delayed(const Duration(seconds: 2),(){
        player2.play(AssetSource('splash/startup2.mp3'));
      });

    // Minimum 10-second wait
    Future.delayed(const Duration(seconds: 10), () {
      _minimumTimePassed = true;
      _checkIfReady();
    });

    _loadAppData();
  }

  Future<void> _loadAppData() async {
    // Simulate real app loading time (replace with actual logic later)
    await Future.delayed(const Duration(seconds: 5));
    _dataLoaded = true;
    _checkIfReady();
  }

  void _checkIfReady() {
    if (_dataLoaded && _minimumTimePassed) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
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
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
