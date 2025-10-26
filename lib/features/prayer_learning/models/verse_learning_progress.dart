/// Model for tracking verse learning progress with spaced repetition
class VerseLearningProgress {
  final String verseId;
  final String verseText;
  final String reference;
  final int reviewCount;
  final DateTime lastReviewed;
  final DateTime nextReviewDate;
  final double masteryLevel; // 0.0 - 1.0
  final List<DateTime> reviewHistory;

  VerseLearningProgress({
    required this.verseId,
    required this.verseText,
    required this.reference,
    this.reviewCount = 0,
    DateTime? lastReviewed,
    DateTime? nextReviewDate,
    this.masteryLevel = 0.0,
    List<DateTime>? reviewHistory,
  })  : lastReviewed = lastReviewed ?? DateTime.now(),
        nextReviewDate = nextReviewDate ?? DateTime.now(),
        reviewHistory = reviewHistory ?? [];

  /// Spaced repetition intervals in days
  static const List<int> spacedRepetitionIntervals = [
    0, // Initial learning
    1, // Review after 1 day
    3, // Review after 3 days
    7, // Review after 1 week
    14, // Review after 2 weeks
    30, // Review after 1 month
  ];

  /// Calculate next review date based on performance
  DateTime calculateNextReview(bool wasSuccessful) {
    final now = DateTime.now();

    if (!wasSuccessful) {
      // Failed review - reset to 1 day
      return now.add(const Duration(days: 1));
    }

    // Successful review - use spaced repetition
    final nextIndex = (reviewCount + 1).clamp(0, spacedRepetitionIntervals.length - 1);
    final daysToAdd = spacedRepetitionIntervals[nextIndex];

    return now.add(Duration(days: daysToAdd));
  }

  /// Check if verse is due for review
  bool get isDueForReview => DateTime.now().isAfter(nextReviewDate);

  /// Update progress after review
  VerseLearningProgress updateAfterReview({
    required bool wasSuccessful,
    required double performanceScore,
  }) {
    final newMastery = wasSuccessful
        ? (masteryLevel + (performanceScore * 0.2)).clamp(0.0, 1.0)
        : (masteryLevel * 0.8).clamp(0.0, 1.0);

    return VerseLearningProgress(
      verseId: verseId,
      verseText: verseText,
      reference: reference,
      reviewCount: wasSuccessful ? reviewCount + 1 : reviewCount,
      lastReviewed: DateTime.now(),
      nextReviewDate: calculateNextReview(wasSuccessful),
      masteryLevel: newMastery,
      reviewHistory: [...reviewHistory, DateTime.now()],
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'verseId': verseId,
      'verseText': verseText,
      'reference': reference,
      'reviewCount': reviewCount,
      'lastReviewed': lastReviewed.toIso8601String(),
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'masteryLevel': masteryLevel,
      'reviewHistory': reviewHistory.map((d) => d.toIso8601String()).toList(),
    };
  }

  /// Create from JSON
  factory VerseLearningProgress.fromJson(Map<String, dynamic> json) {
    return VerseLearningProgress(
      verseId: json['verseId'] as String,
      verseText: json['verseText'] as String,
      reference: json['reference'] as String,
      reviewCount: json['reviewCount'] as int? ?? 0,
      lastReviewed: DateTime.parse(json['lastReviewed'] as String),
      nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
      masteryLevel: (json['masteryLevel'] as num?)?.toDouble() ?? 0.0,
      reviewHistory: (json['reviewHistory'] as List<dynamic>?)
              ?.map((d) => DateTime.parse(d as String))
              .toList() ??
          [],
    );
  }

  VerseLearningProgress copyWith({
    String? verseId,
    String? verseText,
    String? reference,
    int? reviewCount,
    DateTime? lastReviewed,
    DateTime? nextReviewDate,
    double? masteryLevel,
    List<DateTime>? reviewHistory,
  }) {
    return VerseLearningProgress(
      verseId: verseId ?? this.verseId,
      verseText: verseText ?? this.verseText,
      reference: reference ?? this.reference,
      reviewCount: reviewCount ?? this.reviewCount,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      reviewHistory: reviewHistory ?? this.reviewHistory,
    );
  }
}

/// Learning intensity levels
enum LearningIntensity {
  gentle,
  balanced,
  warrior,
}

extension LearningIntensityExtension on LearningIntensity {
  String get displayName {
    switch (this) {
      case LearningIntensity.gentle:
        return 'Gentle';
      case LearningIntensity.balanced:
        return 'Balanced';
      case LearningIntensity.warrior:
        return 'Warrior';
    }
  }

  String get description {
    switch (this) {
      case LearningIntensity.gentle:
        return '1-2 min • Quick review';
      case LearningIntensity.balanced:
        return '3-5 min • Deep learning';
      case LearningIntensity.warrior:
        return '5-10 min • Total mastery';
    }
  }

  int get requiredSteps {
    switch (this) {
      case LearningIntensity.gentle:
        return 2;
      case LearningIntensity.balanced:
        return 4;
      case LearningIntensity.warrior:
        return 6;
    }
  }
}
