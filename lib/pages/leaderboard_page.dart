import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'terminal_theme.dart';

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
          return const Center(
            child: CircularProgressIndicator(color: TerminalColors.green),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              ">> No leaderboard data yet.",
              style: TerminalTextStyles.body,
            ),
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

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: TerminalColors.green),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: TerminalColors.background,
                  foregroundColor: TerminalColors.green,
                  child: Text(
                    '#${index + 1}',
                    style: TerminalTextStyles.body,
                  ),
                ),
                title: Text(username, style: TerminalTextStyles.heading),
                subtitle: Text(
                  "$coins ghost coins • $entries evidence • $locations locations",
                  style: TerminalTextStyles.body,
                ),
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
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: const Text(
          ">> LEADERBOARD_SYS.TXT",
          style: TerminalTextStyles.heading,
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: TerminalColors.green,
          unselectedLabelColor: TerminalColors.text,
          indicatorColor: TerminalColors.green,
          labelStyle: TerminalTextStyles.body,
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
