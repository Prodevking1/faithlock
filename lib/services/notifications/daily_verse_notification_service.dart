import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/faithlock/services/verse_service.dart';
import 'package:faithlock/services/notifications/local_notification_service.dart';
import 'package:faithlock/services/storage/preferences_service.dart';
import 'package:flutter/material.dart';

/// Daily verse notification service — sends one verse per day.
///
/// Notification IDs: 300-306 (7 days scheduled ahead)
///
/// Strategy:
/// - Sequential through ~280 curriculum verses (no repeats until all seen)
/// - Schedules 7 days of verses in advance
/// - Reschedules on each app launch to keep content fresh
/// - Default time: 8:00 AM local (configurable)
///
/// Payload format: `daily_verse_{verseId}` for deep linking to verse library.
class DailyVerseNotificationService {
  static final DailyVerseNotificationService _instance =
      DailyVerseNotificationService._internal();
  factory DailyVerseNotificationService() => _instance;
  DailyVerseNotificationService._internal();

  final LocalNotificationService _notifications = LocalNotificationService();
  final PreferencesService _prefs = PreferencesService();
  final VerseService _verseService = VerseService();

  // Notification IDs per time slot (10-ID gap between slots)
  // Slot 0 (morning): 300-306, Slot 1 (afternoon): 310-316, Slot 2 (evening): 320-326
  static const int _baseNotificationId = 300;
  static const int _slotIdGap = 10;
  static const int _maxTimeSlots = 3;
  static const int _scheduleDays = 7;

  // Preferences keys
  static const String _keyEnabled = 'daily_verse_enabled';
  static const String _keyCurrentIndex = 'daily_verse_index';
  static const String _keyHour = 'daily_verse_hour';
  static const String _keyMinute = 'daily_verse_minute';
  static const String _keyLastScheduledDate = 'daily_verse_last_scheduled';
  // Multi-time keys (V2 onboarding)
  static const String _keyFrequency = 'daily_verse_frequency';
  static const String _keyTimes = 'daily_verse_times';

  // Payload prefix for tap handling
  static const String payloadPrefix = 'daily_verse';

  // Cached verse list (loaded once per session)
  List<BibleVerse>? _cachedVerses;

  /// Enable daily verse notifications and schedule the first batch.
  Future<void> enable({int hour = 8, int minute = 0}) async {
    await _prefs.writeBool(_keyEnabled, true);
    await _prefs.writeString(_keyHour, hour.toString());
    await _prefs.writeString(_keyMinute, minute.toString());

    await scheduleUpcoming();

    debugPrint('✅ [DailyVerse] Enabled at $hour:${minute.toString().padLeft(2, '0')}');
  }

  /// Enable daily verse notifications with multiple times per day (V2 onboarding).
  /// Supports 1-3 notification times daily.
  Future<void> enableWithMultipleTimes(List<TimeOfDay> times) async {
    if (times.isEmpty) return;

    await _prefs.writeBool(_keyEnabled, true);
    await _prefs.writeString(_keyFrequency, times.length.toString());

    // Store times as "hour:minute,hour:minute,..."
    final timesStr = times.map((t) => '${t.hour}:${t.minute}').join(',');
    await _prefs.writeString(_keyTimes, timesStr);

    // Also store first time as the legacy single-time for backward compat
    await _prefs.writeString(_keyHour, times.first.hour.toString());
    await _prefs.writeString(_keyMinute, times.first.minute.toString());

    await scheduleUpcoming();

    final formatted = times
        .map((t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}')
        .join(', ');
    debugPrint('✅ [DailyVerse] Enabled ${times.length}x/day at $formatted');
  }

  /// Get all scheduled notification times (returns 1-3 times).
  Future<List<TimeOfDay>> getScheduledTimes() async {
    final timesStr = await _prefs.readString(_keyTimes);
    if (timesStr != null && timesStr.isNotEmpty) {
      return timesStr.split(',').map((s) {
        final parts = s.split(':');
        return TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
        );
      }).toList();
    }
    // Fallback to legacy single time
    final time = await getScheduledTime();
    return [time];
  }

  /// Get configured frequency (1-3 times per day).
  Future<int> getFrequency() async {
    final freq = await _prefs.readString(_keyFrequency);
    return int.tryParse(freq ?? '1') ?? 1;
  }

  /// Disable daily verse notifications and cancel all scheduled.
  Future<void> disable() async {
    await _prefs.writeBool(_keyEnabled, false);
    await cancelScheduledNotifications();

    debugPrint('🔕 [DailyVerse] Disabled');
  }

  /// Check if daily verse is enabled.
  Future<bool> isEnabled() async {
    return await _prefs.readBool(_keyEnabled) ?? false;
  }

  /// Update the notification time.
  Future<void> updateTime({required int hour, required int minute}) async {
    await _prefs.writeString(_keyHour, hour.toString());
    await _prefs.writeString(_keyMinute, minute.toString());

    // Reschedule with new time
    final enabled = await isEnabled();
    if (enabled) {
      await scheduleUpcoming();
    }

    debugPrint('⏰ [DailyVerse] Time updated to $hour:${minute.toString().padLeft(2, '0')}');
  }

