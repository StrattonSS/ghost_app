import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'main_scaffold.dart';
import 'pages/location_detail.dart';
import 'pages/login_user.dart';
import 'pages/splash_screen.dart';
import 'services/leaderboard_service.dart';
import 'pages/terminal_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GhostApp());
}

class GhostApp extends StatefulWidget {
  const GhostApp({super.key});

  static const String splashRoute = '/';
  static const String authRoute = '/auth';
  static const String locationDetailRoute = '/location_detail';

  @override
  State<GhostApp> createState() => _GhostAppState();
}

class _GhostAppState extends State<GhostApp> {
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
          (user) async {
        if (user == null) return;
        await LeaderboardService.instance.ensureUserDocument();
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'G.H.O.S.T.',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: TerminalColors.background,
        colorScheme: const ColorScheme.dark(
          primary: TerminalColors.green,
          secondary: TerminalColors.faded,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: TerminalColors.background,
          foregroundColor: TerminalColors.green,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: TerminalColors.green,
          foregroundColor: Colors.black,
        ),
      ),
      initialRoute: GhostApp.splashRoute,
      routes: {
        GhostApp.splashRoute: (context) => const SplashScreen(),
        GhostApp.authRoute: (context) {
          final user = FirebaseAuth.instance.currentUser;
          return user == null ? const LoginUserScreen() : const MainScaffold();
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == GhostApp.locationDetailRoute) {
          final args = settings.arguments;

          if (args is String && args.isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => LocationDetailPage(locationId: args),
            );
          }

          return MaterialPageRoute(
            builder: (_) => const _RouteErrorPage(
              message: 'Invalid location ID',
            ),
          );
        }

        return null;
      },
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const _RouteErrorPage(
          message: 'Page not found',
        ),
      ),
    );
  }
}

class _RouteErrorPage extends StatelessWidget {
  final String message;

  const _RouteErrorPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: TerminalColors.background,
      body: Center(
        child: Text(
          'Page error',
          style: TerminalTextStyles.body,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}