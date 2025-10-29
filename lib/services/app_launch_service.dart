import 'package:faithlock/services/storage/secure_storage_service.dart';

/// Service to track how the app was launched
/// Distinguishes between natural app opens vs notification/deeplink opens
class AppLaunchService {
  static final AppLaunchService _instance = AppLaunchService._internal();
  factory AppLaunchService() => _instance;
  AppLaunchService._internal();

  final StorageService _storage = StorageService();

  static const String _keyLaunchSource = 'app_launch_source';
  static const String _keyLastNaturalLaunch = 'last_natural_launch';

  /// Launch sources
  static const String sourceNatural = 'natural';
  static const String sourcePrayerNotification = 'prayer_notification';
  static const String sourceRelockNotification = 'relock_notification';
  static const String sourceDeeplink = 'deeplink';

  /// Set launch source when app opens
  Future<void> setLaunchSource(String source) async {
    await _storage.writeString(_keyLaunchSource, source);

    // Track natural launches separately
    if (source == sourceNatural) {
      await _storage.writeString(
        _keyLastNaturalLaunch,
        DateTime.now().toIso8601String(),
      );
    }
  }

  /// Get current launch source
  Future<String> getLaunchSource() async {
    return await _storage.readString(_keyLaunchSource) ?? sourceNatural;
  }

  /// Check if current launch is natural (user opened app directly)
  Future<bool> isNaturalLaunch() async {
    final source = await getLaunchSource();
    return source == sourceNatural;
  }

  /// Clear launch source (call after handling)
  Future<void> clearLaunchSource() async {
    await _storage.deleteData(_keyLaunchSource);
  }

  /// Get time of last natural launch
  Future<DateTime?> getLastNaturalLaunch() async {
    final timeStr = await _storage.readString(_keyLastNaturalLaunch);
    if (timeStr == null) return null;

    try {
      return DateTime.parse(timeStr);
    } catch (e) {
      return null;
    }
  }
}