  /// Get current notification time.
  Future<TimeOfDay> getScheduledTime() async {
    final hour = int.tryParse(await _prefs.readString(_keyHour) ?? '8') ?? 8;
    final minute =
        int.tryParse(await _prefs.readString(_keyMinute) ?? '0') ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Schedule the next 7 days of verse notifications.
  /// Supports multiple daily times (V2). Called on app launch and settings change.
  Future<void> scheduleUpcoming() async {
    try {
      final enabled = await isEnabled();
      if (!enabled) return;

      // Load all curriculum verses
      final verses = await _loadVerses();
      if (verses.isEmpty) {
        debugPrint('⚠️ [DailyVerse] No verses available — skipping schedule');
        return;
      }

      // Cancel existing scheduled notifications (all slots)
      await cancelScheduledNotifications();

      // Get current position in the verse sequence
      int currentIndex =
          int.tryParse(await _prefs.readString(_keyCurrentIndex) ?? '0') ?? 0;

      // Wrap around if we've gone through all verses
      if (currentIndex >= verses.length) {
        currentIndex = 0;
      }

      // Get all notification times (1-3 slots)
      final times = await getScheduledTimes();
      final now = DateTime.now();

      int totalScheduled = 0;
      for (int slot = 0; slot < times.length; slot++) {
        final time = times[slot];
        final slotBaseId = _baseNotificationId + (slot * _slotIdGap);

        for (int day = 0; day < _scheduleDays; day++) {
          // Calculate the scheduled date
          final scheduledDate = DateTime(
            now.year,
            now.month,
            now.day + day,
            time.hour,
            time.minute,
          );

          // Skip if the time has already passed today
          if (scheduledDate.isBefore(now)) continue;

          // Get the verse for this notification
          final verseIndex = (currentIndex + totalScheduled) % verses.length;
          final verse = verses[verseIndex];

          await _notifications.scheduleNotification(
            id: slotBaseId + day,
            title: '📖 ${verse.reference}',
            body: verse.text,
            scheduledDate: scheduledDate,
            payload: '${payloadPrefix}_${verse.id}',
          );

          totalScheduled++;
          debugPrint(
              '📅 [DailyVerse] Slot $slot Day ${day + 1}: ${verse.reference} at $scheduledDate');
        }
      }

      // Advance the index for the next batch
      final newIndex = (currentIndex + totalScheduled) % verses.length;
      await _prefs.writeString(_keyCurrentIndex, newIndex.toString());
      await _prefs.writeString(
          _keyLastScheduledDate, now.toIso8601String());

      debugPrint(
          '✅ [DailyVerse] Scheduled $totalScheduled notifications across ${times.length} slot(s) (index $currentIndex → $newIndex / ${verses.length})');
    } catch (e) {
      debugPrint('❌ [DailyVerse] Error scheduling: $e');
    }
  }

  /// Get the current verse index (for display in settings).
  Future<int> getCurrentIndex() async {
    return int.tryParse(
            await _prefs.readString(_keyCurrentIndex) ?? '0') ??
        0;
  }

  /// Get total curriculum verse count.
  Future<int> getTotalVerseCount() async {
    final verses = await _loadVerses();
    return verses.length;
  }

  /// Reset the verse sequence to the beginning.
  Future<void> resetSequence() async {
    await _prefs.writeString(_keyCurrentIndex, '0');
    final enabled = await isEnabled();
    if (enabled) {
      await scheduleUpcoming();
    }
    debugPrint('🔄 [DailyVerse] Sequence reset to beginning');
  }

  /// Load and cache curriculum verses (sorted by category then difficulty).
  Future<List<BibleVerse>> _loadVerses() async {
    if (_cachedVerses != null) return _cachedVerses!;

    try {
      final verses = await _verseService.getAllVerses();

      // Sort for a meaningful daily sequence:
      // by category, then by curriculum week, then by difficulty
      verses.sort((a, b) {
        // First by category (rotate through spiritual battles)
        final catCompare = a.category.index.compareTo(b.category.index);
        if (catCompare != 0) return catCompare;

        // Then by curriculum week
        final weekA = a.curriculumWeek ?? 999;
        final weekB = b.curriculumWeek ?? 999;
        final weekCompare = weekA.compareTo(weekB);
        if (weekCompare != 0) return weekCompare;

        // Then by difficulty (easy → hard)
        final diffA = a.difficulty ?? 1;
        final diffB = b.difficulty ?? 1;
        return diffA.compareTo(diffB);
      });

      _cachedVerses = verses;
      debugPrint('📚 [DailyVerse] Loaded ${verses.length} curriculum verses');
      return verses;
    } catch (e) {
      debugPrint('❌ [DailyVerse] Error loading verses: $e');
      return [];
    }
  }

  /// Cancel all scheduled daily verse notifications (all time slots).
  /// Public so WinBackNotificationService can cancel before scheduling its own verses.
  Future<void> cancelScheduledNotifications() async {
    for (int slot = 0; slot < _maxTimeSlots; slot++) {
      final slotBaseId = _baseNotificationId + (slot * _slotIdGap);
      for (int i = 0; i < _scheduleDays; i++) {
        await _notifications.cancelNotification(slotBaseId + i);
      }
    }
  }

  /// Get all curriculum verses sorted for daily sequence.
  /// Used by WinBackNotificationService for verse notifications during winback.
  Future<List<BibleVerse>> getVerses() async {
    return await _loadVerses();
  }

  /// Advance the verse index by [count] positions.
  /// Used by WinBackNotificationService to keep verse sequences in sync.
  Future<void> advanceIndex(int count) async {
    final current = await getCurrentIndex();
    final total = await getTotalVerseCount();
    final newIndex = (current + count) % (total > 0 ? total : 1);
    await _prefs.writeString(_keyCurrentIndex, newIndex.toString());
  }
}
