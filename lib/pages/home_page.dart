import 'package:flutter/material.dart';
import 'package:ghost_app/pages/terminal_theme.dart' as terminal_theme;
import 'package:ghost_app/services/location_service.dart';
import 'package:ghost_app/widgets/location_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedState;
  String? selectedCity;
  String searchQuery = '';
  bool showActivityFilters = false;

  List<String> states = [];
  List<String> cities = [];
  List<Map<String, dynamic>> allLocations = [];
  List<Map<String, dynamic>> filteredLocations = [];

  List<String> selectedActivities = [];
  final List<String> allActivities = [
    'Apparition',
    'Cold Spot',
    'EMF Reading',
    'Voices',
    'Disembodied Sound',
    'Object Moved',
  ];

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    final fetchedStates = await LocationService.getStates();
    setState(() {
      states = fetchedStates;
    });
  }

  Future<void> _loadCities(String state) async {
    final fetchedCities = await LocationService.getCities(state);
    setState(() {
      cities = fetchedCities;
      selectedCity = null;
    });
  }

  Future<void> _loadLocations() async {
    if (selectedState != null && selectedCity != null) {
      final locations =
          await LocationService.getLocations(selectedState!, selectedCity!);
      setState(() {
        allLocations = locations;
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    final query = searchQuery.toLowerCase();

    setState(() {
      filteredLocations = allLocations.where((location) {
        final matchesSearch = location.values
            .any((value) => value.toString().toLowerCase().contains(query));

        final matchesActivity = selectedActivities.isEmpty ||
            selectedActivities.any((activity) =>
                location['activity']
                    ?.toString()
                    .toLowerCase()
                    .contains(activity.toLowerCase()) ??
                false);

        return matchesSearch && matchesActivity;
      }).toList();
    });
  }

  void _toggleActivity(String activity) {
    setState(() {
      if (selectedActivities.contains(activity)) {
        selectedActivities.remove(activity);
      } else {
        selectedActivities.add(activity);
      }
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: terminal_theme.TerminalColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔍 Search bar
              TextField(
                style: terminal_theme.TerminalTextStyles.body,
                cursorColor: terminal_theme.TerminalColors.green,
                decoration: InputDecoration(
                  hintText: 'Search haunted locations...',
                  hintStyle: terminal_theme.TerminalTextStyles.muted,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: terminal_theme.TerminalColors.green),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: terminal_theme.TerminalColors.green),
                  ),
                ),
                onChanged: (value) {
                  searchQuery = value;
                  _applyFilters();
                },
              ),
              const SizedBox(height: 12),

              // ✅ Activity Dropdown-style Filter Toggle
              GestureDetector(
                onTap: () {
                  setState(() {
                    showActivityFilters = !showActivityFilters;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: terminal_theme.TerminalColors.green),
                    borderRadius: BorderRadius.circular(6),
                    color: terminal_theme.TerminalColors.backgroundLight,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedActivities.isEmpty
                            ? 'Filter by Activity'
                            : 'Activity Filters (${selectedActivities.length})',
                        style: terminal_theme.TerminalTextStyles.body,
                      ),
                      Icon(
                        showActivityFilters
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: terminal_theme.TerminalColors.green,
                      ),
                    ],
                  ),
                ),
              ),
              if (showActivityFilters)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: allActivities.map((activity) {
                    return FilterChip(
                      label: Text(activity,
                          style: terminal_theme.TerminalTextStyles.body),
                      selected: selectedActivities.contains(activity),
                      onSelected: (_) => _toggleActivity(activity),
                      selectedColor: terminal_theme.TerminalColors.green,
                      backgroundColor:
                          terminal_theme.TerminalColors.backgroundLight,
                      checkmarkColor: Colors.black,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),

              // 🏙️ State Dropdown
              DropdownButton<String>(
                value: selectedState,
                isExpanded: true,
                dropdownColor: terminal_theme.TerminalColors.background,
                style: terminal_theme.TerminalTextStyles.body,
                hint: const Text("Select a state",
                    style: terminal_theme.TerminalTextStyles.body),
                items: states.map((String state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedState = value;
                    selectedCity = null;
                    cities = [];
                    allLocations = [];
                    filteredLocations = [];
                    selectedActivities = [];
                  });
                  _loadCities(value!);
                },
              ),
              const SizedBox(height: 10),

              // 🏙️ City Dropdown
              if (cities.isNotEmpty)
                DropdownButton<String>(
                  value: selectedCity,
                  isExpanded: true,
                  dropdownColor: terminal_theme.TerminalColors.background,
                  style: terminal_theme.TerminalTextStyles.body,
                  hint: const Text("Select a city",
                      style: terminal_theme.TerminalTextStyles.body),
                  items: cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                      selectedActivities = [];
                    });
                    _loadLocations();
                  },
                ),
              const SizedBox(height: 20),

              // 📍 Results List
              if (filteredLocations.isNotEmpty)
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredLocations.length,
                  itemBuilder: (context, index) {
                    final location = filteredLocations[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/location_detail',
                          arguments: location['id'],
                        );
                      },
                      child: LocationTile(location: location),
                    );
                  },
                )
              else if (selectedState != null && selectedCity != null)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "No haunted locations found.",
                      style: terminal_theme.TerminalTextStyles.body,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
