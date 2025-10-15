import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../posthog_service.dart';

/// Module for user identification, profiling, and user analytics
class UserAnalyticsModule {
  final PostHogService _postHogService;
  bool _isInitialized = false;

  UserAnalyticsModule(this._postHogService);

  /// Initialize the user analytics module
  Future<void> init() async {
    try {
      _isInitialized = true;
      debugPrint('UserAnalyticsModule: Initialized successfully');
    } catch (e) {
      debugPrint('UserAnalyticsModule: Failed to initialize - $e');
      rethrow;
    }
  }

  /// Shutdown the module
  Future<void> shutdown() async {
    try {
      _isInitialized = false;
      debugPrint('UserAnalyticsModule: Shutdown successfully');
    } catch (e) {
      debugPrint('UserAnalyticsModule: Failed to shutdown - $e');
    }
  }

  /// Identify a user with unique ID and properties
  Future<void> identify({
    required String userId,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint(
          'UserAnalyticsModule: Cannot identify - module not initialized');
      return;
    }

    try {
      await Posthog().identify(
        userId: userId,
        userProperties:
            properties != null ? Map<String, Object>.from(properties) : null,
      );
      debugPrint('UserAnalyticsModule: User identified - $userId');
    } catch (e) {
      debugPrint('UserAnalyticsModule: Failed to identify user - $e');
    }
  }

  /// Update user properties
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!_isInitialized) {
      debugPrint(
          'UserAnalyticsModule: Cannot set properties - module not initialized');
      return;
    }

    try {
      // PostHog updates user properties through identify
      final currentUserId = await Posthog().getDistinctId();
      await Posthog().identify(
        userId: currentUserId,
        userProperties: Map<String, Object>.from(properties),
      );
      debugPrint('UserAnalyticsModule: User properties updated');
    } catch (e) {
      debugPrint('UserAnalyticsModule: Failed to set user properties - $e');
    }
  }

  /// Create an alias for the current user
  Future<void> alias(String alias) async {
    if (!_isInitialized) {
      debugPrint(
          'UserAnalyticsModule: Cannot create alias - module not initialized');
      return;
    }

    try {
      await Posthog().alias(alias: alias);
      debugPrint('UserAnalyticsModule: Alias created - $alias');
    } catch (e) {
      debugPrint('UserAnalyticsModule: Failed to create alias - $e');
    }
  }

  /// Reset user identity (logout)
  Future<void> reset() async {
    if (!_isInitialized) {
      debugPrint('UserAnalyticsModule: Cannot reset - module not initialized');
      return;
    }

    try {
      await Posthog().reset();
      debugPrint('UserAnalyticsModule: User identity reset');
    } catch (e) {
      debugPrint('UserAnalyticsModule: Failed to reset user - $e');
    }
  }

  /// Track user profile update
  Future<void> trackProfileUpdate(Map<String, dynamic> updates) async {
    if (!_isInitialized) {
      debugPrint(
          'UserAnalyticsModule: Cannot track profile update - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'user_profile_updated',
        properties: {
          'updates': updates,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('UserAnalyticsModule: Profile update tracked');
    } catch (e) {
      debugPrint('UserAnalyticsModule: Failed to track profile update - $e');
    }
  }

  /// Track user segment membership
  Future<void> trackSegment({
    required String segmentName,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint(
          'UserAnalyticsModule: Cannot track segment - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'user_segment_entered',
        properties: {
          'segment_name': segmentName,
          ...?properties,
        },
      );
      debugPrint('UserAnalyticsModule: User segment tracked - $segmentName');
    } catch (e) {
      debugPrint('UserAnalyticsModule: Failed to track segment - $e');
    }
  }

  /// Get current user's distinct ID
  Future<String?> getDistinctId() async {
    if (!_isInitialized) {
      debugPrint(
          'UserAnalyticsModule: Cannot get distinct ID - module not initialized');
      return null;
    }

    try {
      return await Posthog().getDistinctId();
    } catch (e) {
      debugPrint('UserAnalyticsModule: Failed to get distinct ID - $e');
      return null;
    }
  }
}
