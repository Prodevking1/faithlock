class BibleVerse {
  final String id;
  final String text;
  final String reference;
  final String book;
  final int chapter;
  final int verse;
  final VerseCategory category;
  final String? translation;

  // Curriculum metadata
  final int? curriculumWeek; // 1-4 for structured learning
  final int? difficulty; // 1=easy, 2=medium, 3=hard
  final String? keyword; // Pre-calculated word for fill-in-the-blank

  const BibleVerse({
    required this.id,
    required this.text,
    required this.reference,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.category,
    this.translation = 'KJV',
    this.curriculumWeek,
    this.difficulty,
    this.keyword,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      id: json['id'] as String,
      text: json['text'] as String,
      reference: json['reference'] as String,
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
      category: VerseCategoryExtension.fromString(json['category'] as String),
      translation: json['translation'] as String? ?? 'KJV',
      curriculumWeek: json['curriculum_week'] as int?,
      difficulty: json['difficulty'] as int?,
      keyword: json['keyword'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'reference': reference,
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'category': category.value,
      'translation': translation,
      'curriculum_week': curriculumWeek,
      'difficulty': difficulty,
      'keyword': keyword,
    };
  }

  BibleVerse copyWith({
    String? id,
    String? text,
    String? reference,
    String? book,
    int? chapter,
    int? verse,
    VerseCategory? category,
    String? translation,
    int? curriculumWeek,
    int? difficulty,
    String? keyword,
  }) {
    return BibleVerse(
      id: id ?? this.id,
      text: text ?? this.text,
      reference: reference ?? this.reference,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      category: category ?? this.category,
      translation: translation ?? this.translation,
      curriculumWeek: curriculumWeek ?? this.curriculumWeek,
      difficulty: difficulty ?? this.difficulty,
      keyword: keyword ?? this.keyword,
    );
  }

  @override
  String toString() => '$reference - $text';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BibleVerse && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Verse categories matching onboarding spiritual battles
enum VerseCategory {
  temptation,   // Overcoming temptation and resisting sin
  fearAnxiety,  // Conquering fear and anxiety
  pride,        // Cultivating humility and defeating pride
  lust,         // Maintaining purity and self-control
  anger,        // Managing anger and practicing patience
}

extension VerseCategoryExtension on VerseCategory {
  /// Database value (lowercase with underscore)
  String get value {
    switch (this) {
      case VerseCategory.temptation:
        return 'temptation';
      case VerseCategory.fearAnxiety:
        return 'fear_anxiety';
      case VerseCategory.pride:
        return 'pride';
      case VerseCategory.lust:
        return 'lust';
      case VerseCategory.anger:
        return 'anger';
    }
  }

  /// User-facing display name (matches onboarding exactly)
  String get displayName {
    switch (this) {
      case VerseCategory.temptation:
        return 'Temptation';
      case VerseCategory.fearAnxiety:
        return 'Fear & Anxiety';
      case VerseCategory.pride:
        return 'Pride';
      case VerseCategory.lust:
        return 'Lust';
      case VerseCategory.anger:
        return 'Anger';
    }
  }

  /// Convert from string (from DB or onboarding)
  static VerseCategory fromString(String value) {
    switch (value.toLowerCase().replaceAll(' ', '_').replaceAll('&', '')) {
      case 'temptation':
        return VerseCategory.temptation;
      case 'fear_anxiety':
      case 'fear__anxiety': // Handle "Fear & Anxiety" -> "fear__anxiety"
      case 'fearanxiety':
        return VerseCategory.fearAnxiety;
      case 'pride':
        return VerseCategory.pride;
      case 'lust':
        return VerseCategory.lust;
      case 'anger':
        return VerseCategory.anger;
      default:
        return VerseCategory.temptation; // Default to temptation
    }
  }
}
