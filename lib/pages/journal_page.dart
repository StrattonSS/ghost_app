import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/journal_service.dart';
import 'location_detail.dart';
import 'terminal_theme.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  String? get _userId => _auth.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> _favoritesStream() {
    final userId = _userId;
    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: const Text(
          '>> FINDINGS_LOG',
          style: TerminalTextStyles.heading,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: TerminalColors.green,
          unselectedLabelColor: TerminalColors.text,
          indicatorColor: TerminalColors.green,
          labelStyle: TerminalTextStyles.body,
          tabs: const [
            Tab(text: 'Findings'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      body: user == null
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '>> Sign in to view your saved locations and field findings.',
            style: TerminalTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildReportsTab(),
          _buildFavoritesTab(),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return StreamBuilder<List<JournalEntry>>(
      stream: JournalService.instance.streamUserEntries(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log(
            'Error loading reports',
            error: snapshot.error,
            name: 'JournalPage',
          );

          return const Center(
            child: Text(
              '>> Failed to load findings.',
              style: TerminalTextStyles.body,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: TerminalColors.green),
          );
        }

        final entries = snapshot.data ?? [];

        if (entries.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                '>> No findings logged yet.\nVisit a location and document what you experienced.',
                style: TerminalTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];

            final formattedDate = entry.createdAt == null
                ? 'Saving timestamp...'
                : DateFormat.yMMMd().add_jm().format(entry.createdAt!);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: TerminalColors.green),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '> ${entry.locationName.isEmpty ? 'Unknown Location' : entry.locationName}',
                    style: TerminalTextStyles.heading,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.city.isEmpty ? 'Unknown City' : entry.city}, ${entry.state.isEmpty ? 'Unknown State' : entry.state}',
                    style: TerminalTextStyles.body,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Type: ${entry.evidenceType}',
                    style: TerminalTextStyles.body,
                  ),
                  Text(
                    'Logged: $formattedDate',
                    style: TerminalTextStyles.body,
                  ),
                  if (entry.magneticReading != null)
                    Text(
                      'Magnetic reading: ${entry.magneticReading} µT',
                      style: TerminalTextStyles.body,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    entry.notes.isEmpty ? 'No notes added.' : entry.notes,
                    style: TerminalTextStyles.body,
                  ),
                  if (entry.locationId.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LocationDetailPage(locationId: entry.locationId),
                            ),
                          );
                        },
                        child: const Text('Open Location'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _favoritesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log(
            'Error loading favorites',
            error: snapshot.error,
            name: 'JournalPage',
          );

          return const Center(
            child: Text(
              '>> Failed to load saved locations.',
              style: TerminalTextStyles.body,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: TerminalColors.green),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              '>> No saved locations found.',
              style: TerminalTextStyles.body,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final location = docs[index].data();
            final locationId = (location['id'] ?? '').toString();

            return GestureDetector(
              onTap: locationId.isEmpty
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LocationDetailPage(locationId: locationId),
                  ),
                );
              },
              child: _terminalCard(
                title: (location['name'] ?? 'Unknown').toString(),
                subtitle:
                '${location['city'] ?? 'Unknown City'}, ${location['state'] ?? 'Unknown State'}',
              ),
            );
          },
        );
      },
    );
  }

  Widget _terminalCard({
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: TerminalColors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('> $title', style: TerminalTextStyles.heading),
          const SizedBox(height: 2),
          Text(subtitle, style: TerminalTextStyles.body),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}