import 'package:facebook_flutter_sdk/facebook_flutter_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Meta (Facebook) App Events service for ad campaign tracking.
///
/// Singleton service following the same pattern as [TikTokService] /
/// [PostHogService]. All calls are wrapped in try/catch to ensure non-blocking
/// behavior — analytics failures must never break the app.
///
/// ## ATT (App Tracking Transparency) on iOS
///
/// iOS 14.5+ requires ATT consent before collecting the IDFA. Without consent,
/// Meta still receives events through AEM (Aggregated Event Measurement) but
/// with delayed (24–72h) and aggregated data, plus SKAdNetwork postbacks.
///
/// Default behavior: advertiser tracking is **disabled** at init, mirroring
/// the existing TikTok service. Call [requestTracking] from your onboarding
/// flow (before any purchase) if you want to prompt the user and unlock
/// deterministic attribution.
class MetaService {
  static final MetaService instance = MetaService._internal();
  MetaService._internal();

  final FacebookAppEvents _events = FacebookAppEvents();
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Initialize the Meta App Events SDK.
  ///
  /// App ID and client token are read by the native SDK from
  /// `AndroidManifest.xml` (Android) and `Info.plist` (iOS).
  ///
  /// [enableAdvertiserTracking] should stay `false` until the user has
  /// granted ATT (see [requestTracking]).
  Future<void> init({
    bool enableDebug = false,
    bool enableAdvertiserTracking = false,
  }) async {
    if (_initialized) return;
    try {
      if (enableDebug) {
        await _events.setDebugEnabled(true);
      }
      await _events.setAdvertiserTracking(
        enabled: enableAdvertiserTracking,
        collectId: enableAdvertiserTracking,
      );
      _initialized = true;
      debugPrint('Meta App Events SDK initialized');
    } catch (e) {
      debugPrint('Meta App Events SDK initialization failed: $e');
    }
  }

  /// Request iOS App Tracking Transparency consent and update Meta's
  /// advertiser tracking flag accordingly. Returns `true` if granted.
  ///
  /// Call this during onboarding, before any purchase flow, so early events
  /// are sent with the correct authorization status.
  Future<bool> requestTracking() async {
    try {
      final status = await Permission.appTrackingTransparency.request();
      final granted = status.isGranted;
      await _events.setAdvertiserTracking(
        enabled: granted,
        collectId: granted,
      );
      debugPrint('Meta ATT status: ${granted ? "granted" : "denied"}');
      return granted;
    } catch (e) {
      debugPrint('Meta ATT request failed: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Generic event
  // ---------------------------------------------------------------------------

  Future<void> trackEvent(
    String name, {
    Map<String, dynamic>? parameters,
    double? valueToSum,
  }) async {
    if (!_initialized) return;
    try {
      await _events.logEvent(
        name: name,
        parameters: parameters,
        valueToSum: valueToSum,
      );
      if (kDebugMode) debugPrint('Meta event: $name');
    } catch (e) {
      debugPrint('Meta event tracking failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Standard events for FaithLock
  // ---------------------------------------------------------------------------

  Future<void> trackCompleteRegistration({String? method}) async {
    if (!_initialized) return;
    try {
      await _events.logCompletedRegistration(registrationMethod: method);
    } catch (e) {
      debugPrint('Meta CompleteRegistration failed: $e');
    }
  }

  /// Free trial start. [orderId] should be unique (RevenueCat transaction id)
  /// so the same event can be deduplicated against the Conversions API.
  Future<void> trackStartTrial({
    required String orderId,
    double? price,
    String? currency,
    String? eventId,
  }) async {
    if (!_initialized) return;
    try {
      await _events.logStartTrial(
        price: price,
        currency: currency,
        orderId: orderId,
        eventId: eventId ?? orderId,
      );
    } catch (e) {
      debugPrint('Meta StartTrial failed: $e');
    }
  }

  /// Recurring/initial subscription start.
  Future<void> trackSubscribe({
    required String orderId,
    double? price,
    String? currency,
    String? eventId,
  }) async {
    if (!_initialized) return;
    try {
      await _events.logSubscribe(
        price: price,
        currency: currency,
        orderId: orderId,
        eventId: eventId ?? orderId,
      );
    } catch (e) {
      debugPrint('Meta Subscribe failed: $e');
    }
  }

  /// One-shot purchase. [eventId] is critical for server-side deduplication
  /// when also sending the same purchase via Conversions API.
  Future<void> trackPurchase({
    required double amount,
    required String currency,
    String? eventId,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_initialized) return;
    try {
      await _events.logPurchase(
        amount: amount,
        currency: currency,
        eventId: eventId,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Meta Purchase failed: $e');
    }
  }

  Future<void> trackAddToCart({
    required String id,
    required String type,
    required double price,
    required String currency,
  }) async {
    if (!_initialized) return;
    try {
      await _events.logAddToCart(
        id: id,
        type: type,
        price: price,
        currency: currency,
      );
    } catch (e) {
      debugPrint('Meta AddToCart failed: $e');
    }
  }

  Future<void> trackViewContent({
    String? id,
    String? type,
    double? price,
    String? currency,
  }) async {
    if (!_initialized) return;
    try {
      await _events.logViewContent(
        id: id,
        type: type,
        price: price,
        currency: currency,
      );
    } catch (e) {
      debugPrint('Meta ViewContent failed: $e');
    }
  }

  Future<void> trackInitiatedCheckout({
    double? totalPrice,
    String? currency,
    String? contentId,
    String? contentType,
    int? numItems,
    bool paymentInfoAvailable = false,
  }) async {
    if (!_initialized) return;
    try {
      await _events.logInitiatedCheckout(
        totalPrice: totalPrice,
        currency: currency,
        contentId: contentId,
        contentType: contentType,
        numItems: numItems,
        paymentInfoAvailable: paymentInfoAvailable,
      );
    } catch (e) {
      debugPrint('Meta InitiatedCheckout failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Identity / advanced matching
  // ---------------------------------------------------------------------------

  /// Set advanced-matching user data. Meta hashes these natively before
  /// sending — passing raw values is the documented behavior.
  Future<void> identify({
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? userId,
  }) async {
    if (!_initialized) return;
    try {
      await _events.setUserData(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        city: city,
        state: state,
        zip: zip,
        country: country,
      );
      if (userId != null) {
        await _events.setUserID(userId);
      }
    } catch (e) {
      debugPrint('Meta identify failed: $e');
    }
  }

  Future<void> logout() async {
    if (!_initialized) return;
    try {
      await _events.clearUserData();
      await _events.clearUserID();
    } catch (e) {
      debugPrint('Meta logout failed: $e');
    }
  }

  /// Force-flush queued events. Useful right after a critical conversion.
  Future<void> flush() async {
    if (!_initialized) return;
    try {
      await _events.flush();
    } catch (e) {
      debugPrint('Meta flush failed: $e');
    }
  }
}
