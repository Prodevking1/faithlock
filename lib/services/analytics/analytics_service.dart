import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/foundation.dart';

/// A comprehensive analytics service using Amplitude.
///
/// This service provides methods to track various user events and properties,
/// helping to gather insights about user behavior and app performance.
///
/// Key features:
/// - Initialize Amplitude with API key
/// - Track events with optional properties
/// - Set user properties
/// - Log revenue events
/// - Manage user identification and logout
///
/// Usage:
/// ```dart
/// final analytics = AnalyticsService();
/// await analytics.init('YOUR_API_KEY');
/// analytics.logEvent('button_clicked', eventProperties: {'button_name': 'submit'});
/// ```
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late Amplitude _amplitude;
  bool _isInitialized = false;

  /// Initializes the Amplitude SDK with the given API key.
  Future<void> init(String apiKey) async {
    try {
      _amplitude = Amplitude.getInstance();
      await _amplitude.init(apiKey);
      _isInitialized = true;
      debugPrint('Amplitude initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Amplitude: $e');
    }
  }

  /// Logs an event with optional properties.
  void logEvent(String eventName, {Map<String, dynamic>? eventProperties}) {
    if (!_isInitialized) {
      debugPrint('Amplitude not initialized. Call init() first.');
      return;
    }
    _amplitude.logEvent(eventName, eventProperties: eventProperties);
  }

  /// Sets user properties.
  void setUserProperties(Map<String, dynamic> userProperties) {
    if (!_isInitialized) return;
    _amplitude.setUserProperties(userProperties);
  }

  /// Logs a revenue event.
  void logRevenue(double amount, {String? productId, int? quantity}) {
    if (!_isInitialized) return;
    _amplitude.logRevenue(productId ?? '', quantity ?? 0, amount);
  }

  /// Sets the user ID for the current user.
  void setUserId(String userId) {
    if (!_isInitialized) return;
    _amplitude.setUserId(userId);
  }

  /// Clears the user ID and resets the session.
  void logout() {
    if (!_isInitialized) return;
    _amplitude.setUserId(null);
    _amplitude.regenerateDeviceId();
  }

  /// Enables or disables tracking opt-out.
  void setOptOut(bool optOut) {
    if (!_isInitialized) return;
    _amplitude.setOptOut(optOut);
  }

  /// Flushes any stored events.
  Future<void> uploadEvents() async {
    if (!_isInitialized) return;
    await _amplitude.uploadEvents();
  }
}