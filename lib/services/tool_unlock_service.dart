import 'dart:collection';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ToolUnlockService {
  ToolUnlockService._internal();

  static final ToolUnlockService instance = ToolUnlockService._internal();

  static const String _ghostCoinsKey = 'ghost_coins';
  static const String _toolStatusKey = 'tool_status';

  int _ghostCoins = 0;

  final Map<String, Map<String, dynamic>> _toolStatus = {
    'EMF Reader': {'unlocked': true},
    'UV Light': {'unlocked': false},
    'Spirit Box': {'unlocked': false},
    'Parabolic Mic': {'unlocked': false},
    'Camera': {'unlocked': true},
  };

  int get ghostCoins => _ghostCoins;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _ghostCoins = prefs.getInt(_ghostCoinsKey) ?? 0;

    final rawToolStatus = prefs.getString(_toolStatusKey);
    if (rawToolStatus == null || rawToolStatus.isEmpty) {
      await _saveToolStatus();
      return;
    }

    final decoded = jsonDecode(rawToolStatus);
    if (decoded is Map<String, dynamic>) {
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is Map) {
          _toolStatus[entry.key] = Map<String, dynamic>.from(value);
        }
      }
    }
  }

  Map<String, Map<String, dynamic>> getToolStatus() {
    return UnmodifiableMapView(
      _toolStatus.map(
            (key, value) => MapEntry(
          key,
          UnmodifiableMapView(Map<String, dynamic>.from(value)),
        ),
      ),
    );
  }

  bool isToolUnlocked(String toolName) {
    return _toolStatus[toolName]?['unlocked'] == true;
  }

  Future<void> unlockTool(String toolName) async {
    if (!_toolStatus.containsKey(toolName)) return;

    _toolStatus[toolName]!['unlocked'] = true;
    await _saveToolStatus();
  }

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;

    _ghostCoins += amount;
    await _saveGhostCoins();
  }

  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return true;
    if (_ghostCoins < amount) return false;

    _ghostCoins -= amount;
    await _saveGhostCoins();
    return true;
  }

  Future<void> resetCoins() async {
    _ghostCoins = 0;
    await _saveGhostCoins();
  }

  Future<void> resetAll() async {
    _ghostCoins = 0;

    _toolStatus
      ..clear()
      ..addAll({
        'EMF Reader': {'unlocked': true},
        'UV Light': {'unlocked': false},
        'Spirit Box': {'unlocked': false},
        'Parabolic Mic': {'unlocked': false},
        'Camera': {'unlocked': true},
      });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ghostCoinsKey);
    await prefs.remove(_toolStatusKey);
  }

  Future<void> _saveGhostCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ghostCoinsKey, _ghostCoins);
  }

  Future<void> _saveToolStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_toolStatusKey, jsonEncode(_toolStatus));
  }
}