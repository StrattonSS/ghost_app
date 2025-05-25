import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ghost_app/pages/splash_screen.dart';
import 'firebase_options.dart'; // Make sure this file exists from FlutterFire CLI

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
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Courier',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF00FF00)),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00FF00),
          brightness: Brightness.dark,
          background: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
