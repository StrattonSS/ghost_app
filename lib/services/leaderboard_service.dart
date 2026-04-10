import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardService {
  LeaderboardService._internal();

  static final LeaderboardService instance = LeaderboardService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _defaultUsername(User user) {
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

  DocumentReference<Map<String, dynamic>> _leaderboardRef(String uid) {
    return _firestore.collection('leaderboard').doc(uid);
  }

  CollectionReference<Map<String, dynamic>> _visitedRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('visited_locations');
  }

  Future<void> ensureUserDocument() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final leaderboardRef = _leaderboardRef(user.uid);
    final snapshot = await leaderboardRef.get();

    if (!snapshot.exists) {
      await leaderboardRef.set({
        'username': _defaultUsername(user),
        'locationsVisited': 0,
        'entriesLogged': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await leaderboardRef.set(
      {
        'username': _defaultUsername(user),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<bool> recordUniqueVisit({
    required String locationId,
    required Map<String, dynamic> locationData,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final leaderboardRef = _leaderboardRef(user.uid);
    final visitedRef = _visitedRef(user.uid).doc(locationId);

    bool wasNewVisit = false;

    await _firestore.runTransaction((transaction) async {
      final visitedSnapshot = await transaction.get(visitedRef);

      final visitPayload = {
        'id': locationId,
        'name': (locationData['name'] ?? '').toString(),
        'city': (locationData['city'] ?? '').toString(),
        'state': (locationData['state'] ?? '').toString(),
        'type': (locationData['type'] ?? '').toString(),
        'activity': (locationData['activity'] ?? '').toString(),
        'description': (locationData['description'] ?? '').toString(),
        'latitude': (locationData['latitude'] as num?)?.toDouble(),
        'longitude': (locationData['longitude'] as num?)?.toDouble(),
        'lastVisitedAt': FieldValue.serverTimestamp(),
      };

      if (!visitedSnapshot.exists) {
        wasNewVisit = true;

        transaction.set(visitedRef, visitPayload);

        transaction.set(
          leaderboardRef,
          {
            'username': _defaultUsername(user),
            'locationsVisited': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } else {
        transaction.set(
          visitedRef,
          {
            'lastVisitedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        transaction.set(
          leaderboardRef,
          {
            'username': _defaultUsername(user),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    });

    return wasNewVisit;
  }

  Future<void> incrementEvidenceLogged() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _leaderboardRef(user.uid).set(
      {
        'username': _defaultUsername(user),
        'entriesLogged': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}