/// Unique identifier for each badge
enum BadgeId {
  // Streak badges
  streakStarter,
  streakWarrior,
  streakDevoted,
  streakLegendary,

  // Verse milestones
  verseExplorer,
  verseScholar,
  verseMaster,

  // Session milestones
  firstPrayer,
  perfectScore,

  // Special
  nightOwl,
  earlyBird,
  frozenSolid,
}

/// Badge category for grouping in UI
enum BadgeCategory { streak, verses, session, special }

/// Definition of a badge (static, never changes)
class Badge {
  final BadgeId id;
  final String name;
  final String description;
  final String emoji;
  final BadgeCategory category;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
  });
}

/// A badge that has been earned by the user (stored in DB)
class EarnedBadge {
  final int? dbId;
  final String badgeId;
  final DateTime earnedAt;

  const EarnedBadge({
    this.dbId,
    required this.badgeId,
    required this.earnedAt,
  });

  factory EarnedBadge.fromJson(Map<String, dynamic> json) {
    return EarnedBadge(
      dbId: json['id'] as int?,
      badgeId: json['badge_id'] as String,
      earnedAt: DateTime.parse(json['earned_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badge_id': badgeId,
      'earned_at': earnedAt.toIso8601String(),
    };
  }
}
