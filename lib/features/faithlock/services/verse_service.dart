import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/faithlock/services/faithlock_database_service.dart';
import 'package:flutter/material.dart';

class VerseService {
  final FaithLockDatabaseService _db = FaithLockDatabaseService();

  // Get random verse with smart selection logic
  Future<BibleVerse?> getRandomVerse({
    VerseCategory? category,
    List<String>? excludeIds,
  }) async {
    List<BibleVerse> verses;

    if (category != null) {
      verses = await _db.getVersesByCategory(category);
    } else {
      verses = await _db.getAllVerses();
    }

    if (verses.isEmpty) return null;

    // Exclude recently shown verses
    if (excludeIds != null && excludeIds.isNotEmpty) {
      verses = verses.where((v) => !excludeIds.contains(v.id)).toList();
    }

    if (verses.isEmpty) return null;

    verses.shuffle();
    return verses.first;
  }

  // Get contextual verse based on time of day
  Future<BibleVerse?> getContextualVerse() async {
    final timeOfDay = TimeOfDay.now();
    VerseCategory category;

    // Morning (5am - 11am): Hope, Gratitude, Guidance
    if (timeOfDay.hour >= 5 && timeOfDay.hour < 12) {
      final categories = [VerseCategory.hope, VerseCategory.gratitude, VerseCategory.guidance];
      categories.shuffle();
      category = categories.first;
    }
    // Afternoon (12pm - 5pm): Wisdom, Strength, Perseverance
    else if (timeOfDay.hour >= 12 && timeOfDay.hour < 17) {
      final categories = [VerseCategory.wisdom, VerseCategory.strength, VerseCategory.perseverance];
      categories.shuffle();
      category = categories.first;
    }
    // Evening/Night (5pm - 11pm): Peace, Love, Faith
    else {
      final categories = [VerseCategory.peace, VerseCategory.love, VerseCategory.faith];
      categories.shuffle();
      category = categories.first;
    }

    return await getRandomVerse(category: category);
  }

  // Get verse for current streak level (difficulty scaling)
  Future<BibleVerse?> getVerseForStreak(int currentStreak) async {
    VerseCategory category;

    // Easy (Days 1-7): Hope, Love, Peace
    if (currentStreak <= 7) {
      final categories = [VerseCategory.hope, VerseCategory.love, VerseCategory.peace];
      categories.shuffle();
      category = categories.first;
    }
    // Medium (Days 8-30): Wisdom, Faith, Courage
    else if (currentStreak <= 30) {
      final categories = [VerseCategory.wisdom, VerseCategory.faith, VerseCategory.courage];
      categories.shuffle();
      category = categories.first;
    }
    // Hard (Days 31+): Perseverance, Strength, Guidance
    else {
      final categories = [VerseCategory.perseverance, VerseCategory.strength, VerseCategory.guidance];
      categories.shuffle();
      category = categories.first;
    }

    return await getRandomVerse(category: category);
  }

  // Get all verses by category
  Future<List<BibleVerse>> getVersesByCategory(VerseCategory category) async {
    return await _db.getVersesByCategory(category);
  }

  // Search verses
  Future<List<BibleVerse>> searchVerses(String query) async {
    if (query.isEmpty) {
      return await _db.getAllVerses();
    }
    return await _db.searchVerses(query);
  }

  // Get all verses
  Future<List<BibleVerse>> getAllVerses() async {
    return await _db.getAllVerses();
  }

  // Get verse by ID
  Future<BibleVerse?> getVerseById(String id) async {
    return await _db.getVerseById(id);
  }

  // Favorite management
  Future<bool> toggleFavorite(String verseId) async {
    final isFav = await _db.isFavorite(verseId);
    if (isFav) {
      await _db.removeFavorite(verseId);
      return false;
    } else {
      await _db.addFavorite(verseId);
      return true;
    }
  }

  Future<bool> isFavorite(String verseId) async {
    return await _db.isFavorite(verseId);
  }

  Future<List<BibleVerse>> getFavoriteVerses() async {
    return await _db.getFavoriteVerses();
  }

  // Get verses organized by category
  Future<Map<VerseCategory, List<BibleVerse>>> getVersesGroupedByCategory() async {
    final Map<VerseCategory, List<BibleVerse>> grouped = {};

    for (final category in VerseCategory.values) {
      final verses = await _db.getVersesByCategory(category);
      if (verses.isNotEmpty) {
        grouped[category] = verses;
      }
    }

    return grouped;
  }

  // Get daily verse (could be based on date seed for consistency)
  Future<BibleVerse?> getDailyVerse() async {
    final allVerses = await _db.getAllVerses();
    if (allVerses.isEmpty) return null;

    // Use date as seed for consistent daily verse
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;

    return allVerses[dayOfYear % allVerses.length];
  }

  // Get recently shown verses (from unlock history)
  Future<List<String>> getRecentlyShownVerseIds({int days = 7}) async {
    final history = await _db.getUnlockHistory(limit: 100);
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return history
        .where((attempt) => attempt.timestamp.isAfter(cutoffDate))
        .map((attempt) => attempt.verseId)
        .toSet()
        .toList();
  }
}
