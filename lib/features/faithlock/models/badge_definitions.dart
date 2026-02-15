import 'package:faithlock/features/faithlock/models/badge_model.dart';
import 'package:get/get.dart';

/// Translation key mapping for badge names and descriptions
class _BadgeTranslationKeys {
  static const Map<BadgeId, String> nameKeys = {
    BadgeId.streakStarter: 'badge_streakStarter_name',
    BadgeId.streakWarrior: 'badge_streakWarrior_name',
    BadgeId.streakDevoted: 'badge_streakDevoted_name',
    BadgeId.streakLegendary: 'badge_streakLegendary_name',
    BadgeId.verseExplorer: 'badge_verseExplorer_name',
    BadgeId.verseScholar: 'badge_verseScholar_name',
    BadgeId.verseMaster: 'badge_verseMaster_name',
    BadgeId.firstPrayer: 'badge_firstPrayer_name',
    BadgeId.perfectScore: 'badge_perfectScore_name',
    BadgeId.nightOwl: 'badge_nightOwl_name',
    BadgeId.earlyBird: 'badge_earlyBird_name',
    BadgeId.frozenSolid: 'badge_frozenSolid_name',
  };

  static const Map<BadgeId, String> descKeys = {
    BadgeId.streakStarter: 'badge_streakStarter_desc',
    BadgeId.streakWarrior: 'badge_streakWarrior_desc',
    BadgeId.streakDevoted: 'badge_streakDevoted_desc',
    BadgeId.streakLegendary: 'badge_streakLegendary_desc',
    BadgeId.verseExplorer: 'badge_verseExplorer_desc',
    BadgeId.verseScholar: 'badge_verseScholar_desc',
    BadgeId.verseMaster: 'badge_verseMaster_desc',
    BadgeId.firstPrayer: 'badge_firstPrayer_desc',
    BadgeId.perfectScore: 'badge_perfectScore_desc',
    BadgeId.nightOwl: 'badge_nightOwl_desc',
    BadgeId.earlyBird: 'badge_earlyBird_desc',
    BadgeId.frozenSolid: 'badge_frozenSolid_desc',
  };
}

/// Extension to get translated badge name and description
extension BadgeTranslation on Badge {
  /// Get translated badge name
  String get translatedName =>
      (_BadgeTranslationKeys.nameKeys[id] ?? name).tr;

  /// Get translated badge description
  String get translatedDescription =>
      (_BadgeTranslationKeys.descKeys[id] ?? description).tr;
}

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
