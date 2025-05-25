import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      // Replace this with the actual user ID in your app
      final userId = 'testUser123';

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '>> JOURNAL_LOG.TXT',
          style: TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF00FF00),
          unselectedLabelColor: Colors.greenAccent,
          indicatorColor: Color(0xFF00FF00),
          labelStyle: const TextStyle(fontFamily: 'Courier'),
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
          style: TextStyle(color: Color(0xFF00FF00), fontFamily: 'Courier'),
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
          trailingColor: Colors.redAccent,
        );
      },
    );
  }

  Widget _buildVisitedTab() {
    if (visited.isEmpty) {
      return const Center(
        child: Text(
          '>> No visited locations found.',
          style: TextStyle(color: Color(0xFF00FF00), fontFamily: 'Courier'),
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
            border: Border.all(color: Color(0xFF00FF00)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExpansionTile(
            backgroundColor: Colors.transparent,
            iconColor: Color(0xFF00FF00),
            collapsedIconColor: Color(0xFF00FF00),
            textColor: Color(0xFF00FF00),
            collapsedTextColor: Color(0xFF00FF00),
            title: Text(
              '> ${location['name']}',
              style: const TextStyle(
                color: Color(0xFF00FF00),
                fontFamily: 'Courier',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${location['city']}, ${location['state']}',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontFamily: 'Courier',
                fontSize: 14,
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
                        color: entry.value ? Color(0xFF00FF00) : Colors.grey,
                        size: 28,
                      ),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontFamily: 'Courier',
                        ),
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

  Widget _terminalCard(
      {required String title,
      required String subtitle,
      String? trailing,
      Color? trailingColor}) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF00FF00)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '> $title',
            style: const TextStyle(
              color: Color(0xFF00FF00),
              fontFamily: 'Courier',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontFamily: 'Courier',
              fontSize: 14,
            ),
          ),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                trailing,
                style: TextStyle(
                  color: trailingColor ?? Colors.greenAccent,
                  fontFamily: 'Courier',
                  fontSize: 14,
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
