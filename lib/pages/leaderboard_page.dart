import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final List<Map<String, String>> _categories = [
    {"label": "Today", "field": "coinsToday"},
    {"label": "This Week", "field": "coinsThisWeek"},
    {"label": "All Time", "field": "totalCoins"},
    {"label": "Locations", "field": "locationsVisited"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboard(String field) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('leaderboard')
        .orderBy(field, descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Widget buildLeaderboardTab(String field) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchLeaderboard(field),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No leaderboard data yet.",
                style: TextStyle(color: Colors.white70)),
          );
        }

        final leaders = snapshot.data!;

        return ListView.builder(
          itemCount: leaders.length,
          itemBuilder: (context, index) {
            final user = leaders[index];
            final username = user['username'] ?? 'Unknown';
            final coins = user['totalCoins'] ?? 0;
            final entries = user['entriesLogged'] ?? 0;
            final locations = user['locationsVisited'] ?? 0;

            return ListTile(
              leading: CircleAvatar(child: Text('#${index + 1}')),
              title: Text(
                  username, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                "$coins ghost coins • $entries evidence • $locations locations",
                style: const TextStyle(color: Colors.white70),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((cat) => Tab(text: cat["label"])).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories
            .map((cat) => buildLeaderboardTab(cat["field"]!))
            .toList(),
      ),
    );
  }
}