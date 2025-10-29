import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/faithlock/services/faithlock_database_service.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';

class StatsService {
  final FaithLockDatabaseService _db = FaithLockDatabaseService();
  final StorageService _storage = StorageService();

  // Storage keys
  static const String _keyCurrentStreak = 'faithlock_current_streak';
  static const String _keyLongestStreak = 'faithlock_longest_streak';
  static const String _keyLastUnlockDate = 'faithlock_last_unlock_date';

  // Record unlock attempt
  Future<void> recordUnlockAttempt({
    required String verseId,
    required bool wasSuccessful,
    required int attemptCount,
    int? timeToUnlockSeconds,
    int? unlockDurationMinutes,
  }) async {
    final attempt = UnlockAttempt(
      verseId: verseId,
      timestamp: DateTime.now(),
      wasSuccessful: wasSuccessful,
      attemptCount: attemptCount,
      timeToUnlockSeconds: timeToUnlockSeconds,
      unlockDurationMinutes: unlockDurationMinutes,
    );

    await _db.insertUnlockAttempt(attempt);

    // Update daily stats
    await _updateDailyStats(wasSuccessful);

    // Update streak
    if (wasSuccessful) {
      await _updateStreak();
    }
  }

  // Update daily stats
  Future<void> _updateDailyStats(bool wasSuccessful) async {
    final today = DateTime.now();
    final stats = await _db.getDailyStats(today);

    final updated = DailyStats(
      date: today,
      versesRead: wasSuccessful ? stats.versesRead + 1 : stats.versesRead,
      successfulUnlocks: wasSuccessful ? stats.successfulUnlocks + 1 : stats.successfulUnlocks,
      failedAttempts: !wasSuccessful ? stats.failedAttempts + 1 : stats.failedAttempts,
      screenTimeMinutes: stats.screenTimeMinutes,
    );

    await _db.insertDailyStats(updated);
  }

  // Update streak
  Future<void> _updateStreak() async {
    final lastUnlockStr = await _storage.readString(_keyLastUnlockDate);
    final currentStreakStr = await _storage.readString(_keyCurrentStreak);
    final longestStreakStr = await _storage.readString(_keyLongestStreak);

    final currentStreak = currentStreakStr != null ? int.tryParse(currentStreakStr) ?? 0 : 0;
    final longestStreak = longestStreakStr != null ? int.tryParse(longestStreakStr) ?? 0 : 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastUnlockStr != null) {
      final lastUnlock = DateTime.parse(lastUnlockStr);
      final lastUnlockDay = DateTime(lastUnlock.year, lastUnlock.month, lastUnlock.day);

      // Check if already unlocked today
      if (lastUnlockDay == today) {
        return; // Streak already counted for today
      }

      // Check if it's consecutive day
      final daysDiff = today.difference(lastUnlockDay).inDays;

      if (daysDiff == 1) {
        // Consecutive day - increment streak
        final newStreak = currentStreak + 1;
        await _storage.writeString(_keyCurrentStreak, newStreak.toString());

        // Update longest streak if needed
        if (newStreak > longestStreak) {
          await _storage.writeString(_keyLongestStreak, newStreak.toString());
        }
      } else if (daysDiff > 1) {
        // Streak broken - reset to 1
        await _storage.writeString(_keyCurrentStreak, '1');
      }
    } else {
      // First unlock ever
      await _storage.writeString(_keyCurrentStreak, '1');
      await _storage.writeString(_keyLongestStreak, '1');
    }

