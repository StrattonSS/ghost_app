import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToolUnlockService {
  ToolUnlockService._internal();

  static final ToolUnlockService instance = ToolUnlockService._internal();

  Future<void> logEvidence(
      String evidenceType, {
        String? toolName,
        String? locationName,
      }) async {
    final prefs = await SharedPreferences.getInstance();

    final normalizedEvidenceType = _normalizeKeyPart(evidenceType);
    final normalizedToolName =
    toolName == null ? null : _normalizeKeyPart(toolName);

    final evidenceKey = normalizedToolName != null
        ? 'evidence_${normalizedToolName}_$normalizedEvidenceType'
        : 'evidence_$normalizedEvidenceType';

    final coinKey = normalizedToolName != null
        ? 'coins_${normalizedToolName}_$normalizedEvidenceType'
        : 'coins_$normalizedEvidenceType';

    final count = prefs.getInt(evidenceKey) ?? 0;
    await prefs.setInt(evidenceKey, count + 1);
    await prefs.setBool(coinKey, true);

    if (kDebugMode) {
      debugPrint(
        'Logged evidence: $evidenceKey'
            '${locationName != null ? ' @ $locationName' : ''}',
      );
    }
  }

  Future<int> getEvidenceCount(
      String evidenceType, {
        String? toolName,
      }) async {
    final prefs = await SharedPreferences.getInstance();

    final normalizedEvidenceType = _normalizeKeyPart(evidenceType);
    final normalizedToolName =
    toolName == null ? null : _normalizeKeyPart(toolName);

    final evidenceKey = normalizedToolName != null
        ? 'evidence_${normalizedToolName}_$normalizedEvidenceType'
        : 'evidence_$normalizedEvidenceType';

    return prefs.getInt(evidenceKey) ?? 0;
  }

  Future<bool> canClaimCoins(
      String evidenceType, {
        String? toolName,
      }) async {
    final prefs = await SharedPreferences.getInstance();

    final normalizedEvidenceType = _normalizeKeyPart(evidenceType);
    final normalizedToolName =
    toolName == null ? null : _normalizeKeyPart(toolName);

    final coinKey = normalizedToolName != null
        ? 'coins_${normalizedToolName}_$normalizedEvidenceType'
        : 'coins_$normalizedEvidenceType';

    return prefs.getBool(coinKey) ?? false;
  }

  Future<void> markCoinsClaimed(
      String evidenceType, {
        String? toolName,
      }) async {
    final prefs = await SharedPreferences.getInstance();

    final normalizedEvidenceType = _normalizeKeyPart(evidenceType);
    final normalizedToolName =
    toolName == null ? null : _normalizeKeyPart(toolName);

    final coinKey = normalizedToolName != null
        ? 'coins_${normalizedToolName}_$normalizedEvidenceType'
        : 'coins_$normalizedEvidenceType';

    await prefs.setBool(coinKey, false);
  }

  String _normalizeKeyPart(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }
}