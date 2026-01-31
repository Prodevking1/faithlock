import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/faithlock/services/faithlock_database_service.dart';
import 'package:faithlock/features/faithlock/services/bible_database_loader.dart';
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

    // Morning (5am - 11am): Focus on starting the day right
    if (timeOfDay.hour >= 5 && timeOfDay.hour < 12) {
      final categories = [VerseCategory.temptation, VerseCategory.pride];
      categories.shuffle();
      category = categories.first;
    }
    // Afternoon (12pm - 5pm): Focus on daily struggles
    else if (timeOfDay.hour >= 12 && timeOfDay.hour < 17) {
      final categories = [VerseCategory.anger, VerseCategory.lust];
      categories.shuffle();
      category = categories.first;
    }
    // Evening/Night (5pm - 11pm): Focus on reflection and peace
    else {
      final categories = [VerseCategory.fearAnxiety, VerseCategory.temptation];
      categories.shuffle();
      category = categories.first;
    }

    return await getRandomVerse(category: category);
  }

  // Get verse for current streak level (difficulty scaling)
  Future<BibleVerse?> getVerseForStreak(int currentStreak) async {
    VerseCategory category;

    // Easy (Days 1-7): Start with common struggles
    if (currentStreak <= 7) {
      final categories = [VerseCategory.temptation, VerseCategory.fearAnxiety];
      categories.shuffle();
      category = categories.first;
    }
    // Medium (Days 8-30): Address deeper issues
    else if (currentStreak <= 30) {
      final categories = [VerseCategory.pride, VerseCategory.anger];
      categories.shuffle();
      category = categories.first;
    }
    // Hard (Days 31+): All categories with focus on purity
    else {
      final categories = [VerseCategory.lust, VerseCategory.pride, VerseCategory.anger];
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

  // Get daily verse (randomly selected)
  Future<BibleVerse?> getDailyVerse() async {
    final allVerses = await _db.getAllVerses();
    if (allVerses.isEmpty) return null;

    // Randomly shuffle and pick the first verse
    allVerses.shuffle();
    return allVerses.first;
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

  // Get paginated verses from complete Bible (31,102 verses)
  Future<List<BibleVerse>> getAllBibleVerses({
    int limit = 100,
    int offset = 0,
    VerseCategory? categoryFilter,
    String? searchQuery,
  }) async {
    return await BibleDatabaseLoader.loadAllBibleVerses(
      limit: limit,
      offset: offset,
      categoryFilter: categoryFilter,
      searchQuery: searchQuery,
    );
  }

  // Get total count of verses in complete Bible
  Future<int> getTotalVersesCount({
    VerseCategory? categoryFilter,
    String? searchQuery,
  }) async {
    return await BibleDatabaseLoader.getTotalVersesCount(
      categoryFilter: categoryFilter,
      searchQuery: searchQuery,
    );
  }
}
