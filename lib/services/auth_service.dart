import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? getCurrentUser() => _auth.currentUser;

  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('Sign-in error [${e.code}]: ${e.message}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign-in unexpected error: $e');
      }
      return null;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('Registration error [${e.code}]: ${e.message}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Registration unexpected error: $e');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}