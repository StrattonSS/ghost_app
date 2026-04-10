import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ghost_app/pages/log_finding_page.dart';
import 'package:ghost_app/services/journal_service.dart';
import 'package:ghost_app/services/leaderboard_service.dart';
import 'package:ghost_app/services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  Future<void> loadLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final location = await LocationService.getLocationById(widget.locationId);
      final user = _auth.currentUser;

      bool favoriteExists = false;

      if (user != null) {
        final favDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(widget.locationId)
            .get();

        favoriteExists = favDoc.exists;
      }

      if (!mounted) return;

      if (location == null) {
        setState(() {
          errorMessage = 'Location not found.';
          isLoading = false;
        });
        return;
      }

      setState(() {
        locationData = location;
        isFavorited = favoriteExists;
        isLoading = false;
      });

      await _recordVisit();
    } catch (e, stackTrace) {
      log(
        'Error loading location detail',
        error: e,
        stackTrace: stackTrace,
        name: 'LocationDetailPage',
      );

      if (!mounted) return;

      setState(() {
        errorMessage = 'Failed to load location details.';
        isLoading = false;
      });
    }
  }

  Future<void> _recordVisit() async {
    if (locationData == null) return;

    try {
      await LeaderboardService.instance.recordUniqueVisit(
        locationId: widget.locationId,
        locationData: locationData!,
      );
    } catch (e, stackTrace) {
      log(
        'Failed to record location visit',
        error: e,
        stackTrace: stackTrace,
        name: 'LocationDetailPage',
      );
    }
  }

  Future<void> toggleFavorite() async {
    final user = _auth.currentUser;
    if (user == null || locationData == null) {
      _showSnackBar('You must be logged in to manage favorites.');
      return;
    }

    final favoriteRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.locationId);

    try {
      if (isFavorited) {
        await favoriteRef.delete();

        if (!mounted) return;

        setState(() {
          isFavorited = false;
        });

        _showSnackBar('Removed from favorites.');
        return;
      }

      await favoriteRef.set({
        'id': widget.locationId,
        'name': (locationData!['name'] ?? '').toString(),
        'city': (locationData!['city'] ?? '').toString(),
        'state': (locationData!['state'] ?? '').toString(),
        'type': (locationData!['type'] ?? '').toString(),
        'activity': (locationData!['activity'] ?? '').toString(),
        'description': (locationData!['description'] ?? '').toString(),
        'latitude': (locationData!['latitude'] as num?)?.toDouble(),
        'longitude': (locationData!['longitude'] as num?)?.toDouble(),
        'savedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isFavorited = true;
      });

      _showSnackBar('Added to favorites.');
    } catch (e, stackTrace) {
      log(
        'Failed to toggle favorite',
        error: e,
        stackTrace: stackTrace,
        name: 'LocationDetailPage',
      );
      _showSnackBar('Failed to update favorites.');
    }
  }

  Future<void> openDirections() async {
    if (locationData == null) return;

    final lat = (locationData!['latitude'] as num?)?.toDouble();
    final lng = (locationData!['longitude'] as num?)?.toDouble();

    if (lat == null || lng == null) {
      _showSnackBar('This location does not have coordinates yet.');
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not open map directions.');
    }
  }

  Future<void> startReportFlow() async {
    if (locationData == null) return;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => LogFindingPage(
          initialData: {
            'locationId': widget.locationId,
            'locationName': locationData!['name'],
            'city': locationData!['city'],
            'state': locationData!['state'],
            'latitude': locationData!['latitude'],
            'longitude': locationData!['longitude'],
            'evidenceType': 'Observation',
          },
        ),
      ),
    );

    if (result == null) return;

    try {
      await JournalService.instance.logEntry(
        locationId: (result['locationId'] ?? widget.locationId).toString(),
        locationName: (result['locationName'] ?? '').toString(),
        city: (result['city'] ?? '').toString(),
        state: (result['state'] ?? '').toString(),
        evidenceType: (result['evidenceType'] ?? 'Observation').toString(),
        notes: (result['notes'] ?? '').toString(),
        magneticReading: (result['magneticReading'] as num?)?.toDouble(),
        latitude: (result['latitude'] as num?)?.toDouble(),
        longitude: (result['longitude'] as num?)?.toDouble(),
      );

      if (!mounted) return;
      _showSnackBar('Finding saved to your journal.');
    } catch (e, stackTrace) {
      log(
        'Failed to save finding from location detail',
        error: e,
        stackTrace: stackTrace,
        name: 'LocationDetailPage',
      );

      if (!mounted) return;
      _showSnackBar('Failed to save finding.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: TerminalColors.background,
        content: Text(
          message,
          style: TerminalTextStyles.body,
        ),
      ),
    );
  }

  Widget buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: TerminalColors.green, width: 1.5),
          foregroundColor: TerminalColors.green,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: TerminalTextStyles.button),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: TerminalColors.green),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage!,
                style: TerminalTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: loadLocation,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final location = locationData!;
    final city = (location['city'] ?? 'Unknown City').toString();
    final state = (location['state'] ?? 'Unknown State').toString();
    final type = location['type'];
    final activity = location['activity'];
    final description = location['description'];

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: DefaultTextStyle(
              style: TerminalTextStyles.body,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('> City: $city'),
                  Text('> State: $state'),
                  if (type != null && type.toString().isNotEmpty)
                    Text('> Type: $type'),
                  if (activity != null && activity.toString().isNotEmpty)
                    Text('> Activity: $activity'),
                  const SizedBox(height: 20),
                  if (description != null && description.toString().isNotEmpty)
                    Text(description.toString()),
                  const SizedBox(height: 24),
                  buildActionButton(
                    icon: Icons.directions,
                    label: 'Get Directions',
                    onPressed: openDirections,
                  ),
                  const SizedBox(height: 12),
                  buildActionButton(
                    icon: Icons.edit_note,
                    label: 'Log Findings',
                    onPressed: startReportFlow,
                  ),
                  const SizedBox(height: 12),
                  buildActionButton(
                    icon: isFavorited ? Icons.favorite : Icons.favorite_border,
                    label: isFavorited
                        ? 'Remove from Favorites'
                        : 'Add to Favorites',
                    onPressed: toggleFavorite,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: Text(
          locationData?['name']?.toString() ?? 'Location Details',
          style: TerminalTextStyles.heading,
        ),
      ),
      body: buildBody(),
    );
  }
}