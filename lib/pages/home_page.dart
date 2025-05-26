import 'package:flutter/material.dart';
import 'package:ghost_app/pages/terminal_theme.dart';
import 'package:ghost_app/services/location_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedState;
  String? selectedCity;
  List<String> states = [];
  List<String> cities = [];
  List<Map<String, dynamic>> filteredLocations = [];

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
        filteredLocations = locations;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: Text('G.H.O.S.T.', style: TerminalTextStyles.heading),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<String>(
                value: selectedState,
                isExpanded: true,
                dropdownColor: TerminalColors.background,
                style: TerminalTextStyles.body,
                hint: const Text("Select a state",
                    style: TerminalTextStyles.body),
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
                    filteredLocations = [];
                  });
                  _loadCities(value!);
                },
              ),
              const SizedBox(height: 10),
              if (cities.isNotEmpty)
                DropdownButton<String>(
                  value: selectedCity,
                  isExpanded: true,
                  dropdownColor: TerminalColors.background,
                  style: TerminalTextStyles.body,
                  hint: const Text("Select a city",
                      style: TerminalTextStyles.body),
                  items: cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                      filteredLocations = [];
                    });
                    _loadLocations();
                  },
                ),
              const SizedBox(height: 20),
              if (filteredLocations.isNotEmpty)
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredLocations.length,
                  itemBuilder: (context, index) {
                    final location = filteredLocations[index];
                    return LocationTile(location: location);
                  },
                )
              else if (selectedState != null && selectedCity != null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "No haunted locations found.",
                      style: TerminalTextStyles.body,
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

class LocationTile extends StatelessWidget {
  final Map<String, dynamic> location;

  const LocationTile({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        title: Text(location['name'] ?? 'Unknown Location'),
        subtitle: Text(location['description'] ?? ''),
      ),
    );
  }
}
