import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  static final _locationsCollection =
      FirebaseFirestore.instance.collection('locations');

  static Future<List<Map<String, dynamic>>> getAllLocations() async {
    try {
      final snapshot = await _locationsCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to data map
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching locations: $e');
      return [];
    }
  }
}
