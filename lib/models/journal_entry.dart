class JournalEntry {
  final String locationId;
  final String locationName;
  final String tool;
  final String evidence;
  final DateTime timestamp;

  JournalEntry({
    required this.locationId,
    required this.locationName,
    required this.tool,
    required this.evidence,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() =>
      {
        'locationId': locationId,
        'locationName': locationName,
        'tool': tool,
        'evidence': evidence,
        'timestamp': timestamp.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      JournalEntry(
        locationId: json['locationId'],
        locationName: json['locationName'],
        tool: json['tool'],
        evidence: json['evidence'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}