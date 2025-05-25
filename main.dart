import 'package:flutter/material.dart';
// Firebase initialization temporarily commented out
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const GhostApp());
}

class GhostApp extends StatelessWidget {
  const GhostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'G.H.O.S.T.',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: Colors.greenAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.greenAccent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.green,
          foregroundColor: Colors.black,
        ),
      ),
      home: const PlaceholderSplashScreen(),
    );
  }
}

class PlaceholderSplashScreen extends StatelessWidget {
  const PlaceholderSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'G.H.O.S.T.',
          style: TextStyle(
            fontSize: 32,
            color: Colors.greenAccent,
            fontFamily: 'Courier',
          ),
        ),
      ),
    );
  }
}
