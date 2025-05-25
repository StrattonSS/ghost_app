import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'terminal_theme.dart'; // ✅ Corrected import path

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> favorites = [];
  List<Map<String, dynamic>> visited = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserJournal();
  }

  Future<void> _loadUserJournal() async {
    try {
      final userId = 'testUser123'; // Replace with FirebaseAuth.uid later
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final data = userDoc.data();

      if (data != null) {
        final favs =
            List<Map<String, dynamic>>.from(data['favoritedLocations'] ?? []);
        final visits =
            List<Map<String, dynamic>>.from(data['visitedLocations'] ?? []);
        setState(() {
          favorites = favs;
          visited = visits;
        });
      }
    } catch (e) {
      print('Error loading journal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: const Text('>> JOURNAL_LOG.TXT'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: TerminalColors.green,
          unselectedLabelColor: TerminalColors.faded,
          indicatorColor: TerminalColors.green,
          labelStyle: TerminalTextStyles.body,
          tabs: const [
            Tab(text: 'Favorites'),
            Tab(text: 'Visited'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoritesTab(),
          _buildVisitedTab(),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          '>> No favorited locations found.',
          style: TerminalTextStyles.body,
        ),
      );
    }

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final location = favorites[index];
        return _terminalCard(
          title: location['name'],
          subtitle: '${location['city']}, ${location['state']}',
          trailing: '[★ FAVORITED]',
          trailingColor: TerminalColors.red,
        );
      },
    );
  }

  Widget _buildVisitedTab() {
    if (visited.isEmpty) {
      return const Center(
        child: Text(
          '>> No visited locations found.',
          style: TerminalTextStyles.body,
        ),
      );
    }

    return ListView.builder(
      itemCount: visited.length,
      itemBuilder: (context, index) {
        final location = visited[index];
        final tools = Map<String, dynamic>.from(location['toolsUsed'] ?? {});

        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: TerminalColors.green),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExpansionTile(
            backgroundColor: Colors.transparent,
            iconColor: TerminalColors.green,
            collapsedIconColor: TerminalColors.green,
            textColor: TerminalColors.green,
            collapsedTextColor: TerminalColors.green,
            title: Text(
              '> ${location['name']}',
              style: TerminalTextStyles.heading.copyWith(fontSize: 18),
            ),
            subtitle: Text(
              '${location['city']}, ${location['state']}',
              style: TerminalTextStyles.body.copyWith(
                fontSize: 14,
                color: TerminalColors.green.withOpacity(0.8),
              ),
            ),
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: tools.entries.map((entry) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getToolIcon(entry.key),
                        color: entry.value ? TerminalColors.green : Colors.grey,
                        size: 28,
                      ),
                      Text(
                        entry.key,
                        style: TerminalTextStyles.muted.copyWith(fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _terminalCard({
    required String title,
    required String subtitle,
    String? trailing,
    Color? trailingColor,
  }) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: TerminalColors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('> $title',
              style: TerminalTextStyles.heading.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TerminalTextStyles.body.copyWith(
              fontSize: 14,
              color: TerminalColors.green.withOpacity(0.8),
            ),
          ),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                trailing,
                style: TerminalTextStyles.body.copyWith(
                  fontSize: 14,
                  color: trailingColor ?? TerminalColors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getToolIcon(String tool) {
    switch (tool) {
      case 'EMF':
        return Icons.wifi;
      case 'SpiritBox':
        return Icons.radio;
      case 'UV':
        return Icons.lightbulb;
      case 'Mic':
        return Icons.mic;
      case 'Camera':
        return Icons.camera_alt;
      default:
        return Icons.extension;
    }
  }
}
