import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
        title:
            const Text('>> JOURNAL_LOG.TXT', style: TerminalTextStyles.heading),
        bottom: TabBar(
          controller: _tabController,
          labelColor: TerminalColors.green,
          unselectedLabelColor: TerminalColors.text,
          indicatorColor: TerminalColors.green,
          labelStyle: TerminalTextStyles.body,
          tabs: const [
            Tab(text: 'Favorites'),
            Tab(text: 'Visited'),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => TabBarView(
            controller: _tabController,
            children: [
              _buildResponsiveTab(_buildFavoritesTab()),
              _buildResponsiveTab(_buildVisitedTab()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveTab(Widget content) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: content,
          ),
        );
      },
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

    return Column(
      children: favorites.map((location) {
        return _terminalCard(
          title: location['name'],
          subtitle: '${location['city']}, ${location['state']}',
          trailing: '[★ FAVORITED]',
        );
      }).toList(),
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

    return Column(
      children: visited.map((location) {
        final tools = Map<String, dynamic>.from(location['toolsUsed'] ?? {});

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
              style: TerminalTextStyles.heading,
            ),
            subtitle: Text(
              '${location['city']}, ${location['state']}',
              style: TerminalTextStyles.body,
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
                        style: TerminalTextStyles.body,
                      ),
                    ],
                  );
                }).toList(),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _terminalCard({
    required String title,
    required String subtitle,
    String? trailing,
  }) {
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
          Text('> $title', style: TerminalTextStyles.heading),
          const SizedBox(height: 4),
          Text(subtitle, style: TerminalTextStyles.body),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(trailing, style: TerminalTextStyles.body),
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
