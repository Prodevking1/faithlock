import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/services/notifications/local_notification_service.dart';
import 'package:faithlock/services/storage/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Win-back notification service — 5 strategy notifications then silence.
///
/// Notification IDs: 200-204
///
/// Sequence:
/// - +24h:  The Offer (free week)
/// - +48h:  The Offer Reminder (second chance)
/// - +3d:   The Mirror (identity + aspiration)
/// - +5d:   The Story (testimonial + emotion)
/// - +7d:   The Goodbye (offer still active, final)
///
/// Daily Bible verses continue independently via DailyVerseNotificationService
/// at the user's configured times (1-3x/day from onboarding).
///
/// After the goodbye, the sequence stops permanently.
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

  // The offer notification indices (index 0 = +24h, index 1 = +48h reminder)
  static const int offerNotificationIndex = 0;
  static const int offerReminderNotificationIndex = 1;

  /// Build the 5-notification win-back strategy sequence.
  /// Resolves .tr at call time so translations are always current.
  static List<_WinBackNotification> _buildSequence() => [
    // +24h — The Offer: free week
    _WinBackNotification(
      index: 0,
      delay: Duration(hours: 24),
      titleKey: 'winback_title2',
      bodyKey: 'winback_body2',
      strategy: 'offer',
    ),

    // +48h — The Offer Reminder: verse + gentle nudge
    _WinBackNotification(
      index: 1,
      delay: Duration(hours: 48),
      titleKey: 'winback_title1',
      bodyKey: 'winback_body1',
      strategy: 'offer_reminder',
    ),

    // +3 days — The Mirror: identity + aspiration
    _WinBackNotification(
      index: 2,
      delay: Duration(days: 3),
      titleKey: 'winback_title3',
      bodyKey: 'winback_body3',
      strategy: 'mirror',
    ),

    // +5 days — The Story: emotion + indirect proof
    _WinBackNotification(
      index: 3,
      delay: Duration(days: 5),
      titleKey: 'winback_title4',
      bodyKey: 'winback_body4',
      strategy: 'story',
    ),

    // +7 days — The Goodbye: reverse psychology + respect
    _WinBackNotification(
      index: 4,
      delay: Duration(days: 7),
      titleKey: 'winback_title5',
      bodyKey: 'winback_body5',
      strategy: 'goodbye',
    ),
  ];

  /// Schedule the win-back strategy sequence.
  ///
  /// Daily Bible verses continue independently via DailyVerseNotificationService.
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
        debugPrint(
            'ℹ️ [WinBack] Sequence already completed — respecting silence');
        return;
      }

      // Don't re-schedule if already active
      final alreadyActive = await _prefs.readBool(_keyActive) ?? false;
      if (alreadyActive) {
        debugPrint('ℹ️ [WinBack] Sequence already active — skipping');
        return;
      }

      // Check notification permissions — skip scheduling if denied
      final hasPerms = await _notifications.requestPermissions();
      if (!hasPerms) {
        debugPrint(
            '⚠️ [WinBack] Notification permissions denied — skipping sequence');
        _trackEvent('winback_sequence_skipped', {
          'source': source,
          'reason': 'notification_permission_denied',
        });
        return;
      }

      final now = DateTime.now();

      // Store state
      await _prefs.writeString(_keyStartedAt, now.toIso8601String());
      await _prefs.writeBool(_keyActive, true);
      await _prefs.writeString(_keySource, source);

      // Build sequence at call time so .tr resolves with current locale
      final sequence = _buildSequence();

      // Schedule the 5 win-back strategy notifications
      for (final notification in sequence) {
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

      debugPrint(
          '✅ [WinBack] $_notificationCount strategy notifications scheduled from $source');
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

        debugPrint(
            '🔕 [WinBack] Sequence cancelled (reason: $reason, days: $daysActive)');
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
        debugPrint(
            'ℹ️ [WinBack] Sequence active, day ${daysSinceStart + 1}/7');
      }
    } catch (e) {
      debugPrint('❌ [WinBack] Error checking completion: $e');
    }
  }

  /// Track when user taps a win-back notification.
  /// Called from LocalNotificationService payload handler.
  void trackNotificationTapped(int notificationIndex) {
    final sequence = _buildSequence();
    if (notificationIndex < 0 || notificationIndex >= sequence.length) return;

    final notification = sequence[notificationIndex];

    _trackEvent('winback_notification_tapped', {
      'notification_index': notificationIndex,
      'notification_strategy': notification.strategy,
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
  /// Called when user taps the offer notification.
  Future<void> markPromoEligible() async {
    await _prefs.writeBool(_keyPromoEligible, true);
    await _prefs.writeString(
        _keyPromoSetAt, DateTime.now().toIso8601String());

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

    debugPrint(
        '✅ [WinBack] Promo still eligible (${hoursSinceSet}h / 48h)');
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
  final String titleKey;
  final String bodyKey;
  final String strategy;

  _WinBackNotification({
    required this.index,
    required this.delay,
    required this.titleKey,
    required this.bodyKey,
    required this.strategy,
  });

  /// Resolve translated title at access time
  String get title => titleKey.tr;

  /// Resolve translated body at access time
  String get body => bodyKey.tr;
}
