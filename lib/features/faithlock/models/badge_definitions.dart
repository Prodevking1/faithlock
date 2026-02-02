import 'package:faithlock/features/faithlock/models/badge_model.dart';

/// Static registry of all available badges
class BadgeDefinitions {
  BadgeDefinitions._();

  static const Map<BadgeId, Badge> all = {
    // Streak badges
    BadgeId.streakStarter: Badge(
      id: BadgeId.streakStarter,
      name: 'Streak Starter',
      description: '3 days of prayer in a row',
      emoji: '\u{1F525}', // fire
      category: BadgeCategory.streak,
    ),
    BadgeId.streakWarrior: Badge(
      id: BadgeId.streakWarrior,
      name: 'Streak Warrior',
      description: '7-day prayer streak',
      emoji: '\u{2694}\u{FE0F}', // crossed swords
      category: BadgeCategory.streak,
    ),
    BadgeId.streakDevoted: Badge(
      id: BadgeId.streakDevoted,
      name: 'Devoted',
      description: '14-day prayer streak',
      emoji: '\u{1F64F}', // praying hands
      category: BadgeCategory.streak,
    ),
    BadgeId.streakLegendary: Badge(
      id: BadgeId.streakLegendary,
      name: 'Legendary',
      description: '30-day prayer streak',
      emoji: '\u{1F451}', // crown
      category: BadgeCategory.streak,
    ),

    // Verse milestones
    BadgeId.verseExplorer: Badge(
      id: BadgeId.verseExplorer,
      name: 'Verse Explorer',
      description: 'Read 10 verses',
      emoji: '\u{1F4D6}', // open book
      category: BadgeCategory.verses,
    ),
    BadgeId.verseScholar: Badge(
      id: BadgeId.verseScholar,
      name: 'Verse Scholar',
      description: 'Read 50 verses',
      emoji: '\u{1F4DA}', // books
      category: BadgeCategory.verses,
    ),
    BadgeId.verseMaster: Badge(
      id: BadgeId.verseMaster,
      name: 'Verse Master',
      description: 'Read 100 verses',
      emoji: '\u{1F393}', // graduation cap
      category: BadgeCategory.verses,
    ),

    // Session milestones
    BadgeId.firstPrayer: Badge(
      id: BadgeId.firstPrayer,
      name: 'First Prayer',
      description: 'Complete your first prayer session',
      emoji: '\u{2728}', // sparkles
      category: BadgeCategory.session,
    ),
    BadgeId.perfectScore: Badge(
      id: BadgeId.perfectScore,
      name: 'Perfect Score',
      description: 'Get 100% on a prayer session',
      emoji: '\u{2B50}', // star
      category: BadgeCategory.session,
    ),

    // Special
    BadgeId.nightOwl: Badge(
      id: BadgeId.nightOwl,
      name: 'Night Owl',
      description: 'Pray between 10 PM and 5 AM',
      emoji: '\u{1F319}', // crescent moon
      category: BadgeCategory.special,
    ),
    BadgeId.earlyBird: Badge(
      id: BadgeId.earlyBird,
      name: 'Early Bird',
      description: 'Pray between 5 AM and 7 AM',
      emoji: '\u{1F305}', // sunrise
      category: BadgeCategory.special,
    ),
    BadgeId.frozenSolid: Badge(
      id: BadgeId.frozenSolid,
      name: 'Frozen Solid',
      description: 'Use a streak freeze for the first time',
      emoji: '\u{1F9CA}', // ice
      category: BadgeCategory.special,
    ),
  };

  /// Get badge definition by ID
  static Badge getBadge(BadgeId id) => all[id]!;

  /// Get all badges in a category
  static List<Badge> getByCategory(BadgeCategory category) {
    return all.values.where((b) => b.category == category).toList();
  }

  /// Get all badge definitions as a list
  static List<Badge> get allBadges => all.values.toList();
}
