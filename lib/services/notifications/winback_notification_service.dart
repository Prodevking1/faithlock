import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/services/notifications/local_notification_service.dart';
import 'package:faithlock/services/storage/preferences_service.dart';
import 'package:flutter/material.dart';

/// Win-back notification service — 5 high-quality notifications then silence.
///
/// Notification IDs: 200-204 (avoiding 100-124 used by UnlockTimerService)
///
/// Sequence:
/// - +2h:   The Gift (pure value, no ask)
/// - +24h:  The Mirror (identity + aspiration)
/// - +3d:   The Offer (50% off, 48h urgency)
/// - +5d:   The Story (testimonial + emotion)
/// - +7d:   The Goodbye (reverse psychology, final)
///
/// After notification 5, the sequence stops permanently.
/// Respecting the user = they keep notifications enabled for the app.
class WinBackNotificationService {
  static final WinBackNotificationService _instance =
      WinBackNotificationService._internal();
  factory WinBackNotificationService() => _instance;
  WinBackNotificationService._internal();

  final LocalNotificationService _notifications = LocalNotificationService();
  final PreferencesService _prefs = PreferencesService();
  final PostHogService _analytics = PostHogService.instance;

  // Notification IDs (200-204)
  static const int _baseNotificationId = 200;
  static const int _notificationCount = 5;

  // Preferences keys
  static const String _keyStartedAt = 'winback_started_at';
  static const String _keyActive = 'winback_active';
  static const String _keyCompleted = 'winback_completed';
  static const String _keySource = 'winback_source';
  static const String _keyPromoEligible = 'winback_promo_eligible';
  static const String _keyPromoSetAt = 'winback_promo_set_at';

  // Payload prefix for tap handling
  static const String payloadPrefix = 'winback';

  // The offer notification index (notification #3 = index 2)
  static const int offerNotificationIndex = 2;

  /// The 5-notification sequence
  static const List<_WinBackNotification> _sequence = [
    // +2h — The Gift: pure value, zero ask
    _WinBackNotification(
      index: 0,
      delay: Duration(hours: 2),
      title: 'A verse for your evening',
      body:
          '"The LORD himself goes before you and will be with you; he will never leave you." — Deuteronomy 31:8. No subscription needed for this one.',
      strategy: 'gift',
    ),

    // +24h — The Mirror: identity + aspiration
    _WinBackNotification(
      index: 1,
      delay: Duration(hours: 24),
      title: 'You installed FaithLock for a reason',
      body:
          'Something made you want to change. That desire? It\'s still there. Don\'t let it fade quietly.',
      strategy: 'mirror',
    ),

    // +3 days — The Offer: free week, zero risk
    _WinBackNotification(
      index: 2,
      delay: Duration(days: 3),
      title: 'Your free week is waiting',
      body:
          'No payment, no commitment — just 7 days with Judah by your side. Tap to claim your free week before it expires.',
      strategy: 'offer',
    ),

    // +5 days — The Story: emotion + indirect proof
    _WinBackNotification(
      index: 3,
      delay: Duration(days: 5),
      title: '"I used to unlock Instagram 80 times a day"',
      body:
          'One of our users shared this. Now he reads a verse before every unlock. Small change, big transformation. Your story could be next.',
      strategy: 'story',
    ),

    // +7 days — The Goodbye: reverse psychology + respect
    _WinBackNotification(
      index: 4,
      delay: Duration(days: 7),
      title: 'This is our last message',
      body:
          'We respect your decision. If you ever want Judah back as your guardian, we\'ll be here. No more notifications from us. Take care.',
      strategy: 'goodbye',
    ),
  ];

  /// Schedule the full 5-notification win-back sequence.
  ///
  /// [source] identifies where the trigger came from:
  /// - `paywall_closed`: user dismissed the paywall
  /// - `subscription_expired`: subscription/trial ended
  /// - `expired_screen`: shown the expired screen
  Future<void> scheduleWinBackSequence({required String source}) async {
    try {
      // Don't schedule if already completed (respect the "goodbye")
      final alreadyCompleted = await _prefs.readBool(_keyCompleted) ?? false;
      if (alreadyCompleted) {
        debugPrint('ℹ️ [WinBack] Sequence already completed — respecting silence');
        return;
      }

      // Don't re-schedule if already active
      final alreadyActive = await _prefs.readBool(_keyActive) ?? false;
      if (alreadyActive) {
        debugPrint('ℹ️ [WinBack] Sequence already active — skipping');
        return;
      }

      final now = DateTime.now();

      // Store state
      await _prefs.writeString(_keyStartedAt, now.toIso8601String());
      await _prefs.writeBool(_keyActive, true);
      await _prefs.writeString(_keySource, source);

      // Schedule all 5 notifications
      for (final notification in _sequence) {
        final scheduledDate = now.add(notification.delay);

        // Skip if the scheduled date is already in the past
        if (scheduledDate.isBefore(DateTime.now())) continue;

        await _notifications.scheduleNotification(
          id: _baseNotificationId + notification.index,
          title: notification.title,
          body: notification.body,
          scheduledDate: scheduledDate,
          payload: '${payloadPrefix}_${notification.index}',
        );

        debugPrint(
            '📅 [WinBack] Scheduled #${notification.index + 1} (${notification.strategy}) for $scheduledDate');
      }

      // Track in PostHog
      _trackEvent('winback_sequence_scheduled', {
        'source': source,
        'notification_count': _notificationCount,
      });

      debugPrint('✅ [WinBack] 5-notification sequence scheduled from $source');
    } catch (e) {
      debugPrint('❌ [WinBack] Error scheduling sequence: $e');
    }
  }

