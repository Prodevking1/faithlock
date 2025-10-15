import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../posthog_service.dart';

/// Module for A/B testing and feature flags
class FeatureFlagsModule {
  final PostHogService _postHogService;
  bool _isInitialized = false;
  Map<String, dynamic> _cachedFlags = {};
  DateTime? _lastFetchTime;
  static const Duration _cacheExpiration = Duration(minutes: 10);

  FeatureFlagsModule(this._postHogService);

  /// Initialize the feature flags module
  Future<void> init() async {
    try {
      await _fetchFeatureFlags();
      _isInitialized = true;
      debugPrint('FeatureFlagsModule: Initialized successfully');
    } catch (e) {
      debugPrint('FeatureFlagsModule: Failed to initialize - $e');
      rethrow;
    }
  }

  /// Shutdown the module
  Future<void> shutdown() async {
    try {
      _isInitialized = false;
      _cachedFlags.clear();
      debugPrint('FeatureFlagsModule: Shutdown successfully');
    } catch (e) {
      debugPrint('FeatureFlagsModule: Failed to shutdown - $e');
    }
  }

  /// Reset the module
  Future<void> reset() async {
    try {
      _cachedFlags.clear();
      _lastFetchTime = null;
      await _fetchFeatureFlags();
      debugPrint('FeatureFlagsModule: Reset successfully');
    } catch (e) {
      debugPrint('FeatureFlagsModule: Failed to reset - $e');
    }
  }

  /// Check if a feature flag is enabled
  Future<bool> isEnabled(String flagKey, {bool defaultValue = false}) async {
    if (!_isInitialized) {
      debugPrint(
          'FeatureFlagsModule: Cannot check flag - module not initialized');
      return defaultValue;
    }

    try {
      // Check cache first
      if (_shouldRefreshCache()) {
        await _fetchFeatureFlags();
      }

      final flagValue = await Posthog().isFeatureEnabled(flagKey);

      // Track flag evaluation
      await _trackFlagEvaluation(flagKey, flagValue);

      return flagValue;
    } catch (e) {
      debugPrint('FeatureFlagsModule: Failed to check flag $flagKey - $e');
      return defaultValue;
    }
  }

  /// Get feature flag value with variant support
  Future<T?> getFlagValue<T>(String flagKey, {T? defaultValue}) async {
    if (!_isInitialized) {
      debugPrint(
          'FeatureFlagsModule: Cannot get flag value - module not initialized');
      return defaultValue;
    }

    try {
      if (_shouldRefreshCache()) {
        await _fetchFeatureFlags();
      }

      final flagValue = await Posthog().getFeatureFlag(flagKey);

      // Track flag evaluation
      await _trackFlagEvaluation(flagKey, flagValue);

      if (flagValue is T) {
        return flagValue;
      }

      return defaultValue;
    } catch (e) {
      debugPrint('FeatureFlagsModule: Failed to get flag value $flagKey - $e');
      return defaultValue;
    }
  }

  /// Get all feature flags
  Future<Map<String, dynamic>> getAllFlags() async {
    if (!_isInitialized) {
      debugPrint(
          'FeatureFlagsModule: Cannot get all flags - module not initialized');
      return {};
    }

    try {
      if (_shouldRefreshCache()) {
        await _fetchFeatureFlags();
      }

      return Map.from(_cachedFlags);
    } catch (e) {
      debugPrint('FeatureFlagsModule: Failed to get all flags - $e');
      return {};
    }
  }

  /// Force refresh feature flags from server
  Future<void> refreshFlags() async {
    if (!_isInitialized) {
      debugPrint(
          'FeatureFlagsModule: Cannot refresh flags - module not initialized');
      return;
    }

    try {
      await _fetchFeatureFlags();
      debugPrint('FeatureFlagsModule: Flags refreshed successfully');
    } catch (e) {
      debugPrint('FeatureFlagsModule: Failed to refresh flags - $e');
    }
  }

  /// Track A/B test variant assignment
  Future<void> trackVariantAssignment({
    required String experimentName,
    required String variant,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint(
          'FeatureFlagsModule: Cannot track variant - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'ab_test_variant_assigned',
        properties: {
          'experiment_name': experimentName,
          'variant': variant,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );
      debugPrint(
          'FeatureFlagsModule: Variant assignment tracked - $experimentName:$variant');
    } catch (e) {
      debugPrint('FeatureFlagsModule: Failed to track variant assignment - $e');
    }
  }

  /// Track feature flag usage
  Future<void> trackFlagUsage({
    required String flagKey,
    required String action,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint(
          'FeatureFlagsModule: Cannot track flag usage - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'feature_flag_used',
        properties: {
          'flag_key': flagKey,
          'action': action,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );
      debugPrint('FeatureFlagsModule: Flag usage tracked - $flagKey:$action');
    } catch (e) {
      debugPrint('FeatureFlagsModule: Failed to track flag usage - $e');
    }
  }

  /// Check if flag is in multivariate test
  Future<bool> isMultivariate(String flagKey) async {
    if (!_isInitialized) {
      debugPrint(
          'FeatureFlagsModule: Cannot check multivariate - module not initialized');
      return false;
    }

    try {
      final flagValue = await Posthog().getFeatureFlag(flagKey);
      return flagValue != null && flagValue is! bool;
    } catch (e) {
      debugPrint(
          'FeatureFlagsModule: Failed to check multivariate $flagKey - $e');
      return false;
    }
  }

  /// Get cached flags (for offline use)
  Map<String, dynamic> get cachedFlags => Map.unmodifiable(_cachedFlags);

  /// Check if cache is still valid
  bool get isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheExpiration;
  }

  /// Private method to fetch feature flags
  Future<void> _fetchFeatureFlags() async {
    try {
      // PostHog SDK handles flag fetching internally
      // We just update our timestamp
      _lastFetchTime = DateTime.now();

      // Note: PostHog Flutter SDK doesn't expose a direct way to get all flags
      // so we maintain a simple cache timestamp for now
      debugPrint('FeatureFlagsModule: Flags fetch timestamp updated');
    } catch (e) {
      debugPrint('FeatureFlagsModule: Failed to fetch flags - $e');
    }
  }

  /// Check if cache should be refreshed
  bool _shouldRefreshCache() {
    return _lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!) > _cacheExpiration;
  }

  /// Track flag evaluation for analytics
  Future<void> _trackFlagEvaluation(String flagKey, dynamic value) async {
    try {
      await Posthog().capture(
        eventName: 'feature_flag_evaluated',
        properties: {
          'flag_key': flagKey,
          'flag_value': value,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail for internal tracking
      debugPrint('FeatureFlagsModule: Failed to track flag evaluation - $e');
    }
  }
}
