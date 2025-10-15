import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostHogPrivacyManager {
  static const String _optOutKey = 'posthog_opt_out';
  static const String _consentKey = 'posthog_consent';
  static const String _dataRetentionKey = 'posthog_data_retention';
  static const String _anonymousIdKey = 'posthog_anonymous_id';

  static PostHogPrivacyManager? _instance;
  static PostHogPrivacyManager get instance {
    _instance ??= PostHogPrivacyManager._();
    return _instance!;
  }

  PostHogPrivacyManager._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Opt-out global management
  bool get isOptedOut {
    return _prefs?.getBool(_optOutKey) ?? false;
  }

  Future<void> setOptOut(bool optOut) async {
    await _prefs?.setBool(_optOutKey, optOut);
    if (kDebugMode) {
      debugPrint('PostHog opt-out set to: $optOut');
    }
  }

  // GDPR consent management
  ConsentStatus get consentStatus {
    final status = _prefs?.getString(_consentKey);
    return ConsentStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => ConsentStatus.pending,
    );
  }

  Future<void> setConsent(ConsentStatus status) async {
    await _prefs?.setString(_consentKey, status.name);
    if (kDebugMode) {
      debugPrint('PostHog consent status set to: ${status.name}');
    }
  }

  // Anonymisation des données sensibles
  Map<String, dynamic> sanitizeProperties(Map<String, dynamic> properties) {
    final sanitized = <String, dynamic>{};
    final sensitiveKeys = [
      'email',
      'phone',
      'password',
      'token',
      'key',
      'secret',
      'credit_card',
      'ssn',
      'passport',
    ];

    for (final entry in properties.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;

      if (sensitiveKeys.any((sensitive) => key.contains(sensitive))) {
        if (value is String && value.isNotEmpty) {
          sanitized[entry.key] = _maskSensitiveData(value);
        } else {
          sanitized[entry.key] = '[MASKED]';
        }
      } else {
        sanitized[entry.key] = value;
      }
    }

    return sanitized;
  }

  String _maskSensitiveData(String data) {
    if (data.length <= 4) return '*' * data.length;

    final visibleChars = data.length ~/ 4;
    final maskedChars = data.length - (visibleChars * 2);

    return data.substring(0, visibleChars) +
        '*' * maskedChars +
        data.substring(data.length - visibleChars);
  }

  // Data retention management
  int get dataRetentionDays {
    return _prefs?.getInt(_dataRetentionKey) ?? 365; // 1 year by default
  }

  Future<void> setDataRetentionDays(int days) async {
    await _prefs?.setInt(_dataRetentionKey, days);
  }

  // Anonymized ID for unidentified users
  String? get anonymousId {
    return _prefs?.getString(_anonymousIdKey);
  }

  Future<void> setAnonymousId(String id) async {
    await _prefs?.setString(_anonymousIdKey, id);
  }

  Future<void> clearAnonymousId() async {
    await _prefs?.remove(_anonymousIdKey);
  }

  // Event permission verification
  bool canTrackEvent(String eventName) {
    if (isOptedOut) return false;
    if (consentStatus == ConsentStatus.denied) return false;

    // Events always authorized (critical for functionality)
    final criticalEvents = [
      'app_crashed',
      'error_occurred',
      'privacy_settings_changed',
    ];

    if (criticalEvents.contains(eventName)) return true;

    return consentStatus == ConsentStatus.granted;
  }

  // Data cleanup
  Future<void> cleanupExpiredData() async {
    // This method should be called periodically
    // to clean up data according to retention rules
    if (kDebugMode) {
      debugPrint('PostHog data cleanup initiated');
    }
  }

  // Export user data (GDPR right)
  Map<String, dynamic> exportUserData() {
    return {
      'opt_out_status': isOptedOut,
      'consent_status': consentStatus.name,
      'data_retention_days': dataRetentionDays,
      'anonymous_id': anonymousId,
      'export_timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Complete user data deletion (GDPR right)
  Future<void> deleteAllUserData() async {
    await _prefs?.remove(_optOutKey);
    await _prefs?.remove(_consentKey);
    await _prefs?.remove(_dataRetentionKey);
    await _prefs?.remove(_anonymousIdKey);

    if (kDebugMode) {
      debugPrint('All PostHog user data deleted');
    }
  }
}

enum ConsentStatus {
  pending,
  granted,
  denied,
  partial,
}

// GDPR compliance validation helper
class GDPRHelper {
  static bool isEUUser() {
    // This method should determine if the user is in the EU
    // based on geolocation, IP, etc.
    return false; // Placeholder
  }

  static bool requiresConsent() {
    return isEUUser(); // Simplified for this example
  }

  static List<String> getRequiredConsentCategories() {
    return [
      'analytics',
      'marketing',
      'personalization',
      'functional',
    ];
  }
}
