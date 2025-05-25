import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ghost_app/pages/splash_screen.dart';
import 'firebase_options.dart';
import 'pages/terminal_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GhostApp());
}

class GhostApp extends StatelessWidget {
  const GhostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'G.H.O.S.T.',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: TerminalColors.background,
        fontFamily: 'Courier',
        appBarTheme: const AppBarTheme(
          backgroundColor: TerminalColors.background,
          foregroundColor: TerminalColors.green,
          titleTextStyle: TerminalTextStyles.heading,
          iconTheme: IconThemeData(color: TerminalColors.green),
        ),
        iconTheme: const IconThemeData(color: TerminalColors.green),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: TerminalColors.background,
          foregroundColor: TerminalColors.green,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
