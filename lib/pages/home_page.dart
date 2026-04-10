import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ghost_app/pages/terminal_theme.dart' as terminal_theme;
import 'package:ghost_app/services/location_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedState;
  String? selectedCity;
  String searchQuery = '';

  bool isLoading = true;
  String? errorMessage;

  List<String> states = [];
  List<String> cities = [];
  Map<String, List<String>> citiesByState = {};
  List<Map<String, dynamic>> allLocations = [];
  List<Map<String, dynamic>> filteredLocations = [];

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final locations = await LocationService.getAllLocations();
      final stateSet = <String>{};
      final Map<String, Set<String>> cityMap = {};

      for (final loc in locations) {
        final state = (loc['state'] ?? '').toString().trim();
        final city = (loc['city'] ?? '').toString().trim();

        if (state.isNotEmpty) {
          stateSet.add(state);
        }

        if (state.isNotEmpty && city.isNotEmpty) {
          cityMap.putIfAbsent(state, () => <String>{}).add(city);
        }
      }

      final sortedStates = stateSet.toList()..sort();
      final mappedCities = {
        for (final entry in cityMap.entries)
          entry.key: (entry.value.toList()..sort()),
      };

      setState(() {
        allLocations = locations;
        states = sortedStates;
        citiesByState = mappedCities;
        cities = [];
        isLoading = false;
      });

      filterLocations();
    } catch (_) {
      setState(() {
        errorMessage = 'Failed to load haunted locations.';
        isLoading = false;
      });
    }
  }

  void filterLocations() {
    final query = searchQuery.toLowerCase().trim();

    setState(() {
      filteredLocations = allLocations.where((loc) {
        final name = (loc['name'] ?? '').toString().toLowerCase();
        final city = (loc['city'] ?? '').toString().toLowerCase();
        final state = (loc['state'] ?? '').toString().toLowerCase();
        final description = (loc['description'] ?? '').toString().toLowerCase();
        final activity = (loc['activity'] ?? '').toString().toLowerCase();

        final matchState =
            selectedState == null || loc['state'] == selectedState;
        final matchCity =
            selectedCity == null || loc['city'] == selectedCity;

        final matchesSearch =
            query.isEmpty ||
                name.contains(query) ||
                city.contains(query) ||
                state.contains(query) ||
                description.contains(query) ||
                activity.contains(query);

        return matchState && matchCity && matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      searchQuery = value;
      filterLocations();
    });
  }

  Widget buildStyledDropdown({
    required String hint,
    required String? selected,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: terminal_theme.TerminalColors.green,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: selected != null && items.contains(selected) ? selected : null,
        hint: Text(hint, style: terminal_theme.TerminalTextStyles.body),
        dropdownColor: Colors.black,
        iconEnabledColor: terminal_theme.TerminalColors.green,
        underline: const SizedBox.shrink(),
        style: terminal_theme.TerminalTextStyles.body,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          ),
        )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildLocationTile(Map<String, dynamic> location) {
    final id = (location['id'] ?? '').toString();
    final name = (location['name'] ?? 'Unknown').toString();
    final city = (location['city'] ?? 'Unknown City').toString();
    final state = (location['state'] ?? 'Unknown State').toString();
    final description = (location['description'] ?? '').toString();

    return GestureDetector(
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
        decoration: BoxDecoration(
          border: Border.all(
            color: terminal_theme.TerminalColors.green,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.black,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: terminal_theme.TerminalTextStyles.heading,
            ),
            const SizedBox(height: 6),
            Text(
              '$city, $state',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: terminal_theme.TerminalTextStyles.body,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                description.isEmpty ? 'No description available.' : description,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: terminal_theme.TerminalTextStyles.body.copyWith(
                  color: Colors.greenAccent.shade100,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              id.isEmpty ? 'Location unavailable' : 'Tap to investigate',
              style: terminal_theme.TerminalTextStyles.body.copyWith(
                color: id.isEmpty
                    ? Colors.grey
                    : terminal_theme.TerminalColors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.greenAccent),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage!,
              style: terminal_theme.TerminalTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredLocations.isEmpty) {
      return Center(
        child: Text(
          'No matching locations found. Try clearing filters or using a broader search.',
          style: terminal_theme.TerminalTextStyles.body,
          textAlign: TextAlign.center,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
            ? 2
            : 1;

        return GridView.builder(
          itemCount: filteredLocations.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: crossAxisCount == 1 ? 2.2 : 0.95,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            return buildLocationTile(filteredLocations[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: terminal_theme.TerminalColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Haunted Locations',
                style: terminal_theme.TerminalTextStyles.heading.copyWith(
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Browse active locations, filter by region, and open a site to investigate or log findings.',
                style: terminal_theme.TerminalTextStyles.body,
              ),
              const SizedBox(height: 16),
              TextField(
                style: terminal_theme.TerminalTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Search by name, city, description, or activity...',
                  hintStyle: terminal_theme.TerminalTextStyles.body,
                  filled: true,
                  fillColor: Colors.black,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: terminal_theme.TerminalColors.green,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: terminal_theme.TerminalColors.green,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
              buildStyledDropdown(
                hint: 'Filter by state',
                selected: selectedState,
                items: states,
                onChanged: (value) {
                  setState(() {
                    selectedState = value;
                    selectedCity = null;
                    cities = selectedState != null &&
                        citiesByState.containsKey(selectedState)
                        ? citiesByState[selectedState]!
                        : [];
                  });
                  filterLocations();
                },
              ),
              buildStyledDropdown(
                hint: 'Filter by city',
                selected: selectedCity,
                items: cities,
                onChanged: (value) {
                  setState(() {
                    selectedCity = value;
                  });
                  filterLocations();
                },
              ),
              const SizedBox(height: 16),
              Expanded(child: buildContent()),
            ],
          ),
        ),
      ),
    );
  }
}