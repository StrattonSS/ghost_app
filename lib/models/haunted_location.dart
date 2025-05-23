class HauntedLocation {
  final String id;
  final String name;
  final String city;
  final String state;
  final double latitude;
  final double longitude;

  HauntedLocation({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
  });

  factory HauntedLocation.fromMap(String id, Map<String, dynamic> data) {
    return HauntedLocation(
      id: id,
      name: data['name'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      latitude: (data['coordinates']?['lat'] ?? 0).toDouble(),
      longitude: (data['coordinates']?['lng'] ?? 0).toDouble(),
    );
  }
}
