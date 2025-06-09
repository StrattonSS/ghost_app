import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get list of unique states from the 'locations' collection
  static Future<List<String>> getStates() async {
    final snapshot = await _firestore.collection('locations').get();

    final states = snapshot.docs
        .map((doc) => doc.data()['state'] as String?)
        .where((state) => state != null)
        .cast<String>()
        .toSet()
        .toList();

    states.sort();
    return states;
  }

  /// Get list of unique cities within a selected state
  static Future<List<String>> getCities(String state) async {
    final snapshot = await _firestore
        .collection('locations')
        .where('state', isEqualTo: state)
        .get();

    final cities = snapshot.docs
        .map((doc) => doc.data()['city'] as String?)
        .where((city) => city != null)
        .cast<String>()
        .toSet()
        .toList();

    cities.sort();
    return cities;
  }

  /// Get all locations matching a selected state and city
  static Future<List<Map<String, dynamic>>> getLocations(
      String state, String city) async {
    final snapshot = await _firestore
        .collection('locations')
        .where('state', isEqualTo: state)
        .where('city', isEqualTo: city)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Attach the Firestore doc ID
      return data;
    }).toList();
  }
}
