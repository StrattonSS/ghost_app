import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  static final CollectionReference<Map<String, dynamic>> _locationsCollection =
      FirebaseFirestore.instance.collection('locations');

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
}