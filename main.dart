import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ghost_app/pages/login_user.dart';
import 'package:ghost_app/pages/splash_screen.dart';
import 'package:ghost_app/main_scaffold.dart';
import 'package:ghost_app/pages/location_detail.dart'; // ✅ Import this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GhostApp());
}

class GhostApp extends StatelessWidget {
  const GhostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'G.H.O.S.T.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) {
          final user = FirebaseAuth.instance.currentUser;
          return user == null ? const LoginUserScreen() : const MainScaffold();
        },
        '/location_detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is String && args.isNotEmpty) {
            return LocationDetailPage(locationId: args);
          } else {
            return const Scaffold(
              body: Center(child: Text('Invalid location ID')),
            );
          }
        },
      },
    );
  }
}
