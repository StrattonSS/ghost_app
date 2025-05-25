import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

import 'register_user.dart';
import 'terminal_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _animationReady = false;

  @override
  void initState() {
    super.initState();

    _controller =
        VideoPlayerController.asset('assets/splash/GHOST_animation.mp4')
          ..initialize().then((_) {
            _controller.setLooping(true);
            _controller.play();
            setState(() => _animationReady = true);
          });

    final player1 = AudioPlayer();
    final player2 = AudioPlayer();

    player1.play(AssetSource('splash/startup1.mp3'));
    Future.delayed(const Duration(seconds: 2), () {
      player2.play(AssetSource('splash/startup2.mp3'));
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RegisterUserScreen()),
        );
      }
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
      backgroundColor: TerminalColors.background,
      body: Center(
        child: _animationReady
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(color: TerminalColors.green),
      ),
    );
  }
}
