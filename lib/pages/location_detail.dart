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
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final favs = List<Map<String, dynamic>>.from(
            userDoc.data()?['favoritedLocations'] ?? []);
        final alreadyFavorited =
            favs.any((fav) => fav['id'] == widget.locationId);

        setState(() {
          locationData = doc.data();
          isFavorited = alreadyFavorited;
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

    final userRef = _firestore.collection('users').doc(user.uid);
    final newFavorite = {
      'id': widget.locationId,
      'name': locationData!['name'],
      'city': locationData!['city'],
      'state': locationData!['state'],
      'imageUrl': locationData!['imageUrl'] ?? '',
    };

    try {
      await userRef.update({
        'favoritedLocations': FieldValue.arrayUnion([newFavorite])
      });

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
          : Padding(
              padding: const EdgeInsets.all(16),
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
    );
  }
}
