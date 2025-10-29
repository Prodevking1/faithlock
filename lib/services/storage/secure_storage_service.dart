import 'dart:convert';

import 'package:faithlock/config/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A service that provides secure storage functionalities.
///
/// This service encapsulates operations for securely storing and retrieving
/// various data types including strings, booleans, maps, and lists.
/// It uses Flutter's secure storage to ensure data is stored securely on the device.
///
/// Key features:
/// - Write and read operations for strings, booleans, maps, and lists
/// - Data encryption for sensitive information
/// - Error handling and logging for all operations
/// - Methods to check for existing keys and delete data
///
/// Usage:
/// ```dart
/// final secureStorage = SecureStorageService();
/// await secureStorage.writeString('user_token', 'abc123');
/// final token = await secureStorage.readString('user_token');
/// ```
class StorageService {
  final FlutterSecureStorage _storage;

  /// Creates a [StorageService] with an optional [FlutterSecureStorage] instance.
  StorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Writes a [String] value to secure storage.
  Future<void> writeString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e, stackTrace) {
      logger.error('Error writing string to secure storage', e, stackTrace);
      rethrow;
    }
  }

  /// Writes a [bool] value to secure storage.
  Future<void> writeBool(String key, bool value) async {
    await writeString(key, value.toString());
  }

  /// Writes a [int] value to secure storage.
  Future<void> writeInt(String key, int value) async {
    await writeString(key, value.toString());
  }

  /// Writes a [Map] to secure storage by encoding it to JSON.
  Future<void> writeMap(String key, Map<String, dynamic> value) async {
    await writeString(key, jsonEncode(value));
  }

  /// Writes a [List] to secure storage by encoding it to JSON.
  Future<void> writeList(String key, List<dynamic> value) async {
    await writeString(key, jsonEncode(value));
  }

  /// Reads a [String] value from secure storage.
  Future<String?> readString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e, stackTrace) {
      logger.error('Error reading string from secure storage', e, stackTrace);
      rethrow;
    }
  }

  /// Reads a [bool] value from secure storage.
  Future<bool?> readBool(String key) async {
    final value = await readString(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /// Reads an [int] value from secure storage.
  Future<int?> readInt(String key) async {
    final value = await readString(key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// Reads a [Map] from secure storage by decoding the JSON string.
  Future<Map<String, dynamic>?> readMap(String key) async {
    final value = await readString(key);
    if (value == null) return null;
    return jsonDecode(value) as Map<String, dynamic>;
  }

  /// Reads a [List] from secure storage by decoding the JSON string.
  Future<List<dynamic>?> readList(String key) async {
    final value = await readString(key);
    if (value == null) return null;
    return jsonDecode(value) as List<dynamic>;
  }

  /// Deletes data associated with the given [key] from secure storage.
  Future<void> deleteData(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, stackTrace) {
      logger.error('Error deleting data from secure storage', e, stackTrace);
      rethrow;
    }
  }

  /// Checks if the given [key] exists in secure storage.
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e, stackTrace) {
      logger.error('Error checking key in secure storage', e, stackTrace);
      rethrow;
    }
  }

  /// Deletes all data from secure storage.
  Future<void> deleteAllData() async {
    try {
      await _storage.deleteAll();
    } catch (e, stackTrace) {
      logger.error(
          'Error deleting all data from secure storage', e, stackTrace);
      rethrow;
    }
  }
}