    // Update last unlock date
    await _storage.writeString(_keyLastUnlockDate, now.toIso8601String());
  }

  /// Reset current streak to 0 (used when user abandons prayer session)
  /// Keeps longest streak intact as historical record
  Future<void> resetStreak() async {
    await _storage.writeString(_keyCurrentStreak, '0');
    // Note: We keep longest streak and last unlock date for historical purposes
  }

  // Get user stats
  Future<UserStats> getUserStats() async {
    final currentStreakStr = await _storage.readString(_keyCurrentStreak);
    final longestStreakStr = await _storage.readString(_keyLongestStreak);
    final currentStreak = currentStreakStr != null ? int.tryParse(currentStreakStr) ?? 0 : 0;
    final longestStreak = longestStreakStr != null ? int.tryParse(longestStreakStr) ?? 0 : 0;
    final lastUnlockStr = await _storage.readString(_keyLastUnlockDate);

    // Get all unlock history
    List<UnlockAttempt> unlockHistory = [];
    try {
      unlockHistory = await _db.getUnlockHistory(limit: 1000);
    } catch (e) {
      // Database might not be initialized yet
      unlockHistory = [];
    }

    // Calculate totals
    final totalVersesRead = unlockHistory.where((a) => a.wasSuccessful).length;
    final successfulUnlocks = unlockHistory.where((a) => a.wasSuccessful).length;
    final failedAttempts = unlockHistory.where((a) => !a.wasSuccessful).length;

    // Get verses by category
    final versesByCategory = await _getVersesByCategory(unlockHistory);

    // Calculate average quiz score
    final averageScore = _calculateAverageQuizScore(unlockHistory);

    // Calculate screen time reduced (use actual unlock durations)
    final screenTimeReduced = _calculateScreenTimeReduced(unlockHistory);

    return UserStats(
      totalVersesRead: totalVersesRead,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      screenTimeReducedMinutes: screenTimeReduced,
      successfulUnlocks: successfulUnlocks,
      failedAttempts: failedAttempts,
      versesByCategory: versesByCategory,
      lastUnlockDate: lastUnlockStr != null ? DateTime.parse(lastUnlockStr) : DateTime.now(),
      averageQuizScore: averageScore,
    );
  }

  // Get verses by category from unlock history
  Future<Map<VerseCategory, int>> _getVersesByCategory(List<UnlockAttempt> history) async {
    final Map<VerseCategory, int> categoryCount = {};

    for (final attempt in history.where((a) => a.wasSuccessful)) {
      final verse = await _db.getVerseById(attempt.verseId);
      if (verse != null) {
        categoryCount[verse.category] = (categoryCount[verse.category] ?? 0) + 1;
      }
    }

    return categoryCount;
  }

  // Calculate average quiz score (returns value between 0.0 and 1.0)
  double _calculateAverageQuizScore(List<UnlockAttempt> history) {
    if (history.isEmpty) return 0.0;

    final totalAttempts = history.length;
    final successfulAttempts = history.where((a) => a.wasSuccessful).length;

    return successfulAttempts / totalAttempts;
  }

  // Calculate screen time reduced using actual unlock durations
  int _calculateScreenTimeReduced(List<UnlockAttempt> history) {
    int totalMinutes = 0;

    for (final attempt in history.where((a) => a.wasSuccessful)) {
      if (attempt.unlockDurationMinutes != null) {
        // Use actual duration selected by user
        totalMinutes += attempt.unlockDurationMinutes!;
      } else {
        // Fallback to 5 minutes for old records without duration
        totalMinutes += 5;
      }
    }

    return totalMinutes;
  }

  // Get weekly progress
  Future<List<DailyStats>> getWeeklyProgress() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return await _db.getStatsRange(weekStart, weekEnd);
  }

  // Get monthly progress
  Future<List<DailyStats>> getMonthlyProgress() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    return await _db.getStatsRange(monthStart, monthEnd);
  }

  // Calculate current streak manually (check for consecutive days)
  Future<int> calculateStreak() async {
    List<UnlockAttempt> unlockHistory = [];
    try {
      unlockHistory = await _db.getUnlockHistory(limit: 365);
    } catch (e) {
      // Database might not be initialized yet
      return 0;
    }

    if (unlockHistory.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (final attempt in unlockHistory.where((a) => a.wasSuccessful)) {
      final attemptDate = DateTime(
        attempt.timestamp.year,
        attempt.timestamp.month,
        attempt.timestamp.day,
      );

      if (lastDate == null) {
        // First successful unlock
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        // Check if it's today or yesterday
        final daysDiff = todayDate.difference(attemptDate).inDays;

        if (daysDiff <= 1) {
          streak = 1;
          lastDate = attemptDate;
        } else {
          break; // Too old, no current streak
        }
      } else {
        // Check if consecutive
        final daysDiff = lastDate.difference(attemptDate).inDays;

        if (daysDiff == 1) {
          streak++;
          lastDate = attemptDate;
        } else if (daysDiff == 0) {
          // Same day, don't increment
          continue;
        } else {
          // Streak broken
          break;
        }
      }
    }

    return streak;
  }

  // Get today's unlock attempts
  Future<List<UnlockAttempt>> getTodayUnlocks() async {
    try {
      return await _db.getTodayUnlocks();
    } catch (e) {
      // Database might not be initialized yet, return empty list
      return [];
    }
  }

  // Reset all stats (for testing or user request)
  Future<void> resetAllStats() async {
    await _storage.deleteData(_keyCurrentStreak);
    await _storage.deleteData(_keyLongestStreak);
    await _storage.deleteData(_keyLastUnlockDate);
  }
}
