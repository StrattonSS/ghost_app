import 'package:flutter/material.dart';

class TerminalColors {
  const TerminalColors._();

  static const Color background = Colors.black;
  static const Color backgroundLight = Color(0xFF1A1A1A);
  static const Color green = Color(0xFF00FF00);
  static const Color faded = Color(0xFF00AA00);
  static const Color red = Color(0xFFFF3B30);
  static const Color orange = Color(0xFFFFA500);
  static const Color yellow = Color(0xFFFFFF00);
  static const Color greyDark = Color(0xFF444444);
  static const Color accent = Color(0xFF222222);
  static const Color text = Color(0xFFB8FFB8);

  static Color get transparentGreen => green.withValues(alpha: 0.1);
}

class TerminalTextStyles {
  const TerminalTextStyles._();

  static const String _fontFamily = 'Glasstty';

  static const TextStyle heading = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: TerminalColors.green,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    color: TerminalColors.text,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: TerminalColors.text,
    letterSpacing: 0.4,
  );

  static const TextStyle muted = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    color: TerminalColors.faded,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: TerminalColors.green,
  );
}

class TerminalButtonStyles {
  const TerminalButtonStyles._();

  static final ButtonStyle elevated = ElevatedButton.styleFrom(
    backgroundColor: TerminalColors.green,
    foregroundColor: Colors.black,
    textStyle: TerminalTextStyles.button,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}