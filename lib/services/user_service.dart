import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserService {
  static final UserService instance = UserService._internal();

  UserService._internal();

  String? userId;
  String username = "Anonymous";

  Future<void> initUser() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser ?? await auth.signInAnonymously();
    userId = FirebaseAuth.instance.currentUser?.uid;
    username = "Hunter_${userId!.substring(0, 6)}";
  }

  bool get isSignedIn => userId != null;
}