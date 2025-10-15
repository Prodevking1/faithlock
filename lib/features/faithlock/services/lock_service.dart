import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/faithlock/services/faithlock_database_service.dart';
import 'package:faithlock/features/faithlock/services/screen_time_service.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';

class LockService {
  final FaithLockDatabaseService _db = FaithLockDatabaseService();
  final StorageService _storage = StorageService();
  final ScreenTimeService _screenTimeService = ScreenTimeService();

  // Storage keys
  static const String _keyLockEnabled = 'faithlock_enabled';
  static const String _keyActiveLockId = 'faithlock_active_lock_id';

  // Schedule management
  Future<void> createSchedule(LockSchedule schedule) async {
    await _db.insertSchedule(schedule);
  }

  Future<void> updateSchedule(LockSchedule schedule) async {
    await _db.updateSchedule(schedule);
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await _db.deleteSchedule(scheduleId);
  }

  Future<List<LockSchedule>> getAllSchedules() async {
    return await _db.getAllSchedules();
  }

  Future<List<LockSchedule>> getActiveSchedules() async {
    return await _db.getActiveSchedules();
  }

  // Check if device should be locked now
  Future<LockSchedule?> checkShouldLock() async {
    final isEnabled = await isLockEnabled();
    if (!isEnabled) return null;

    final activeSchedules = await getActiveSchedules();

    for (final schedule in activeSchedules) {
      if (schedule.isActiveNow()) {
        return schedule;
      }
    }

    return null;
  }

  // Enable/disable lock system
  Future<void> setLockEnabled(bool enabled) async {
    await _storage.writeBool(_keyLockEnabled, enabled);
  }

  Future<bool> isLockEnabled() async {
    return await _storage.readBool(_keyLockEnabled) ?? true;
  }

  // Active lock management
  Future<void> setActiveLock(String? scheduleId) async {
    if (scheduleId == null) {
      await _storage.deleteData(_keyActiveLockId);
    } else {
      await _storage.writeString(_keyActiveLockId, scheduleId);
    }
  }

  Future<String?> getActiveLockId() async {
    return await _storage.readString(_keyActiveLockId);
  }

  Future<LockSchedule?> getActiveLock() async {
    final activeLockId = await getActiveLockId();
    if (activeLockId == null) return null;

    final schedules = await getAllSchedules();
    try {
      return schedules.firstWhere((s) => s.id == activeLockId);
    } catch (e) {
      return null;
    }
  }

  // Toggle schedule enabled/disabled
  Future<void> toggleSchedule(String scheduleId) async {
    final schedules = await getAllSchedules();
    final schedule = schedules.firstWhere((s) => s.id == scheduleId);

    final updated = schedule.copyWith(isEnabled: !schedule.isEnabled);
    await updateSchedule(updated);
  }

  // Get next scheduled lock
  Future<({LockSchedule schedule, DateTime nextLockTime})?> getNextScheduledLock() async {
    final activeSchedules = await getActiveSchedules();
    if (activeSchedules.isEmpty) return null;

    final now = DateTime.now();
    DateTime? nearestLockTime;
    LockSchedule? nearestSchedule;

    for (final schedule in activeSchedules) {
      final nextLock = _getNextLockTime(schedule, now);
      if (nextLock != null) {
        if (nearestLockTime == null || nextLock.isBefore(nearestLockTime)) {
          nearestLockTime = nextLock;
          nearestSchedule = schedule;
        }
      }
    }

    if (nearestSchedule != null && nearestLockTime != null) {
      return (schedule: nearestSchedule, nextLockTime: nearestLockTime);
    }

    return null;
  }

  DateTime? _getNextLockTime(LockSchedule schedule, DateTime from) {
    final currentDay = from.weekday;

    // Check if schedule is active for today
    if (schedule.daysOfWeek.contains(currentDay)) {
      final todayLockTime = DateTime(
        from.year,
        from.month,
        from.day,
        schedule.startTime.hour,
        schedule.startTime.minute,
      );

      if (todayLockTime.isAfter(from)) {
        return todayLockTime;
      }
    }

    // Find next day when schedule is active
    for (int i = 1; i <= 7; i++) {
      final nextDate = from.add(Duration(days: i));
      final nextDay = nextDate.weekday;

      if (schedule.daysOfWeek.contains(nextDay)) {
        return DateTime(
          nextDate.year,
          nextDate.month,
          nextDate.day,
          schedule.startTime.hour,
          schedule.startTime.minute,
        );
      }
    }

    return null;
  }

  // Create default bedtime schedule
  Future<void> createDefaultSchedule() async {
    final schedules = await getAllSchedules();
    if (schedules.isNotEmpty) return; // Already has schedules

    final bedtimeSchedule = LockSchedulePresets.bedtime();
    await createSchedule(bedtimeSchedule);
  }

  // Get time until next lock
  Future<Duration?> getTimeUntilNextLock() async {
    final nextLock = await getNextScheduledLock();
    if (nextLock == null) return null;

    final now = DateTime.now();
    return nextLock.nextLockTime.difference(now);
  }

  // Check if currently in a lock period
  Future<bool> isCurrentlyLocked() async {
    final currentLock = await checkShouldLock();
    return currentLock != null;
  }

  // Activate Screen Time blocking for a schedule
  Future<void> activateScheduleBlocking(LockSchedule schedule) async {
    try {
      // Check if Screen Time is authorized
      final isAuthorized = await _screenTimeService.isAuthorized();
      if (!isAuthorized) {
        throw Exception('Screen Time not authorized');
      }

      // Start blocking with the schedule
      await _screenTimeService.startBlocking(schedule: schedule);

      // Set as active lock
      await setActiveLock(schedule.id);
    } catch (e) {
      throw Exception('Failed to activate schedule blocking: $e');
    }
  }

  // Check and activate any pending schedules
  Future<bool> checkAndActivateSchedules() async {
    try {
      final scheduleToActivate = await checkShouldLock();

      if (scheduleToActivate != null) {
        final currentActiveLockId = await getActiveLockId();

        // Only activate if not already active
        if (currentActiveLockId != scheduleToActivate.id) {
          await activateScheduleBlocking(scheduleToActivate);
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
