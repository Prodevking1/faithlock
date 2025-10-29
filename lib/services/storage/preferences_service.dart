import 'dart:convert';

import 'package:faithlock/config/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that provides persistent storage for non-sensitive data.
///
/// This service uses SharedPreferences to store data that should be
/// cleared when the app is uninstalled (unlike FlutterSecureStorage/Keychain).
///
/// Use this for:
/// - Onboarding completion flags
/// - User preferences
/// - App state that should reset on reinstall
///
/// Do NOT use this for:
/// - Authentication tokens
/// - Sensitive user data
/// - Passwords or credentials
///
/// Usage:
/// ```dart
/// final prefs = PreferencesService();
/// await prefs.writeBool('onboarding_complete', true);
/// final isComplete = await prefs.readBool('onboarding_complete');
/// ```
class PreferencesService {
  /// Writes a [String] value to shared preferences.
  Future<void> writeString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e, stackTrace) {
      logger.error('Error writing string to shared preferences', e, stackTrace);
      rethrow;
    }
  }

  /// Writes a [bool] value to shared preferences.
  Future<void> writeBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e, stackTrace) {
      logger.error('Error writing bool to shared preferences', e, stackTrace);
      rethrow;
    }
  }

  /// Writes an [int] value to shared preferences.
  Future<void> writeInt(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, value);
    } catch (e, stackTrace) {
      logger.error('Error writing int to shared preferences', e, stackTrace);
      rethrow;
    }
  }

  /// Writes a [double] value to shared preferences.
  Future<void> writeDouble(String key, double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(key, value);
    } catch (e, stackTrace) {
      logger.error('Error writing double to shared preferences', e, stackTrace);
      rethrow;
    }
  }

  /// Writes a [Map] to shared preferences by encoding it to JSON.
  Future<void> writeMap(String key, Map<String, dynamic> value) async {
    await writeString(key, jsonEncode(value));
  }

  /// Writes a [List] to shared preferences by encoding it to JSON.
  Future<void> writeList(String key, List<dynamic> value) async {
    await writeString(key, jsonEncode(value));
  }

  /// Reads a [String] value from shared preferences.
  Future<String?> readString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e, stackTrace) {
      logger.error('Error reading string from shared preferences', e, stackTrace);
      rethrow;
    }
  }

  /// Reads a [bool] value from shared preferences.
  Future<bool?> readBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (e, stackTrace) {
      logger.error('Error reading bool from shared preferences', e, stackTrace);
      rethrow;
    }
  }

  /// Reads an [int] value from shared preferences.
  Future<int?> readInt(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(key);
    } catch (e, stackTrace) {
      logger.error('Error reading int from shared preferences', e, stackTrace);
      rethrow;
    }
  }

  /// Reads a [double] value from shared preferences.
  Future<double?> readDouble(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(key);
    } catch (e, stackTrace) {
      logger.error('Error reading double from shared preferences', e, stackTrace);
      rethrow;
    }
  }

  /// Reads a [Map] from shared preferences by decoding the JSON string.
  Future<Map<String, dynamic>?> readMap(String key) async {
    final value = await readString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      logger.error('Error decoding map from shared preferences', e, stackTrace);
      return null;
    }
  }

  /// Reads a [List] from shared preferences by decoding the JSON string.
  Future<List<dynamic>?> readList(String key) async {
    final value = await readString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as List<dynamic>;
    } catch (e, stackTrace) {
      logger.error('Error decoding list from shared preferences', e, stackTrace);
      return null;
    }
  }

  /// Deletes data associated with the given [key] from shared preferences.
  Future<void> deleteData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e, stackTrace) {
      logger.error('Error deleting data from shared preferences', e, stackTrace);
      rethrow;
    }
  }

  /// Checks if the given [key] exists in shared preferences.
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    } catch (e, stackTrace) {
      logger.error('Error checking key in shared preferences', e, stackTrace);
      rethrow;
    }
  }

  /// Deletes all data from shared preferences.
  Future<void> deleteAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e, stackTrace) {
      logger.error('Error deleting all data from shared preferences', e, stackTrace);
      rethrow;
    }
  }
}