  /// Cancel all win-back notifications and clear state.
  /// Call this when the user subscribes.
  Future<void> cancelWinBackSequence({String reason = 'subscribed'}) async {
    try {
      final wasActive = await _prefs.readBool(_keyActive) ?? false;

      for (int i = 0; i < _notificationCount; i++) {
        await _notifications.cancelNotification(_baseNotificationId + i);
      }

      await _prefs.writeBool(_keyActive, false);

      if (wasActive) {
        // Calculate how many days into the sequence the user converted
        final startedAtStr = await _prefs.readString(_keyStartedAt);
        int? daysActive;
        if (startedAtStr != null) {
          daysActive = DateTime.now()
              .difference(DateTime.parse(startedAtStr))
              .inDays;
        }

        _trackEvent('winback_sequence_cancelled', {
          'reason': reason,
          'days_active': daysActive,
        });

        debugPrint('🔕 [WinBack] Sequence cancelled (reason: $reason, days: $daysActive)');
      }
    } catch (e) {
      debugPrint('❌ [WinBack] Error cancelling sequence: $e');
    }
  }

  /// Mark the sequence as completed (after the 7-day goodbye).
  /// Called on app launch to check if all notifications have been sent.
  Future<void> checkAndMarkCompleted() async {
    try {
      final isActive = await _prefs.readBool(_keyActive) ?? false;
      if (!isActive) return;

      final startedAtStr = await _prefs.readString(_keyStartedAt);
      if (startedAtStr == null) return;

      final startedAt = DateTime.parse(startedAtStr);
      final daysSinceStart = DateTime.now().difference(startedAt).inDays;

      // If 8+ days have passed, the goodbye notification was sent — mark complete
      if (daysSinceStart >= 8) {
        await _prefs.writeBool(_keyActive, false);
        await _prefs.writeBool(_keyCompleted, true);

        final source = await _prefs.readString(_keySource) ?? 'unknown';

        _trackEvent('winback_sequence_completed', {
          'source': source,
          'days_total': daysSinceStart,
          'converted': false,
        });

        debugPrint('✅ [WinBack] Sequence completed — entering silence mode');
      } else {
        debugPrint('ℹ️ [WinBack] Sequence active, day ${daysSinceStart + 1}/7');
      }
    } catch (e) {
      debugPrint('❌ [WinBack] Error checking completion: $e');
    }
  }

  /// Track when user taps a win-back notification.
  /// Called from LocalNotificationService payload handler.
  void trackNotificationTapped(int notificationIndex) {
    if (notificationIndex < 0 || notificationIndex >= _sequence.length) return;

    final notification = _sequence[notificationIndex];

    _trackEvent('winback_notification_tapped', {
      'notification_index': notificationIndex,
      'notification_strategy': notification.strategy,
      'notification_title': notification.title,
    });

    debugPrint(
        '👆 [WinBack] Notification #${notificationIndex + 1} (${notification.strategy}) tapped');
  }

  /// Check if win-back is currently active
  Future<bool> isActive() async {
    return await _prefs.readBool(_keyActive) ?? false;
  }

  /// Check if win-back sequence was already completed (in silence mode)
  Future<bool> isCompleted() async {
    return await _prefs.readBool(_keyCompleted) ?? false;
  }

  /// Mark user as eligible for win-back promo (48h window).
  /// Called when user taps notification #3 (the offer).
  Future<void> markPromoEligible() async {
    await _prefs.writeBool(_keyPromoEligible, true);
    await _prefs.writeString(_keyPromoSetAt, DateTime.now().toIso8601String());

    _trackEvent('winback_promo_eligible', {});

    debugPrint('🎁 [WinBack] User marked as promo eligible (48h window)');
  }

  /// Check if user is currently eligible for win-back promo.
  /// Returns false if promo was never set or 48h window has expired.
  Future<bool> isPromoEligible() async {
    final eligible = await _prefs.readBool(_keyPromoEligible) ?? false;
    if (!eligible) return false;

    // Check 48h expiry
    final setAtStr = await _prefs.readString(_keyPromoSetAt);
    if (setAtStr == null) return false;

    final setAt = DateTime.parse(setAtStr);
    final hoursSinceSet = DateTime.now().difference(setAt).inHours;

    if (hoursSinceSet > 48) {
      await clearPromoEligible();
      debugPrint('⏰ [WinBack] Promo expired (${hoursSinceSet}h > 48h)');
      return false;
    }

    debugPrint('✅ [WinBack] Promo still eligible (${hoursSinceSet}h / 48h)');
    return true;
  }

  /// Clear promo eligibility (after purchase or expiry)
  Future<void> clearPromoEligible() async {
    await _prefs.deleteData(_keyPromoEligible);
    await _prefs.deleteData(_keyPromoSetAt);
  }

  /// Reset the win-back state completely (for testing)
  Future<void> reset() async {
    await cancelWinBackSequence(reason: 'reset');
    await _prefs.deleteData(_keyStartedAt);
    await _prefs.deleteData(_keyActive);
    await _prefs.deleteData(_keyCompleted);
    await _prefs.deleteData(_keySource);
    await clearPromoEligible();
    debugPrint('🔄 [WinBack] State fully reset');
  }

  void _trackEvent(String eventName, Map<String, dynamic> properties) {
    try {
      if (_analytics.isReady) {
        _analytics.events.trackCustom(
          eventName,
          {
            ...properties,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      debugPrint('⚠️ [WinBack] PostHog tracking error: $e');
    }
  }
}

/// Internal model for a single win-back notification
class _WinBackNotification {
  final int index;
  final Duration delay;
  final String title;
  final String body;
  final String strategy;

  const _WinBackNotification({
    required this.index,
    required this.delay,
    required this.title,
    required this.body,
    required this.strategy,
  });
}
