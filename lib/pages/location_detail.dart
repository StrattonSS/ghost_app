import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  final Color terminalGreen = const Color(0xFF00FF00);

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
        SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            '>> Added to favorites!',
            style: TextStyle(color: terminalGreen, fontFamily: 'Courier'),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          locationData?['name'] ?? 'Loading...',
          style: TextStyle(
            color: terminalGreen,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: isFavorited
          ? null
          : FloatingActionButton.extended(
              backgroundColor: Colors.black,
              icon: Icon(Icons.favorite_border, color: terminalGreen),
              label: Text(
                "Add to Favorites",
                style: TextStyle(color: terminalGreen, fontFamily: 'Courier'),
              ),
              onPressed: addToFavorites,
            ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: terminalGreen))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: DefaultTextStyle(
                style: TextStyle(color: terminalGreen, fontFamily: 'Courier'),
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
