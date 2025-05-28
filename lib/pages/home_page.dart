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

  List<String> states = [];
  List<String> cities = [];
  Map<String, List<String>> citiesByState = {};
  List<Map<String, dynamic>> allLocations = [];
  List<Map<String, dynamic>> filteredLocations = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final locations = await LocationService.getAllLocations();
    final stateSet = <String>{};
    final Map<String, Set<String>> cityMap = {};

    for (var loc in locations) {
      final state = loc['state'] ?? '';
      final city = loc['city'] ?? '';
      if (state.isNotEmpty && city.isNotEmpty) {
        stateSet.add(state);
        cityMap.putIfAbsent(state, () => <String>{}).add(city);
      }
    }

    final sortedStates = stateSet.toList()..sort();
    final mappedCities = {
      for (var entry in cityMap.entries)
        entry.key: (entry.value.toList()..sort())
    };

    setState(() {
      allLocations = locations;
      states = ['Select a State', ...sortedStates];
      citiesByState = mappedCities;
      cities = ['Select a City'];
    });

    filterLocations();
  }

  void filterLocations() {
    setState(() {
      filteredLocations = allLocations.where((loc) {
        final query = searchQuery.toLowerCase();

        final name = (loc['name'] ?? '').toString().toLowerCase();
        final city = (loc['city'] ?? '').toString().toLowerCase();
        final state = (loc['state'] ?? '').toString().toLowerCase();
        final description = (loc['description'] ?? '').toString().toLowerCase();
        final activity = (loc['activity'] ?? '').toString().toLowerCase();

        final matchState =
            selectedState == null || loc['state'] == selectedState;
        final matchCity = selectedCity == null || loc['city'] == selectedCity;

        final matchesSearch = query.isEmpty ||
            name.contains(query) ||
            city.contains(query) ||
            state.contains(query) ||
            description.contains(query) ||
            activity.contains(query);

        return matchState && matchCity && matchesSearch;
      }).toList();
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
        border:
            Border.all(color: terminal_theme.TerminalColors.green, width: 1.5),
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
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildLocationTile(Map<String, dynamic> location) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/location_detail',
          arguments: location['id'],
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: terminal_theme.TerminalColors.green, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          color: Colors.black,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location['name'] ?? 'Unknown',
              style: terminal_theme.TerminalTextStyles.heading,
            ),
            const SizedBox(height: 4),
            Text(
              '${location['city']}, ${location['state']}',
              style: terminal_theme.TerminalTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: terminal_theme.TerminalColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              TextField(
                style: terminal_theme.TerminalTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Search by name or description...',
                  hintStyle: terminal_theme.TerminalTextStyles.body,
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: terminal_theme.TerminalColors.green,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    filterLocations();
                  });
                },
              ),
              buildStyledDropdown(
                hint: 'Select State',
                selected: selectedState,
                items: states,
                onChanged: (value) {
                  setState(() {
                    selectedState = (value == 'Select a State') ? null : value;
                    selectedCity = null;
                    cities = ['Select a City'];
                    if (selectedState != null &&
                        citiesByState.containsKey(selectedState)) {
                      cities.addAll(citiesByState[selectedState]!);
                    }
                    filterLocations();
                  });
                },
              ),
              buildStyledDropdown(
                hint: 'Select City',
                selected: selectedCity,
                items: cities,
                onChanged: (value) {
                  setState(() {
                    selectedCity = (value == 'Select a City') ? null : value;
                    filterLocations();
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredLocations.isEmpty
                    ? Center(
                        child: Text(
                          'No matching locations found.',
                          style: terminal_theme.TerminalTextStyles.body,
                        ),
                      )
                    : GridView.builder(
                        itemCount: filteredLocations.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.95,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemBuilder: (context, index) =>
                            buildLocationTile(filteredLocations[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
