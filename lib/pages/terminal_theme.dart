import 'package:flutter/material.dart';

class TerminalColors {
  static const background = Colors.black;
  static const foreground = Color(0xFF00FF00); // Bright green
  static const muted = Color(0xFF007700); // Dimmer green
  static const error = Color(0xFFFF5555); // Red for errors
  static const card = Color(0xFF111111); // Dark gray for cards
}

class TerminalTextStyles {
  static const heading = TextStyle(
    color: TerminalColors.foreground,
    fontSize: 24,
    fontFamily: 'Glasstty',
    fontWeight: FontWeight.bold,
  );

  static const body = TextStyle(
    color: TerminalColors.foreground,
    fontSize: 16,
    fontFamily: 'Glasstty',
  );

  static const muted = TextStyle(
    color: TerminalColors.muted,
    fontSize: 14,
    fontFamily: 'Glasstty',
  );
}
