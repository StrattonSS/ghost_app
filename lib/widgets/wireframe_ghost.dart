// lib/widgets/wireframe_ghost.dart
import 'dart:math';
import 'package:flutter/material.dart';

class WireframeGhost extends StatefulWidget {
  const WireframeGhost({super.key});

  @override
  State<WireframeGhost> createState() => _WireframeGhostState();
}

class _WireframeGhostState extends State<WireframeGhost>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: CustomPaint(
            painter: _GhostPainter(),
            size: const Size(200, 300),
          ),
        );
      },
    );
  }
}

class _GhostPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;

    final path = Path();

    // Head (semi-circle)
    path.moveTo(centerX - 40, 80);
    path.quadraticBezierTo(centerX, 0, centerX + 40, 80);

    // Body
    path.lineTo(centerX + 40, 200);
    path.quadraticBezierTo(centerX, 230, centerX - 40, 200);
    path.close();

    // Arms
    canvas.drawLine(
        Offset(centerX - 40, 120), Offset(centerX - 70, 160), paint);
    canvas.drawLine(
        Offset(centerX + 40, 120), Offset(centerX + 70, 160), paint);

    // Eyes
    canvas.drawCircle(Offset(centerX - 15, 60), 4, paint);
    canvas.drawCircle(Offset(centerX + 15, 60), 4, paint);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
