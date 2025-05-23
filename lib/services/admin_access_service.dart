import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAccessService {
  static final AdminAccessService instance = AdminAccessService._internal();

  AdminAccessService._internal();

  bool isAdmin = false;

  Future<bool> signInAdmin(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userId = credential.user?.uid;
      if (userId == null) return false;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(
          userId).get();
      final role = userDoc.data()?['role'];
      isAdmin = role == 'admin';
      return isAdmin;
    } catch (e) {
      return false;
    }
  }
}