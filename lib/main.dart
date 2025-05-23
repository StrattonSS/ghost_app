import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ghost_app/pages/splash_screen.dart'; // Splash screen
import 'package:ghost_app/main_scaffold.dart'; // New bottom tab navigation

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/', // Start with splash
    routes: {
      '/': (context) => const SplashScreen(),
      '/home': (context) => const MainScaffold(), // Route to tab layout
    },
  ));
}
