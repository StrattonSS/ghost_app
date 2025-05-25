import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/splash_screen.dart';

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
        primaryColor: const Color(0xFF00FF00),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: 'Glasstty',
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: 'Glasstty',
          ),
          titleLarge: TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: 'Glasstty',
            fontSize: 20,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Color(0xFF00FF00),
          titleTextStyle: TextStyle(
            fontFamily: 'Glasstty',
            color: Color(0xFF00FF00),
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Color(0xFF00FF00)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF00),
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontFamily: 'Glasstty'),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.black,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00FF00)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00FF00)),
          ),
          labelStyle: TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: 'Glasstty',
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
