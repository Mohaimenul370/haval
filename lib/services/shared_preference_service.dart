import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class SharedPreferenceService {
  static late SharedPreferences _prefs;
  static bool _isInitialized = false;

  // Initialize SharedPreferences
  static Future<void> initialize() async {
    if (!_isInitialized) {
      developer.log('Initializing SharedPreferenceService...');
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      developer.log('SharedPreferenceService initialized successfully');
    }
  }

  // GAME PROGRESS METHODS
  
  // Save game progress
  static Future<bool> saveGameProgress(String gameId, int score, int totalQuestions) async {
    if (!_isInitialized) await initialize();
    
    developer.log('Saving game progress for $gameId:');
    developer.log('Score: $score out of $totalQuestions');
    
    final percentage = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0.0;
    final isCompleted = score >= (totalQuestions / 2);
    
    developer.log('Percentage: $percentage%');
    developer.log('Is completed: $isCompleted');
    
    // Save all relevant data
    await _prefs.setInt('${gameId}_score', score);
    await _prefs.setInt('${gameId}_totalQuestions', totalQuestions);
    await _prefs.setDouble('${gameId}_percentage', percentage);
    await _prefs.setBool('${gameId}_completed', isCompleted);
    
    // Commit changes to ensure they're written to disk
    final success = await commit();
    developer.log('SharedPreferenceService save for $gameId success: $success');
    return success;
  }

  // Get game score
  static int getGameScore(String gameId) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get game score before initialization');
      return 0;
    }
    final score = _prefs.getInt('${gameId}_score') ?? 0;
    developer.log('Getting game score for $gameId: $score');
    return score;
  }

  // Get total questions
  static int getTotalQuestions(String gameId) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get total questions before initialization');
      return 0;
    }
    final total = _prefs.getInt('${gameId}_totalQuestions') ?? 0;
    developer.log('Getting total questions for $gameId: $total');
    return total;
  }

  // Get game completion percentage
  static double getGamePercentage(String gameId) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get game percentage before initialization');
      return 0.0;
    }
    final percentage = _prefs.getDouble('${gameId}_percentage') ?? 0.0;
    developer.log('Getting game percentage for $gameId: $percentage%');
    return percentage;
  }

  // Check if game is completed
  static bool isGameCompleted(String gameId) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to check game completion before initialization');
      return false;
    }
    final isCompleted = _prefs.getBool('${gameId}_completed') ?? false;
    developer.log('Checking if game $gameId is completed: $isCompleted');
    return isCompleted;
  }
  
  // Get all game IDs with saved progress
  static List<String> getAllGameIds() {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get all game IDs before initialization');
      return [];
    }
    
    final Set<String> gameIds = {};
    final keyPattern = RegExp(r'(.+)_score');
    
    for (final key in _prefs.getKeys()) {
      final match = keyPattern.firstMatch(key);
      if (match != null && match.groupCount >= 1) {
        gameIds.add(match.group(1)!);
      }
    }
    
    developer.log('Found ${gameIds.length} games with saved progress: $gameIds');
    return gameIds.toList();
  }

  // GENERAL PREFERENCE METHODS

  // Save an integer value
  static Future<bool> setInt(String key, int value) async {
    if (!_isInitialized) await initialize();
    developer.log('Setting int: $key = $value');
    return await _prefs.setInt(key, value);
  }

  // Get an integer value
  static int? getInt(String key) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get int value before initialization');
      return null;
    }
    final value = _prefs.getInt(key);
    developer.log('Getting int: $key = $value');
    return value;
  }

  // Save a boolean value
  static Future<bool> setBool(String key, bool value) async {
    if (!_isInitialized) await initialize();
    developer.log('Setting bool: $key = $value');
    return await _prefs.setBool(key, value);
  }

  // Get a boolean value
  static bool? getBool(String key) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get bool value before initialization');
      return null;
    }
    final value = _prefs.getBool(key);
    developer.log('Getting bool: $key = $value');
    return value;
  }

  // Save a double value
  static Future<bool> setDouble(String key, double value) async {
    if (!_isInitialized) await initialize();
    developer.log('Setting double: $key = $value');
    return await _prefs.setDouble(key, value);
  }

  // Get a double value
  static double? getDouble(String key) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get double value before initialization');
      return null;
    }
    final value = _prefs.getDouble(key);
    developer.log('Getting double: $key = $value');
    return value;
  }

  // Save a string value
  static Future<bool> setString(String key, String value) async {
    if (!_isInitialized) await initialize();
    developer.log('Setting string: $key = $value');
    return await _prefs.setString(key, value);
  }

  // Get a string value
  static String? getString(String key) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get string value before initialization');
      return null;
    }
    final value = _prefs.getString(key);
    developer.log('Getting string: $key = $value');
    return value;
  }

  // Save a string list
  static Future<bool> setStringList(String key, List<String> value) async {
    if (!_isInitialized) await initialize();
    developer.log('Setting string list: $key = $value');
    return await _prefs.setStringList(key, value);
  }

  // Get a string list
  static List<String>? getStringList(String key) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get string list before initialization');
      return null;
    }
    final value = _prefs.getStringList(key);
    developer.log('Getting string list: $key = $value');
    return value;
  }

  // Remove a specific key
  static Future<bool> remove(String key) async {
    if (!_isInitialized) await initialize();
    developer.log('Removing key: $key');
    return await _prefs.remove(key);
  }

  // Clear all preferences
  static Future<bool> clear() async {
    if (!_isInitialized) await initialize();
    developer.log('Clearing all preferences');
    return await _prefs.clear();
  }

  // Check if key exists
  static bool containsKey(String key) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to check key before initialization');
      return false;
    }
    final contains = _prefs.containsKey(key);
    developer.log('Checking if contains key: $key = $contains');
    return contains;
  }
  
  // Get all keys
  static Set<String> getKeys() {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get keys before initialization');
      return {};
    }
    final keys = _prefs.getKeys();
    developer.log('Getting all keys: $keys');
    return keys;
  }

  // Commit changes to disk (important for some platforms)
  static Future<bool> commit() async {
    if (!_isInitialized) {
      developer.log('Warning: Trying to commit before initialization');
      return false;
    }
    developer.log('Committing changes to disk');
    return await _prefs.commit();
  }
  
  // Debug: Print all stored values
  static void debugPrintAllValues() {
    if (!_isInitialized) {
      developer.log('Warning: Trying to print debug values before initialization');
      return;
    }
    
    developer.log('=== DEBUG: All Stored Preference Values ===');
    final keys = _prefs.getKeys();
    
    if (keys.isEmpty) {
      developer.log('No values stored.');
    } else {
      for (final key in keys) {
        developer.log('$key: ${_prefs.get(key)}');
      }
    }
    
    // Print all games with completion status
    final gameIds = getAllGameIds();
    if (gameIds.isNotEmpty) {
      developer.log('=== Game Progress Summary ===');
      for (final gameId in gameIds) {
        final score = getGameScore(gameId);
        final total = getTotalQuestions(gameId);
        final percentage = getGamePercentage(gameId);
        final completed = isGameCompleted(gameId);
        
        developer.log('$gameId: $score/$total (${percentage.toStringAsFixed(1)}%) - ${completed ? "COMPLETED" : "IN PROGRESS"}');
      }
    }
    
    developer.log('=== End of Debug Values ===');
  }
} 