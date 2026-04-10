import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  UserService._internal();

  static final UserService instance = UserService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  String? get userId => currentUser?.uid;

  String get username {
    final user = currentUser;

    if (user == null) {
      return 'Anonymous';
    }

    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }

    return 'Hunter_${user.uid.substring(0, 6)}';
  }

  bool get isSignedIn => currentUser != null;

  bool get isAnonymous => currentUser?.isAnonymous ?? false;
}