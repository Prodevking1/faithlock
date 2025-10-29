import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/faithlock/services/faithlock_database_service.dart';
import 'package:flutter/material.dart';

/// Intelligent verse selection strategy that combines curriculum-based learning
/// with spaced repetition for optimal memorization
class VerseSelectionStrategy {
  final FaithLockDatabaseService _db = FaithLockDatabaseService();

  /// Maximum streak for curriculum mode (28 days = 4 weeks)
  static const int curriculumMaxStreak = 28;

  /// Select a verse based on current streak and user preferences
  ///
  /// **Days 1-28**: Structured curriculum (4 weeks × 7 days)
  /// - Week 1 (Days 1-7): Easy verses (difficulty=1)
  /// - Week 2 (Days 8-14): Medium verses (difficulty=2)
  /// - Week 3 (Days 15-21): Medium-Hard verses (difficulty=2-3)
  /// - Week 4 (Days 22-28): Hard verses (difficulty=3)
  ///
  /// **Days 29+**: Smart random with spaced repetition
  Future<BibleVerse?> selectVerse({
    required int currentStreak,
    required List<VerseCategory> selectedCategories,
    List<String>? excludeIds,
  }) async {
    if (currentStreak <= curriculumMaxStreak) {
      return await _selectCurriculumVerse(
        currentStreak: currentStreak,
        selectedCategories: selectedCategories,
        excludeIds: excludeIds,
      );
    } else {
      return await _selectSpacedRepetitionVerse(
        selectedCategories: selectedCategories,
        excludeIds: excludeIds,
      );
    }
  }

  /// Select a verse from the curriculum based on current streak
  Future<BibleVerse?> _selectCurriculumVerse({
    required int currentStreak,
    required List<VerseCategory> selectedCategories,
    List<String>? excludeIds,
  }) async {
    // Determine which week we're in (1-4)
    final week = ((currentStreak - 1) ~/ 7) + 1;

    // Determine which day within the week (1-7)
    final dayInWeek = ((currentStreak - 1) % 7) + 1;

    // Get verses for this week from user's selected categories
    List<BibleVerse> weekVerses = [];
    for (final category in selectedCategories) {
      final categoryVerses = await _db.getVersesByCurriculumWeek(
        category: category,
        week: week,
      );
      weekVerses.addAll(categoryVerses);
    }

    if (weekVerses.isEmpty) {
      debugPrint('⚠️ No curriculum verses found for week $week');
      return await _selectRandomVerse(
        categories: selectedCategories,
        excludeIds: excludeIds,
      );
    }

    // Exclude recently shown verses
    if (excludeIds != null && excludeIds.isNotEmpty) {
      weekVerses = weekVerses.where((v) => !excludeIds.contains(v.id)).toList();
    }

    if (weekVerses.isEmpty) {
      debugPrint('⚠️ All curriculum verses excluded, falling back');
      return await _selectRandomVerse(
        categories: selectedCategories,
        excludeIds: [],
      );
    }

    // Smart selection: rotate through verses in the week
    // This ensures users see different verses each day
    final verseIndex = (dayInWeek - 1) % weekVerses.length;
    final selectedVerse = weekVerses[verseIndex];

    debugPrint('✅ Selected: ${selectedVerse.reference} (difficulty=${selectedVerse.difficulty})');
    return selectedVerse;
  }

  /// Select a verse using spaced repetition algorithm
  ///
  /// Algorithm prioritizes:
  /// 1. Verses not seen recently (7+ days ago)
  /// 2. Verses from user's selected categories
  /// 3. Difficulty appropriate for advanced user (all levels)
  Future<BibleVerse?> _selectSpacedRepetitionVerse({
    required List<VerseCategory> selectedCategories,
    List<String>? excludeIds,
  }) async {
    debugPrint('🔄 Spaced Repetition Mode: Advanced user');

    // Get all verses from selected categories
    List<BibleVerse> allVerses = [];
    for (final category in selectedCategories) {
      final categoryVerses = await _db.getVersesByCategory(category);
      allVerses.addAll(categoryVerses);
    }

    if (allVerses.isEmpty) {
      debugPrint('⚠️ No verses found for selected categories');
      return null;
    }

    // Exclude recently shown verses (spaced repetition)
    if (excludeIds != null && excludeIds.isNotEmpty) {
      allVerses = allVerses.where((v) => !excludeIds.contains(v.id)).toList();
    }

    if (allVerses.isEmpty) {
      debugPrint('⚠️ All verses excluded, resetting exclusion list');
      return await _selectRandomVerse(
        categories: selectedCategories,
        excludeIds: [],
      );
    }

    // Shuffle for randomness
    allVerses.shuffle();
    final selectedVerse = allVerses.first;

    debugPrint('✅ Selected: ${selectedVerse.reference} (random with spaced repetition)');
    return selectedVerse;
  }

  /// Fallback: select a random verse from categories
  Future<BibleVerse?> _selectRandomVerse({
    required List<VerseCategory> categories,
    List<String>? excludeIds,
  }) async {
    List<BibleVerse> verses = [];
    for (final category in categories) {
      final categoryVerses = await _db.getVersesByCategory(category);
      verses.addAll(categoryVerses);
    }

    if (verses.isEmpty) return null;

    if (excludeIds != null && excludeIds.isNotEmpty) {
      verses = verses.where((v) => !excludeIds.contains(v.id)).toList();
    }

    if (verses.isEmpty) return null;

    verses.shuffle();
    return verses.first;
  }

  /// Get the current curriculum week based on streak (1-4, or null if past curriculum)
  int? getCurriculumWeek(int currentStreak) {
    if (currentStreak > curriculumMaxStreak) return null;
    return ((currentStreak - 1) ~/ 7) + 1;
  }

  /// Get the expected difficulty level for current streak
  int? getExpectedDifficulty(int currentStreak) {
    if (currentStreak > curriculumMaxStreak) return null;

    final week = getCurriculumWeek(currentStreak);
    switch (week) {
      case 1:
        return 1; // Easy
      case 2:
        return 2; // Medium
      case 3:
        return 2; // Medium-Hard (still difficulty=2 mostly, some 3)
      case 4:
        return 3; // Hard
      default:
        return null;
    }
  }

  /// Check if user has completed the curriculum
  bool hasCompletedCurriculum(int currentStreak) {
    return currentStreak > curriculumMaxStreak;
  }
}
