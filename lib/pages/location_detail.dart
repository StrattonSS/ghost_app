import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'terminal_theme.dart';

class LocationDetailPage extends StatefulWidget {
  final String locationId;

  const LocationDetailPage({super.key, required this.locationId});

  @override
  State<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? locationData;
  bool isLoading = true;
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  Future<void> loadLocation() async {
    try {
      final doc =
          await _firestore.collection('locations').doc(widget.locationId).get();
      final user = _auth.currentUser;

      if (doc.exists && user != null) {
        final favDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(widget.locationId)
            .get();

        setState(() {
          locationData = doc.data();
          isFavorited = favDoc.exists;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading location: $e');
    }
  }

  Future<void> addToFavorites() async {
    final user = _auth.currentUser;
    if (user == null || locationData == null) return;

    final locationId = widget.locationId;

    final favoriteRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(locationId);

    final newFavorite = {
      'id': locationId,
      'name': locationData!['name'] ?? '',
      'city': locationData!['city'] ?? '',
      'state': locationData!['state'] ?? '',
      'type': locationData!['type'] ?? '',
      'activity': locationData!['activity'] ?? '',
      'description': locationData!['description'] ?? '',
      'coordinates': locationData!['coordinates'] ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await favoriteRef.set(newFavorite);

      setState(() {
        isFavorited = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: TerminalColors.background,
          content: Text(
            '>> Added to favorites!',
            style: TerminalTextStyles.body,
          ),
        ),
      );
    } catch (e) {
      print('Failed to favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: Text(
          locationData?['name'] ?? 'Loading...',
          style: TerminalTextStyles.heading,
        ),
      ),
      floatingActionButton: isFavorited
          ? null
          : FloatingActionButton.extended(
              backgroundColor: TerminalColors.background,
              icon: const Icon(Icons.favorite_border,
                  color: TerminalColors.green),
              label: const Text(
                "Add to Favorites",
                style: TerminalTextStyles.button,
              ),
              onPressed: addToFavorites,
            ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: TerminalColors.green),
            )
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: DefaultTextStyle(
                      style: TerminalTextStyles.body,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("> City: ${locationData!['city']}"),
                          Text("> State: ${locationData!['state']}"),
                          if (locationData!['type'] != null)
                            Text("> Type: ${locationData!['type']}"),
                          if (locationData!['activity'] != null)
                            Text("> Activity: ${locationData!['activity']}"),
                          const SizedBox(height: 20),
                          if (locationData!['description'] != null)
                            Text(locationData!['description']),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
