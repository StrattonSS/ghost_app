class ToolUnlockService {
  static final ToolUnlockService instance = ToolUnlockService._internal();

  ToolUnlockService._internal();

  int ghostCoins = 0;

  Map<String, Map<String, dynamic>> _toolStatus = {
    'EMF Reader': {'unlocked': true},
    'UV Light': {'unlocked': false},
    'Spirit Box': {'unlocked': false},
    'Parabolic Mic': {'unlocked': false},
    'Camera': {'unlocked': true},
  };

  Map<String, Map<String, dynamic>> getToolStatus() {
    return _toolStatus;
  }

  void unlockTool(String toolName) {
    if (_toolStatus.containsKey(toolName)) {
      _toolStatus[toolName]!['unlocked'] = true;
    }
  }

  void addCoins(int amount) {
    ghostCoins += amount;
  }

  void resetCoins() {
    ghostCoins = 0;
  }
}
