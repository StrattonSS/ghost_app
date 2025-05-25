import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'location_detail.dart';
import 'terminal_theme.dart'; // ✅ Importing shared terminal style

class Location {
  final String id;
  final String name;
  final String city;
  final String state;
  final String? imageUrl;
  final String? activity;
  final String? type;

  Location({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    this.imageUrl,
    this.activity,
    this.type,
  });

  factory Location.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Location(
      id: doc.id,
      name: data['name'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      imageUrl: data['imageUrl'],
      activity: data['activity'],
      type: data['type'],
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedState = 'Any';
  String selectedCity = 'Any';
  String selectedType = 'Any';
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  List<Location> allLocations = [];
  Set<String> states = {};
  Set<String> cities = {};
  Set<String> types = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('locations').get();
    final locations =
        snapshot.docs.map((doc) => Location.fromFirestore(doc)).toList();

    setState(() {
      allLocations = locations;
      states = locations.map((e) => e.state).toSet();
      types = locations.map((e) => e.type).whereType<String>().toSet();
      isLoading = false;
    });
  }

  List<Location> get filteredLocations {
    return allLocations.where((loc) {
      final matchesState = selectedState == 'Any' || loc.state == selectedState;
      final matchesCity = selectedCity == 'Any' || loc.city == selectedCity;
      final matchesType = selectedType == 'Any' || loc.type == selectedType;
      final matchesSearch = searchQuery.isEmpty ||
          loc.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (loc.type?.toLowerCase().contains(searchQuery.toLowerCase()) ??
              false) ||
          (loc.activity?.toLowerCase().contains(searchQuery.toLowerCase()) ??
              false);
      return matchesState && matchesCity && matchesType && matchesSearch;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      selectedState = 'Any';
      selectedCity = 'Any';
      selectedType = 'Any';
      searchQuery = '';
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final terminalText = TerminalTextStyles.body.copyWith(fontSize: 18);

    final availableCities = selectedState == 'Any'
        ? allLocations.map((loc) => loc.city).toSet().toList()
        : allLocations
            .where((loc) => loc.state == selectedState)
            .map((loc) => loc.city)
            .toSet()
            .toList();

    return Scaffold(
      backgroundColor: TerminalColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: TerminalColors.green))
            : DefaultTextStyle(
                style: terminalText,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _clearFilters,
                        child: Text("> Clear All Filters", style: terminalText),
                      ),
                    ),
                    Text("> Search:"),
                    const SizedBox(height: 6),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        border: Border.all(color: TerminalColors.green),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: searchController,
                        style: terminalText,
                        cursorColor: TerminalColors.green,
                        decoration: InputDecoration(
                          hintText: 'Type, name, or activity...',
                          hintStyle: TextStyle(
                              color: TerminalColors.green.withOpacity(0.5)),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) =>
                            setState(() => searchQuery = value),
                      ),
                    ),
                    Text("> Filter by Type:"),
                    const SizedBox(height: 6),
                    _buildDropdown(selectedType, types, (value) {
                      setState(() => selectedType = value);
                    }),
                    Text("> Select State:"),
                    const SizedBox(height: 6),
                    _buildDropdown(selectedState, states, (value) {
                      setState(() {
                        selectedState = value;
                        selectedCity = 'Any';
                      });
                    }),
                    Text("> Select City:"),
                    const SizedBox(height: 6),
                    _buildDropdown(selectedCity, availableCities.toSet(),
                        (value) {
                      setState(() => selectedCity = value);
                    }),
                    Text("> Matching Locations:"),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filteredLocations.isEmpty
                          ? const Center(
                              child: Text("> No matching results found.",
                                  style: TerminalTextStyles.body),
                            )
                          : GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                              children: filteredLocations.map((loc) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LocationDetailPage(
                                            locationId: loc.id),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: TerminalColors.green),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: loc.imageUrl != null &&
                                                  loc.imageUrl!.isNotEmpty
                                              ? Image.network(loc.imageUrl!,
                                                  fit: BoxFit.cover)
                                              : const Icon(
                                                  Icons.image_not_supported,
                                                  color: TerminalColors.green,
                                                  size: 40),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          loc.name,
                                          style: terminalText,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDropdown(
      String selectedValue, Set<String> options, Function(String) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        border: Border.all(color: TerminalColors.green),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButton<String>(
        dropdownColor: TerminalColors.background,
        isExpanded: true,
        value: selectedValue,
        underline: Container(),
        items: ['Any', ...options].map((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value,
                style: TerminalTextStyles.body.copyWith(fontSize: 18)),
          );
        }).toList(),
        onChanged: (value) => onChanged(value!),
      ),
    );
  }
}
