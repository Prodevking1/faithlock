import 'package:faithlock/features/faithlock/models/streak_freeze_model.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:faithlock/services/subscription/revenuecat_service.dart';
import 'package:flutter/material.dart';

/// Manages streak freeze protection
///
/// Rules:
/// - Free users: 1 freeze per week
/// - Premium users: 3 freezes per week
/// - Recharges every Monday at midnight
/// - Cannot use 2 freezes in a row (max 1 consecutive missed day)
class StreakFreezeService {
  final StorageService _storage = StorageService();

  static const String _keyFreezeRemaining = 'faithlock_freeze_remaining';
  static const String _keyFreezeMax = 'faithlock_freeze_max';
  static const String _keyFreezeWeekStart = 'faithlock_freeze_week_start';
  static const String _keyFreezeLastUsed = 'faithlock_freeze_last_used_date';
  static const String _keyFreezeUsedConsecutive =
      'faithlock_freeze_used_consecutive';

  bool get _isPremium {
    try {
      return RevenueCatService.instance.hasAnyActiveSubscription;
    } catch (_) {
      return false;
    }
  }

  /// Initialize freeze state for first-time users
  Future<void> initializeIfNeeded() async {
    final existing = await _storage.readString(_keyFreezeRemaining);
    if (existing != null) return;

    final maxFreezes = _isPremium ? 3 : 1;
    await _storage.writeString(_keyFreezeRemaining, maxFreezes.toString());
    await _storage.writeString(_keyFreezeMax, maxFreezes.toString());
    await _storage.writeString(
      _keyFreezeWeekStart,
      _getMondayOfCurrentWeek().toIso8601String(),
    );
    await _storage.writeBool(_keyFreezeUsedConsecutive, false);

    debugPrint(
        '✅ StreakFreezeService initialized: $maxFreezes freezes (premium: $_isPremium)');
  }

  /// Check if freezes should be recharged (Monday midnight reset)
  Future<void> checkAndRecharge() async {
    await initializeIfNeeded();

    final weekStartStr = await _storage.readString(_keyFreezeWeekStart);
    if (weekStartStr == null) return;

    final storedMonday = DateTime.parse(weekStartStr);
    final currentMonday = _getMondayOfCurrentWeek();

    // If we've moved to a new week, recharge
    if (currentMonday.isAfter(storedMonday)) {
      final maxFreezes = _isPremium ? 3 : 1;
      await _storage.writeString(_keyFreezeRemaining, maxFreezes.toString());
      await _storage.writeString(_keyFreezeMax, maxFreezes.toString());
      await _storage.writeString(
        _keyFreezeWeekStart,
        currentMonday.toIso8601String(),
      );
      await _storage.writeBool(_keyFreezeUsedConsecutive, false);

      debugPrint(
          '🧊 Streak freezes recharged: $maxFreezes (premium: $_isPremium)');
    }
  }

  /// Get current freeze state
  Future<StreakFreezeState> getFreezeState() async {
    await checkAndRecharge();

    final remainingStr = await _storage.readString(_keyFreezeRemaining);
    final maxStr = await _storage.readString(_keyFreezeMax);
    final weekStartStr = await _storage.readString(_keyFreezeWeekStart);
    final lastUsedStr = await _storage.readString(_keyFreezeLastUsed);
    final usedConsecutive =
        await _storage.readBool(_keyFreezeUsedConsecutive) ?? false;

    return StreakFreezeState(
      freezesRemaining:
          remainingStr != null ? int.tryParse(remainingStr) ?? 0 : 0,
      maxFreezes: maxStr != null ? int.tryParse(maxStr) ?? 1 : 1,
      weekStartDate: weekStartStr != null
          ? DateTime.parse(weekStartStr)
          : _getMondayOfCurrentWeek(),
      usedConsecutiveFreeze: usedConsecutive,
      lastFreezeUsedDate:
          lastUsedStr != null ? DateTime.parse(lastUsedStr) : null,
    );
  }

  /// Attempt to consume a freeze. Returns true if successful.
  ///
  /// Called from StatsService._updateStreak() when daysDiff == 2
  /// (user missed exactly 1 day).
  Future<bool> tryUseFreeze() async {
    final state = await getFreezeState();

    if (!state.canUseFreeze) {
      debugPrint(
          '🧊 Cannot use freeze: remaining=${state.freezesRemaining}, consecutive=${state.usedConsecutiveFreeze}');
      return false;
    }

    // Consume one freeze
    final newRemaining = state.freezesRemaining - 1;
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    await _storage.writeString(_keyFreezeRemaining, newRemaining.toString());
    await _storage.writeString(
        _keyFreezeLastUsed, yesterday.toIso8601String());
    await _storage.writeBool(_keyFreezeUsedConsecutive, true);

    debugPrint(
        '🧊 Streak freeze used! Remaining: $newRemaining/${state.maxFreezes}');
    return true;
  }

  /// Reset the consecutive freeze flag.
  /// Called when user successfully prays on a consecutive day (daysDiff == 1).
  Future<void> resetConsecutiveFlag() async {
    await _storage.writeBool(_keyFreezeUsedConsecutive, false);
  }

  /// Get Monday 00:00 of the current week
  DateTime _getMondayOfCurrentWeek() {
    final now = DateTime.now();
    final daysFromMonday = now.weekday - DateTime.monday;
    final monday = now.subtract(Duration(days: daysFromMonday));
    return DateTime(monday.year, monday.month, monday.day);
  }
}
