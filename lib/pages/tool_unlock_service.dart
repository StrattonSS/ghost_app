import 'package:shared_preferences/shared_preferences.dart';

class ToolUnlockService {
  static final ToolUnlockService instance = ToolUnlockService._internal();

  ToolUnlockService._internal();

  /// Logs an instance of evidence for the given type and optionally tool/location.
  /// This increments a usage counter and sets a flag to allow coin claiming.
  Future<void> logEvidence(
    String evidenceType, {
    String? toolName,
    String? locationName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Construct keys
    final key = toolName != null
        ? 'evidence_${toolName}_$evidenceType'
        : 'evidence_$evidenceType';

    final coinKey = key.replaceFirst('evidence', 'coins');

    // Increment evidence count
    final count = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, count + 1);

    // Set coin earned flag
    await prefs.setBool(coinKey, true);

    // Debug output
    print(
      'Logged evidence: $key${locationName != null ? ' @ $locationName' : ''}',
    );
  }
}
