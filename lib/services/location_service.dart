import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final CollectionReference<Map<String, dynamic>> _locationsCollection =
  _firestore.collection('locations');

  static CollectionReference<Map<String, dynamic>> _userCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('visited_locations');

  static CollectionReference<Map<String, dynamic>> _favoritesCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorites');

  static String? get currentUserId => _auth.currentUser?.uid;

  static Future<List<Map<String, dynamic>>> getAllLocations() async {
    try {
      final snapshot = await _locationsCollection.orderBy('name').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e, stackTrace) {
      log(
        'Error fetching locations',
        error: e,
        stackTrace: stackTrace,
        name: 'LocationService',
      );
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getLocationById(String locationId) async {
    try {
      final doc = await _locationsCollection.doc(locationId).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return {
        'id': doc.id,
        ...doc.data()!,
      };
    } catch (e, stackTrace) {
      log(
        'Error fetching location by ID',
        error: e,
        stackTrace: stackTrace,
        name: 'LocationService',
      );
      return null;
    }
  }

  static Stream<List<Map<String, dynamic>>> streamVisitedLocations() {
    final uid = currentUserId;

    if (uid == null) {
      return Stream.value([]);
    }

    return _userCollection(uid)
        .orderBy('lastVisitedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList(),
    )
        .handleError((error, stackTrace) {
      log(
        'Error streaming visited locations',
        error: error,
        stackTrace: stackTrace,
        name: 'LocationService',
      );
    });
  }

  static Stream<List<Map<String, dynamic>>> streamFavoriteLocations() {
    final uid = currentUserId;

    if (uid == null) {
      return Stream.value([]);
    }

    return _favoritesCollection(uid)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList(),
    )
        .handleError((error, stackTrace) {
      log(
        'Error streaming favorite locations',
        error: error,
        stackTrace: stackTrace,
        name: 'LocationService',
      );
    });
  }
}