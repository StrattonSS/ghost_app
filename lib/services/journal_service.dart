import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ghost_app/services/leaderboard_service.dart';

class JournalEntry {
  final String id;
  final String userId;
  final String locationId;
  final String locationName;
  final String city;
  final String state;
  final String evidenceType;
  final String notes;
  final double? magneticReading;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.locationName,
    required this.city,
    required this.state,
    required this.evidenceType,
    required this.notes,
    this.magneticReading,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  factory JournalEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final timestamp = data['createdAt'];

    return JournalEntry(
      id: doc.id,
      userId: (data['userId'] ?? '').toString(),
      locationId: (data['locationId'] ?? '').toString(),
      locationName: (data['locationName'] ?? '').toString(),
      city: (data['city'] ?? '').toString(),
      state: (data['state'] ?? '').toString(),
      evidenceType: (data['evidenceType'] ?? 'Observation').toString(),
      notes: (data['notes'] ?? '').toString(),
      magneticReading: (data['magneticReading'] as num?)?.toDouble(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'locationId': locationId,
      'locationName': locationName,
      'city': city,
      'state': state,
      'evidenceType': evidenceType,
      'notes': notes,
      'magneticReading': magneticReading,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
    };
  }
}

class JournalService {
  JournalService._internal();

  static final JournalService instance = JournalService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      _firestore.collection('reports');

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> logEntry({
    required String locationId,
    required String locationName,
    required String city,
    required String state,
    required String evidenceType,
    required String notes,
    double? magneticReading,
    double? latitude,
    double? longitude,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User must be signed in to save findings.');
    }

    try {
      await _reportsCollection.add({
        'userId': user.uid,
        'locationId': locationId,
        'locationName': locationName,
        'city': city,
        'state': state,
        'evidenceType': evidenceType,
        'notes': notes,
        'magneticReading': magneticReading,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await LeaderboardService.instance.incrementEvidenceLogged();
    } catch (e, stackTrace) {
      log(
        'Failed to save journal entry',
        error: e,
        stackTrace: stackTrace,
        name: 'JournalService',
      );
      rethrow;
    }
  }

  Stream<List<JournalEntry>> streamUserEntries() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _reportsCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map((doc) => JournalEntry.fromDoc(doc)).toList(),
    );
  }
}