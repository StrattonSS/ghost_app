import 'package:flutter/foundation.dart';

class JournalEntry {
  final String tool;
  final String evidenceType;
  final String locationName;
  final DateTime timestamp;
  final bool coinsClaimed;
  final String title;
  final String description;
  final int coins;

  JournalEntry({
    required this.tool,
    required this.evidenceType,
    required this.locationName,
    required this.timestamp,
    required this.coinsClaimed,
    required this.title,
    required this.description,
    required this.coins,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      tool: map['tool'] ?? '',
      evidenceType: map['evidenceType'] ?? '',
      locationName: map['locationName'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      coinsClaimed: map['coinsClaimed'] ?? false,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      coins: map['coins'] ?? 0,
    );
  }

  JournalEntry copyWith({
    String? tool,
    String? evidenceType,
    String? locationName,
    DateTime? timestamp,
    bool? coinsClaimed,
    String? title,
    String? description,
    int? coins,
  }) {
    return JournalEntry(
      tool: tool ?? this.tool,
      evidenceType: evidenceType ?? this.evidenceType,
      locationName: locationName ?? this.locationName,
      timestamp: timestamp ?? this.timestamp,
      coinsClaimed: coinsClaimed ?? this.coinsClaimed,
      title: title ?? this.title,
      description: description ?? this.description,
      coins: coins ?? this.coins,
    );
  }
}

class JournalService {
  static final instance = JournalService._internal();
  final List<JournalEntry> _entries = [];

  JournalService._internal();

  List<JournalEntry> get entries => _entries;

  void claimCoins(int index) {
    if (index >= 0 && index < _entries.length) {
      final updatedEntry = _entries[index].copyWith(coinsClaimed: true);
      _entries[index] = updatedEntry;
    }
  }

  void logEntry(JournalEntry entry) {
    _entries.add(entry);
  }
}
