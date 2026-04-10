import 'package:flutter/material.dart';
import 'package:ghost_app/services/location_service.dart';

import 'submit_location_page.dart';
import 'terminal_theme.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: TerminalColors.background,
        appBar: AppBar(
          backgroundColor: TerminalColors.background,
          title: const Text(
            '>> LOCATION_HISTORY.TXT',
            style: TerminalTextStyles.heading,
          ),
          bottom: const TabBar(
            indicatorColor: TerminalColors.green,
            labelColor: TerminalColors.green,
            unselectedLabelColor: TerminalColors.greyLight,
            tabs: [
              Tab(
                icon: Icon(Icons.history),
                text: 'Visited',
              ),
              Tab(
                icon: Icon(Icons.star_border),
                text: 'Favorites',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _VisitedLocationsTab(),
            _FavoriteLocationsTab(),
          ],
        ),
      ),
    );
  }
}

class _VisitedLocationsTab extends StatelessWidget {
  const _VisitedLocationsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: LocationService.streamVisitedLocations(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _StateMessage(
            icon: Icons.error_outline,
            title: 'Could not load history',
            body:
            'There was a problem loading your visited locations. Try again later.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: TerminalColors.green),
          );
        }

        final locations = snapshot.data ?? [];

        if (locations.isEmpty) {
          return const _VisitedEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: locations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _LocationCard(
              location: locations[index],
              trailingIcon: Icons.history,
            );
          },
        );
      },
    );
  }
}

class _FavoriteLocationsTab extends StatelessWidget {
  const _FavoriteLocationsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: LocationService.streamFavoriteLocations(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _StateMessage(
            icon: Icons.error_outline,
            title: 'Could not load favorites',
            body:
            'There was a problem loading your saved locations. Try again later.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: TerminalColors.green),
          );
        }

        final locations = snapshot.data ?? [];

        if (locations.isEmpty) {
          return const _FavoritesEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: locations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _LocationCard(
              location: locations[index],
              trailingIcon: Icons.favorite,
            );
          },
        );
      },
    );
  }
}

class _LocationCard extends StatelessWidget {
  final Map<String, dynamic> location;
  final IconData trailingIcon;

  const _LocationCard({
    required this.location,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final id = (location['id'] ?? '').toString();
    final name = (location['name'] ?? 'Unknown Location').toString();
    final city = (location['city'] ?? 'Unknown City').toString();
    final state = (location['state'] ?? 'Unknown State').toString();
    final activity = (location['activity'] ?? '').toString();
    final type = (location['type'] ?? '').toString();
    final description = (location['description'] ?? '').toString();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: id.isEmpty
          ? null
          : () {
        Navigator.pushNamed(
          context,
          '/location_detail',
          arguments: id,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TerminalColors.green, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              trailingIcon,
              color: TerminalColors.green,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TerminalTextStyles.heading,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$city, $state',
                    style: TerminalTextStyles.body,
                  ),
                  if (type.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Type: $type',
                      style: TerminalTextStyles.muted,
                    ),
                  ],
                  if (activity.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Activity: $activity',
                      style: TerminalTextStyles.muted,
                    ),
                  ],
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TerminalTextStyles.body,
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Text(
                    'Tap to open location details',
                    style: TerminalTextStyles.muted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitedEmptyState extends StatelessWidget {
  const _VisitedEmptyState();

  @override
  Widget build(BuildContext context) {
    return const _StateMessage(
      icon: Icons.history,
      title: 'No visited locations yet',
      body:
      'Locations you open and investigate will appear here so you can quickly revisit them later.',
    );
  }
}

class _FavoritesEmptyState extends StatelessWidget {
  const _FavoritesEmptyState();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_border,
                size: 52,
                color: TerminalColors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'No favorite locations yet',
                textAlign: TextAlign.center,
                style: TerminalTextStyles.heading,
              ),
              const SizedBox(height: 12),
              const Text(
                'Locations you mark as favorites will appear here for quick future access.',
                textAlign: TextAlign.center,
                style: TerminalTextStyles.body,
              ),
              const SizedBox(height: 12),
              const Text(
                'Open a location and tap the favorite button to save it.',
                textAlign: TextAlign.center,
                style: TerminalTextStyles.muted,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: TerminalColors.green),
                    foregroundColor: TerminalColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SubmitLocationPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Submit a Location'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 52,
                color: TerminalColors.green,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TerminalTextStyles.heading,
              ),
              const SizedBox(height: 12),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TerminalTextStyles.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}