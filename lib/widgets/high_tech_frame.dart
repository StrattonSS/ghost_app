import 'package:flutter/material.dart';
import 'package:ghost_app/pages/terminal_theme.dart';

class HighTechFrame extends StatelessWidget {
  final Widget child;
  const HighTechFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HighTechFramePainter(),
      child: child,
    );
  }
}

class HighTechFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TerminalColors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    const padding = 10.0;

    // Outer Rect
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(padding, padding, size.width - padding * 2,
          size.height - padding * 2),
      const Radius.circular(12),
    ));

    // Tech-style lines (top left)
    path.moveTo(padding + 20, padding);
    path.lineTo(padding + 40, padding + 10);
    path.lineTo(padding + 60, padding);

    // Tech-style lines (bottom right)
    path.moveTo(size.width - padding - 60, size.height - padding);
    path.lineTo(size.width - padding - 40, size.height - padding - 10);
    path.lineTo(size.width - padding - 20, size.height - padding);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
