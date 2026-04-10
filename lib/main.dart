import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ghost_app/firebase_options.dart';
import 'package:ghost_app/pages/location_detail.dart';
import 'package:ghost_app/pages/login_user.dart';
import 'package:ghost_app/pages/splash_screen.dart';

import 'main_scaffold.dart';

Future<void> main() async {
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
      title: 'G.H.O.S.T.',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.cyanAccent,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) {
          final user = FirebaseAuth.instance.currentUser;
          return user == null ? const LoginUserScreen() : const MainScaffold();
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/location_detail') {
          final args = settings.arguments;

          if (args is String && args.isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => LocationDetailPage(locationId: args),
            );
          }

          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Text(
                  'Invalid location ID',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }

        return null;
      },
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Text(
              'Page not found',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}