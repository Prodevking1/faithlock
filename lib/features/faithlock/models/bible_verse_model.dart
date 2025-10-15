class BibleVerse {
  final String id;
  final String text;
  final String reference;
  final String book;
  final int chapter;
  final int verse;
  final VerseCategory category;
  final String? translation;

  const BibleVerse({
    required this.id,
    required this.text,
    required this.reference,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.category,
    this.translation = 'KJV',
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

enum VerseCategory {
  strength,
  peace,
  wisdom,
  love,
  faith,
  hope,
  courage,
  guidance,
  gratitude,
  perseverance,
}

extension VerseCategoryExtension on VerseCategory {
  String get value {
    switch (this) {
      case VerseCategory.strength:
        return 'strength';
      case VerseCategory.peace:
        return 'peace';
      case VerseCategory.wisdom:
        return 'wisdom';
      case VerseCategory.love:
        return 'love';
      case VerseCategory.faith:
        return 'faith';
      case VerseCategory.hope:
        return 'hope';
      case VerseCategory.courage:
        return 'courage';
      case VerseCategory.guidance:
        return 'guidance';
      case VerseCategory.gratitude:
        return 'gratitude';
      case VerseCategory.perseverance:
        return 'perseverance';
    }
  }

  String get displayName {
    switch (this) {
      case VerseCategory.strength:
        return 'Strength';
      case VerseCategory.peace:
        return 'Peace';
      case VerseCategory.wisdom:
        return 'Wisdom';
      case VerseCategory.love:
        return 'Love';
      case VerseCategory.faith:
        return 'Faith';
      case VerseCategory.hope:
        return 'Hope';
      case VerseCategory.courage:
        return 'Courage';
      case VerseCategory.guidance:
        return 'Guidance';
      case VerseCategory.gratitude:
        return 'Gratitude';
      case VerseCategory.perseverance:
        return 'Perseverance';
    }
  }

  static VerseCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'strength':
        return VerseCategory.strength;
      case 'peace':
        return VerseCategory.peace;
      case 'wisdom':
        return VerseCategory.wisdom;
      case 'love':
        return VerseCategory.love;
      case 'faith':
        return VerseCategory.faith;
      case 'hope':
        return VerseCategory.hope;
      case 'courage':
        return VerseCategory.courage;
      case 'guidance':
        return VerseCategory.guidance;
      case 'gratitude':
        return VerseCategory.gratitude;
      case 'perseverance':
        return VerseCategory.perseverance;
      default:
        return VerseCategory.faith;
    }
  }
}
