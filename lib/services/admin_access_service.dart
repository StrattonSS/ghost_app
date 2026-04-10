import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAccessService {
  AdminAccessService._internal();

  static final AdminAccessService instance = AdminAccessService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isAdmin = false;

  Future<bool> signInAdmin(String email, String password) async {
    try {
      isAdmin = false;

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final userId = credential.user?.uid;
      if (userId == null) {
        await _auth.signOut();
        return false;
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final role = userDoc.data()?['role']?.toString().trim().toLowerCase();

      if (role == 'admin') {
        isAdmin = true;
        return true;
      }

      await _auth.signOut();
      return false;
    } on FirebaseAuthException {
      isAdmin = false;
      return false;
    } on FirebaseException {
      isAdmin = false;
      await _safeSignOut();
      return false;
    } catch (_) {
      isAdmin = false;
      await _safeSignOut();
      return false;
    }
  }

  Future<void> refreshAdminStatus() async {
    final user = _auth.currentUser;
    if (user == null) {
      isAdmin = false;
      return;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final role = userDoc.data()?['role']?.toString().trim().toLowerCase();
      isAdmin = role == 'admin';
    } catch (_) {
      isAdmin = false;
    }
  }

  Future<void> signOut() async {
    isAdmin = false;
    await _auth.signOut();
  }

  Future<void> _safeSignOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}