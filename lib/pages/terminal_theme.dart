import 'package:flutter/material.dart';

class TerminalColors {
  static const Color green = Color(0xFF00FF00);
  static const Color red = Colors.redAccent;
  static const Color faded = Color(0xAA00FF00);
  static const Color background = Colors.black;
  static const Color gray = Colors.white70;
}

class TerminalTextStyles {
  static const TextStyle heading = TextStyle(
    color: TerminalColors.green,
    fontFamily: 'Courier',
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headingWithSize(double size) =>
      heading.copyWith(fontSize: size);

  static const TextStyle body = TextStyle(
    color: TerminalColors.green,
    fontFamily: 'Courier',
  );

  static const TextStyle faded = TextStyle(
    color: TerminalColors.faded,
    fontFamily: 'Courier',
  );

  static const TextStyle muted = TextStyle(
    color: TerminalColors.gray,
    fontFamily: 'Courier',
  );

  static const TextStyle italicMuted = TextStyle(
    color: TerminalColors.gray,
    fontFamily: 'Courier',
    fontStyle: FontStyle.italic,
  );
}

class TerminalButtonStyles {
  static final Elevated = ElevatedButton.styleFrom(
    backgroundColor: TerminalColors.green,
    foregroundColor: Colors.black,
    textStyle: TerminalTextStyles.body,
    padding: const EdgeInsets.symmetric(vertical: 12),
  );

  static final Outlined = OutlinedButton.styleFrom(
    side: const BorderSide(color: TerminalColors.green),
    foregroundColor: TerminalColors.green,
    backgroundColor: TerminalColors.background,
    textStyle: TerminalTextStyles.body,
    padding: const EdgeInsets.symmetric(vertical: 12),
  );
}
