import 'package:flutter/material.dart';

class TerminalColors {
  static const Color background = Colors.black;
  static const Color backgroundLight = Color(0xFF1A1A1A);
  static const Color green = Color(0xFF00FF00);
  static const Color faded = Color(0xFF00AA00);
  static const Color red = Color(0xFFFF3B30);
  static const Color orange = Color(0xFFFFA500); // 🟧 Added
  static const Color yellow = Color(0xFFFFFF00); // 🟨 Added
  static const Color greyDark = Color(0xFF444444); // 🩶 Added
  static const Color accent = Color(0xFF222222);
  static const Color text = Color(0xFFB8FFB8);
}

class TerminalTextStyles {
  static const String _fontFamily = 'Glasstty';

  static const TextStyle heading = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: TerminalColors.green,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    color: TerminalColors.text,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: TerminalColors.text,
  );

  static const TextStyle muted = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    color: TerminalColors.faded,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: TerminalColors.green,
  );
}

class TerminalButtonStyles {
  static final Elevated = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(TerminalColors.green),
    foregroundColor: MaterialStateProperty.all(Colors.black),
    textStyle: MaterialStateProperty.all(TerminalTextStyles.button),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
