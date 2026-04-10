class HauntedLocation {
  final String id;
  final String name;
  final String city;
  final String state;
  final double latitude;
  final double longitude;

  const HauntedLocation({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
  });

  factory HauntedLocation.fromMap(String id, Map<String, dynamic> data) {
    final coordinates = data['coordinates'];

    return HauntedLocation(
      id: id,
      name: (data['name'] ?? '').toString(),
      city: (data['city'] ?? '').toString(),
      state: (data['state'] ?? '').toString(),
      latitude: _parseCoordinate(
        coordinates is Map ? coordinates['lat'] : null,
      ),
      longitude: _parseCoordinate(
        coordinates is Map ? coordinates['lng'] : null,
      ),
    );
  }

  static double _parseCoordinate(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'city': city,
      'state': state,
      'coordinates': {
        'lat': latitude,
        'lng': longitude,
      },
    };
  }
}