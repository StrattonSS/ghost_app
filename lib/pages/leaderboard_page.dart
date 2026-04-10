import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'terminal_theme.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Map<String, String>> _categories = const [
    {'label': 'Most Visited', 'field': 'locationsVisited'},
    {'label': 'Most Evidence', 'field': 'entriesLogged'},
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<_LeaderboardBannerState> _bannerStream() async* {
    await for (final user in _auth.authStateChanges()) {
      if (user == null) {
        yield const _LeaderboardBannerState.signedOut();
        continue;
      }

      final userDocStream =
      _firestore.collection('leaderboard').doc(user.uid).snapshots();

      await for (final doc in userDocStream) {
        final data = doc.data();

        if (data == null) {
          yield const _LeaderboardBannerState.noStats();
          continue;
        }

        final visited = (data['locationsVisited'] as num?) ?? 0;
        final evidence = (data['entriesLogged'] as num?) ?? 0;

        final visitedRank = visited > 0
            ? await _computeRank(
          field: 'locationsVisited',
          value: visited,
        )
            : null;

        final evidenceRank = evidence > 0
            ? await _computeRank(
          field: 'entriesLogged',
          value: evidence,
        )
            : null;

        yield _LeaderboardBannerState.ready(
          visitedCount: visited.toInt(),
          visitedRank: visitedRank,
          evidenceCount: evidence.toInt(),
          evidenceRank: evidenceRank,
          email: user.email,
        );
      }
    }
  }

  Future<int?> _computeRank({
    required String field,
    required num value,
  }) async {
    if (value <= 0) return null;

    final snapshot = await _firestore
        .collection('leaderboard')
        .where(field, isGreaterThan: value)
        .count()
        .get();

    return snapshot.count + 1;
  }

  Widget _buildBanner() {
    return StreamBuilder<_LeaderboardBannerState>(
      stream: _bannerStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildBannerCard(
            title: 'Checking investigator status...',
            lines: const [
              'Authenticating session and retrieving leaderboard data.',
            ],
          );
        }

        final state = snapshot.data ?? const _LeaderboardBannerState.signedOut();

        switch (state.type) {
          case _BannerType.signedOut:
            return _buildBannerCard(
              title: 'You are currently signed out',
              lines: const [
                'Sign in to track your leaderboard rank.',
                'If this was unexpected, your session may have expired.',
              ],
            );
          case _BannerType.noStats:
            return _buildBannerCard(
              title: 'Signed in, but no rank yet',
              lines: const [
                'Visit haunted locations and save findings to appear on the leaderboard.',
              ],
            );
          case _BannerType.ready:
            final visitedText = state.visitedRank == null
                ? 'No visited locations recorded yet.'
                : 'Rank #${state.visitedRank} for visited locations (${state.visitedCount}).';

            final evidenceText = state.evidenceRank == null
                ? 'No evidence logs recorded yet.'
                : 'Rank #${state.evidenceRank} for evidence logs (${state.evidenceCount}).';

            return _buildBannerCard(
              title: state.email == null || state.email!.isEmpty
                  ? 'Signed in'
                  : 'Signed in as ${state.email}',
              lines: [
                visitedText,
                evidenceText,
              ],
            );
        }
      },
    );
  }

  Widget _buildBannerCard({
    required String title,
    required List<String> lines,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: TerminalColors.green,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TerminalTextStyles.heading),
          const SizedBox(height: 8),
          ...lines.map(
                (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $line',
                style: TerminalTextStyles.body,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: const Text(
          '>> LEADERBOARD_SYS.TXT',
          style: TerminalTextStyles.heading,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: TerminalColors.green,
          unselectedLabelColor: TerminalColors.text,
          indicatorColor: TerminalColors.green,
          labelStyle: TerminalTextStyles.body,
          tabs: _categories.map((cat) => Tab(text: cat['label'])).toList(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildBanner(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories
                    .map(
                      (cat) => _LeaderboardTab(
                    title: cat['label']!,
                    field: cat['field']!,
                  ),
                )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTab extends StatefulWidget {
  final String title;
  final String field;

  const _LeaderboardTab({
    required this.title,
    required this.field,
  });

  @override
  State<_LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<_LeaderboardTab>
    with AutomaticKeepAliveClientMixin {
  Stream<QuerySnapshot<Map<String, dynamic>>> _leaderboardStream() {
    return FirebaseFirestore.instance
        .collection('leaderboard')
        .orderBy(widget.field, descending: true)
        .limit(25)
        .snapshots();
  }

  String _metricLabel() {
    switch (widget.field) {
      case 'locationsVisited':
        return 'visited locations';
      case 'entriesLogged':
        return 'evidence logs';
      default:
        return 'score';
    }
  }

  IconData _metricIcon() {
    switch (widget.field) {
      case 'locationsVisited':
        return Icons.location_on;
      case 'entriesLogged':
        return Icons.fact_check;
      default:
        return Icons.leaderboard;
    }
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amberAccent;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.deepOrangeAccent;
      default:
        return TerminalColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _leaderboardStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                '>> Failed to load leaderboard data.',
                style: TerminalTextStyles.body,
                textAlign: TextAlign.center,
              ),
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '>> No ${_metricLabel()} data yet.',
                style: TerminalTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final user = docs[index].data();
            final rank = index + 1;

            final username =
            (user['username'] ?? 'Unknown Investigator').toString();
            final primaryValue = (user[widget.field] ?? 0).toString();
            final locationsVisited =
            (user['locationsVisited'] ?? 0).toString();
            final entriesLogged = (user['entriesLogged'] ?? 0).toString();

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: rank <= 3 ? _rankColor(rank) : TerminalColors.green,
                  width: 1.4,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: TerminalColors.background,
                    foregroundColor:
                    rank <= 3 ? _rankColor(rank) : TerminalColors.green,
                    child: Text(
                      '#$rank',
                      style: TerminalTextStyles.body,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TerminalTextStyles.heading,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              _metricIcon(),
                              size: 18,
                              color: TerminalColors.green,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '$primaryValue ${_metricLabel()}',
                                style: TerminalTextStyles.body.copyWith(
                                  color: TerminalColors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$locationsVisited visited • $entriesLogged evidence logs',
                          style: TerminalTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

enum _BannerType {
  signedOut,
  noStats,
  ready,
}

class _LeaderboardBannerState {
  final _BannerType type;
  final int visitedCount;
  final int? visitedRank;
  final int evidenceCount;
  final int? evidenceRank;
  final String? email;

  const _LeaderboardBannerState._({
    required this.type,
    this.visitedCount = 0,
    this.visitedRank,
    this.evidenceCount = 0,
    this.evidenceRank,
    this.email,
  });

  const _LeaderboardBannerState.signedOut()
      : this._(type: _BannerType.signedOut);

  const _LeaderboardBannerState.noStats()
      : this._(type: _BannerType.noStats);

  const _LeaderboardBannerState.ready({
    required int visitedCount,
    required int? visitedRank,
    required int evidenceCount,
    required int? evidenceRank,
    String? email,
  }) : this._(
    type: _BannerType.ready,
    visitedCount: visitedCount,
    visitedRank: visitedRank,
    evidenceCount: evidenceCount,
    evidenceRank: evidenceRank,
    email: email,
  );
}