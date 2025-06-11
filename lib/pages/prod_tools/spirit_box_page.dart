import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../terminal_theme.dart';

class SpiritBoxPage extends StatefulWidget {
  const SpiritBoxPage({Key? key}) : super(key: key);

  @override
  State<SpiritBoxPage> createState() => _SpiritBoxPageState();
}

class _SpiritBoxPageState extends State<SpiritBoxPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<double> _frequencies = [
    87.5,
    89.1,
    90.7,
    92.3,
    93.9,
    95.5,
    97.1,
    98.7,
    100.3,
    101.9,
    103.5,
    105.1,
    106.7,
    108.0,
  ];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _responseDetected = false;
  bool _canLog = false;
  String _currentFreqLabel = '';
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() {
    _isPlaying = true;
    _scanTimer =
        Timer.periodic(const Duration(milliseconds: 300), (timer) async {
      setState(() {
        _currentFreqLabel =
            "${_frequencies[_currentIndex].toStringAsFixed(1)} MHz";
        _responseDetected = Random().nextBool() && Random().nextInt(6) == 0;
      });

      if (_responseDetected) {
        _audioPlayer.stop();
        await _audioPlayer.setAsset('assets/audio/voice_response.mp3');
        await _audioPlayer.play();
        setState(() => _canLog = true);
        await Future.delayed(const Duration(seconds: 2));
        _responseDetected = false;
        _audioPlayer.stop();
      } else {
        await _audioPlayer.setAsset('assets/audio/static.mp3');
        await _audioPlayer.play();
      }

      _currentIndex = (_currentIndex + 1) % _frequencies.length;
    });
  }

  void _logEvidence() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Spirit response logged!'),
        backgroundColor: TerminalColors.background,
      ),
    );
    setState(() => _canLog = false);
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildGlobalBackButton() {
    return Positioned(
      top: 40,
      left: 20,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TerminalColors.backgroundLight,
            border: Border.all(color: TerminalColors.green),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back, color: TerminalColors.green),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: TerminalColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const AnimatedBackground(),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child:
                        Text('SPIRIT BOX', style: TerminalTextStyles.heading),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TerminalColors.backgroundLight,
                      border: Border.all(color: TerminalColors.green),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _currentFreqLabel,
                        style: TerminalTextStyles.body.copyWith(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Icon(
                    LucideIcons.ghost,
                    size: 60,
                    color: _responseDetected
                        ? TerminalColors.green
                        : TerminalColors.faded,
                    shadows: [
                      if (_responseDetected)
                        const Shadow(
                            color: TerminalColors.green, blurRadius: 20),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _canLog ? _logEvidence : null,
                    icon: const Icon(Icons.add),
                    label: const Text("Log Response"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: TerminalColors.green,
                      side: const BorderSide(color: TerminalColors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      textStyle: TerminalTextStyles.body,
                    ),
                  ),
                ],
              ),
            ),
            _buildGlobalBackButton(),
          ],
        ),
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({Key? key}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SpiritBoxPainter(_controller.value),
          child: Container(),
        );
      },
    );
  }
}

class SpiritBoxPainter extends CustomPainter {
  final double value;

  SpiritBoxPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TerminalColors.green.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 20) {
      final startY = sin((i / size.width * 2 * pi) + (value * 2 * pi)) * 30 +
          size.height / 2;
      final endY = cos((i / size.width * 2 * pi) + (value * 2 * pi)) * 30 +
          size.height / 2;
      canvas.drawLine(Offset(i, startY), Offset(i, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant SpiritBoxPainter oldDelegate) => true;
}
