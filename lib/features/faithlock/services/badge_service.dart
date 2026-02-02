import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/faithlock/services/faithlock_database_service.dart';
import 'package:flutter/material.dart' hide Badge;

/// Manages badge earning, checking, and querying
class BadgeService {
  final FaithLockDatabaseService _db = FaithLockDatabaseService();

  /// Get all earned badges from database
  Future<List<EarnedBadge>> getEarnedBadges() async {
    try {
      final rows = await _db.getEarnedBadges();
      return rows.map((r) => EarnedBadge.fromJson(r)).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to load earned badges: $e');
      return [];
    }
  }

  /// Check if a specific badge has been earned
  Future<bool> isBadgeEarned(BadgeId badgeId) async {
    try {
      return await _db.isBadgeEarned(badgeId.name);
    } catch (e) {
      return false;
    }
  }

  /// Award a badge. Returns true if it was newly earned (first time).
  Future<bool> awardBadge(BadgeId badgeId) async {
    final alreadyEarned = await isBadgeEarned(badgeId);
    if (alreadyEarned) return false;

    try {
      final badge = EarnedBadge(
        badgeId: badgeId.name,
        earnedAt: DateTime.now(),
      );
      await _db.insertEarnedBadge(badge.toJson());
      debugPrint(
          '🏅 Badge earned: ${BadgeDefinitions.getBadge(badgeId).name}');
      return true;
    } catch (e) {
      debugPrint('⚠️ Failed to award badge ${badgeId.name}: $e');
      return false;
    }
  }

  /// Check all badge conditions and award any newly eligible badges.
  ///
  /// Returns list of NEWLY earned [Badge] definitions (for dialog display).
  Future<List<Badge>> checkAndAwardBadges({
    required UserStats stats,
    double? sessionScore,
    int? sessionHour,
    bool? usedStreakFreeze,
  }) async {
    final List<Badge> newlyEarned = [];

    // Streak badges
    if (stats.currentStreak >= 3) {
      if (await awardBadge(BadgeId.streakStarter)) {
        newlyEarned.add(BadgeDefinitions.getBadge(BadgeId.streakStarter));
      }
    }
    if (stats.currentStreak >= 7) {
      if (await awardBadge(BadgeId.streakWarrior)) {
        newlyEarned.add(BadgeDefinitions.getBadge(BadgeId.streakWarrior));
      }
    }
    if (stats.currentStreak >= 14) {
      if (await awardBadge(BadgeId.streakDevoted)) {
        newlyEarned.add(BadgeDefinitions.getBadge(BadgeId.streakDevoted));
      }
    }
    if (stats.currentStreak >= 30) {
      if (await awardBadge(BadgeId.streakLegendary)) {
        newlyEarned.add(BadgeDefinitions.getBadge(BadgeId.streakLegendary));
      }
    }

    // Verse milestones
    if (stats.totalVersesRead >= 10) {
      if (await awardBadge(BadgeId.verseExplorer)) {
        newlyEarned.add(BadgeDefinitions.getBadge(BadgeId.verseExplorer));
      }
    }
    if (stats.totalVersesRead >= 50) {
      if (await awardBadge(BadgeId.verseScholar)) {
        newlyEarned.add(BadgeDefinitions.getBadge(BadgeId.verseScholar));
      }
    }
    if (stats.totalVersesRead >= 100) {
      if (await awardBadge(BadgeId.verseMaster)) {
        newlyEarned.add(BadgeDefinitions.getBadge(BadgeId.verseMaster));
      }
    }

    // Session milestones
    if (stats.successfulUnlocks >= 1) {
      if (await awardBadge(BadgeId.firstPrayer)) {
        newlyEarned.add(BadgeDefinitions.getBadge(BadgeId.firstPrayer));
      }
    }
    if (sessionScore != null && sessionScore >= 1.0) {
      if (await awardBadge(BadgeId.perfectScore)) {
        newlyEarned.add(BadgeDefinitions.getBadge(BadgeId.perfectScore));
      }
    }

    // Special — time-based
    if (sessionHour != null) {
      if (sessionHour >= 22 || sessionHour < 5) {
        if (await awardBadge(BadgeId.nightOwl)) {
          newlyEarned.add(BadgeDefinitions.getBadge(BadgeId.nightOwl));
        }
      }
      if (sessionHour >= 5 && sessionHour < 7) {
        if (await awardBadge(BadgeId.earlyBird)) {
          newlyEarned.add(BadgeDefinitions.getBadge(BadgeId.earlyBird));
        }
      }
    }

    // Special — freeze
    if (usedStreakFreeze == true) {
      if (await awardBadge(BadgeId.frozenSolid)) {
        newlyEarned.add(BadgeDefinitions.getBadge(BadgeId.frozenSolid));
      }
    }

    return newlyEarned;
  }
}
