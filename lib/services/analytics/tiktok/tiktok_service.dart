import 'package:tiktok_events_sdk/tiktok_events_sdk.dart';
import 'package:flutter/foundation.dart';

/// TikTok Events SDK service for ad campaign tracking
///
/// Singleton service following the same pattern as PostHogService.
/// All calls are wrapped in try/catch to ensure non-blocking behavior.
class TikTokService {
  static final TikTokService instance = TikTokService._internal();
  TikTokService._internal();

  bool _initialized = false;

  /// Whether the SDK has been successfully initialized
  bool get isInitialized => _initialized;

  /// Initialize the TikTok Events SDK
  Future<void> init({
    required String iosAppId,
    required String tiktokIosId,
    required String androidAppId,
    required String tiktokAndroidId,
    bool enableDebug = false,
  }) async {
    if (_initialized) return;

    try {
      final iosOptions = TikTokIosOptions(
        disableTracking: false,
        disableAutomaticTracking: false,
        disableSKAdNetworkSupport: false,
      );

      final androidOptions = TikTokAndroidOptions(
        disableAutoStart: false,
        enableAutoIapTrack: true,
        disableAdvertiserIDCollection: false,
      );

      await TikTokEventsSdk.initSdk(
        androidAppId: androidAppId,
        tikTokAndroidId: tiktokAndroidId,
        iosAppId: iosAppId,
        tiktokIosId: tiktokIosId,
        isDebugMode: enableDebug,
        logLevel: enableDebug ? TikTokLogLevel.debug : TikTokLogLevel.none,
        androidOptions: androidOptions,
        iosOptions: iosOptions,
      );

      _initialized = true;
      debugPrint('TikTok Events SDK initialized');
    } catch (e) {
      debugPrint('TikTok Events SDK initialization failed: $e');
    }
  }

  /// Track a custom event with optional properties
  Future<void> trackEvent(
    String eventName, {
    String? eventId,
    Map<String, String>? properties,
  }) async {
    if (!_initialized) return;
    try {
      await TikTokEventsSdk.logEvent(
        event: TikTokEvent(
          eventName: eventName,
          eventId: eventId,
          properties: properties != null
              ? EventProperties(customProperties: properties)
              : null,
        ),
      );
      if (kDebugMode) {
        debugPrint('TikTok event: $eventName');
      }
    } catch (e) {
      debugPrint('TikTok event tracking failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Convenience methods for FaithLock events
  // ---------------------------------------------------------------------------

  /// Track user completing onboarding / registration
  Future<void> trackCompleteRegistration() =>
      trackEvent('CompleteRegistration');

  /// Track free trial start
  Future<void> trackStartTrial() => trackEvent('StartTrial');

  /// Track subscription purchase
  Future<void> trackSubscribe({double? value, String? currency}) =>
      trackEvent('Subscribe', properties: {
        if (value != null) 'value': value.toString(),
        if (currency != null) 'currency': currency,
      });

  /// Track in-app purchase
  Future<void> trackPurchase({
    double? value,
    String? currency,
    String? contentId,
  }) =>
      trackEvent('Purchase', properties: {
        if (value != null) 'value': value.toString(),
        if (currency != null) 'currency': currency,
        if (contentId != null) 'content_id': contentId,
      });

  /// Track tutorial / challenge completion
  Future<void> trackCompleteTutorial() => trackEvent('CompleteTutorial');

  /// Track content view
  Future<void> trackViewContent(String contentName) =>
      trackEvent('ViewContent', properties: {'content_name': contentName});

  // ---------------------------------------------------------------------------
  // Identity
  // ---------------------------------------------------------------------------

  /// Identify user for enhanced matching (optional)
  Future<void> identify({
    required String externalUserName,
    String externalId = '',
    String email = '',
  }) async {
    if (!_initialized) return;
    try {
      await TikTokEventsSdk.identify(
        identifier: TikTokIdentifier(
          externalUserName: externalUserName,
          externalId: externalId,
          email: email,
        ),
      );
    } catch (e) {
      debugPrint('TikTok identify failed: $e');
    }
  }

  /// Clear user identity on logout
  Future<void> logout() async {
    if (!_initialized) return;
    try {
      await TikTokEventsSdk.logout();
    } catch (e) {
      debugPrint('TikTok logout failed: $e');
    }
  }
}
