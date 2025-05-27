import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<List<String>> getStates() async {
    final snapshot = await _firestore.collection('locations').get();
    final states =
        snapshot.docs.map((doc) => doc['state'] as String).toSet().toList();
    states.sort();
    return states;
  }

  static Future<List<String>> getCities(String state) async {
    final snapshot = await _firestore
        .collection('locations')
        .where('state', isEqualTo: state)
        .get();

    final cities =
        snapshot.docs.map((doc) => doc['city'] as String).toSet().toList();
    cities.sort();
    return cities;
  }

  static Future<List<Map<String, dynamic>>> getLocations(
      String state, String city) async {
    final snapshot = await _firestore
        .collection('locations')
        .where('state', isEqualTo: state)
        .where('city', isEqualTo: city)
        .get();

    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            })
        .toList();
  }
}
