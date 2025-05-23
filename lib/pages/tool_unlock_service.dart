import 'package:shared_preferences/shared_preferences.dart';

class ToolUnlockService {
  static final ToolUnlockService instance = ToolUnlockService._internal();

  ToolUnlockService._internal();

  /// Unified logging method
  Future<void> logEvidence(
    String evidenceType, {
    String? toolName,
    String? locationName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Build key dynamically
    final keyParts = [
      if (toolName != null) 'evidence_${toolName}_$evidenceType',
      if (toolName == null) 'evidence_$evidenceType',
    ];

    final key = keyParts.first;
    final coinKey = key.replaceFirst('evidence', 'coins');

    int count = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, count + 1);
    await prefs.setBool(coinKey, true);

    // Optional debug print
    print('Logged evidence: $key'
        '${locationName != null ? ' @ $locationName' : ''}');
  }
}
