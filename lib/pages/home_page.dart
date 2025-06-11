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
  final TextEditingController _searchController = TextEditingController();

  List<String> states = [];
  List<String> cities = [];
  List<Map<String, dynamic>> allLocations = [];
  List<Map<String, dynamic>> filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _loadStates();
    _loadAllLocations(); // Load all locations initially
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      });
      _applyFilters(); // Apply current search to new data
    }
  }

  Future<void> _loadAllLocations() async {
    final locations = await LocationService.getAllLocations();
    setState(() {
      allLocations = locations;
      filteredLocations = List.from(locations);
    });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredLocations = List.from(allLocations); // Show all if blank
      } else {
        filteredLocations = allLocations.where((location) {
          return location.entries.any((entry) {
            final value = entry.value.toString().toLowerCase();
            return value.contains(query);
          });
        }).toList();
      }
    });
  }

  void _resetFilters() async {
    setState(() {
      selectedState = null;
      selectedCity = null;
      cities = [];
      _searchController.clear();
    });

    await _loadAllLocations(); // Refresh full list
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
              Center(
                child: Image.asset(
                  'assets/images/full_logo.png',
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Use the search bar below to explore haunted locations.',
                style: terminal_theme.TerminalTextStyles.body,
              ),
              const SizedBox(height: 12),

              // ✅ Fully functional live search bar
              TextField(
                controller: _searchController,
                style: terminal_theme.TerminalTextStyles.body,
                cursorColor: terminal_theme.TerminalColors.green,
                onChanged: (_) => _applyFilters(),
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
              ),
              const SizedBox(height: 12),

              // 🗺️ State Dropdown
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
                    });
                    _loadLocations();
                  },
                ),

              const SizedBox(height: 12),

              // 🧹 Reset Filters Button
              ElevatedButton(
                onPressed: _resetFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: terminal_theme.TerminalColors.green,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Reset Filters'),
              ),

              const SizedBox(height: 20),

              // 📋 Results List
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
                          arguments: location,
                        );
                      },
                      child: LocationTile(location: location),
                    );
                  },
                )
              else
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
