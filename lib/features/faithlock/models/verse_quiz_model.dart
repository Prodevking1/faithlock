import 'package:faithlock/features/faithlock/models/bible_verse_model.dart';

class VerseQuiz {
  final String id;
  final BibleVerse verse;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final QuizType type;

  const VerseQuiz({
    required this.id,
    required this.verse,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.type,
  });

  factory VerseQuiz.fromVerse(BibleVerse verse) {
    // Auto-generate quiz based on verse
    return VerseQuiz._generateQuiz(verse);
  }

  static VerseQuiz _generateQuiz(BibleVerse verse) {
    final quizTypes = [
      QuizType.missingWord,
      QuizType.reference,
      QuizType.theme,
    ];

    // Randomly select quiz type
    final type = (quizTypes..shuffle()).first;

    switch (type) {
      case QuizType.missingWord:
        return _createMissingWordQuiz(verse);
      case QuizType.reference:
        return _createReferenceQuiz(verse);
      case QuizType.theme:
        return _createThemeQuiz(verse);
    }
  }

  static VerseQuiz _createMissingWordQuiz(BibleVerse verse) {
    final words = verse.text.split(' ');
    final keyWords = words.where((w) => w.length > 4).toList();

    if (keyWords.isEmpty) {
      return _createReferenceQuiz(verse);
    }

    final missingWord = (keyWords..shuffle()).first;
    final missingWordIndex = words.indexOf(missingWord);

    final questionText = List<String>.from(words);
    questionText[missingWordIndex] = '_____';

    // Generate wrong options
    final allOptions = [missingWord];
    final wrongWords = ['love', 'faith', 'hope', 'truth', 'grace', 'peace', 'joy', 'life'];
    wrongWords.shuffle();

    for (var word in wrongWords) {
      if (word.toLowerCase() != missingWord.toLowerCase() && allOptions.length < 4) {
        allOptions.add(word);
      }
    }

    allOptions.shuffle();
    final correctIndex = allOptions.indexOf(missingWord);

    return VerseQuiz(
      id: '${verse.id}_quiz',
      verse: verse,
      question: 'Fill in the missing word:\n"${questionText.join(' ')}"',
      options: allOptions,
      correctAnswerIndex: correctIndex,
      type: QuizType.missingWord,
    );
  }

  static VerseQuiz _createReferenceQuiz(BibleVerse verse) {
    final correctReference = verse.reference;
    final allOptions = [correctReference];

    // Generate wrong options
    final books = ['John', 'Matthew', 'Psalms', 'Romans', 'Philippians', 'Proverbs'];
    books.shuffle();

    for (var book in books) {
      if (book != verse.book && allOptions.length < 4) {
        allOptions.add('$book ${verse.chapter}:${verse.verse}');
      }
    }

    allOptions.shuffle();
    final correctIndex = allOptions.indexOf(correctReference);

    return VerseQuiz(
      id: '${verse.id}_quiz',
      verse: verse,
      question: 'Where is this verse from?\n"${verse.text}"',
      options: allOptions,
      correctAnswerIndex: correctIndex,
      type: QuizType.reference,
    );
  }

  static VerseQuiz _createThemeQuiz(BibleVerse verse) {
    final correctTheme = verse.category.displayName;
    final allOptions = [correctTheme];

    // Add other categories as wrong options
    final categories = VerseCategory.values
        .map((c) => c.displayName)
        .where((name) => name != correctTheme)
        .toList();

    categories.shuffle();

    for (var category in categories) {
      if (allOptions.length < 4) {
        allOptions.add(category);
      }
    }

    allOptions.shuffle();
    final correctIndex = allOptions.indexOf(correctTheme);

    return VerseQuiz(
      id: '${verse.id}_quiz',
      verse: verse,
      question: 'What is the main theme of this verse?\n"${verse.text}"',
      options: allOptions,
      correctAnswerIndex: correctIndex,
      type: QuizType.theme,
    );
  }

  factory VerseQuiz.fromJson(Map<String, dynamic> json) {
    return VerseQuiz(
      id: json['id'] as String,
      verse: BibleVerse.fromJson(json['verse'] as Map<String, dynamic>),
      question: json['question'] as String,
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      type: QuizTypeExtension.fromString(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'verse': verse.toJson(),
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'type': type.value,
    };
  }

  bool isCorrectAnswer(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }
}

enum QuizType {
  missingWord,
  reference,
  theme,
}

extension QuizTypeExtension on QuizType {
  String get value {
    switch (this) {
      case QuizType.missingWord:
        return 'missing_word';
      case QuizType.reference:
        return 'reference';
      case QuizType.theme:
        return 'theme';
    }
  }

  static QuizType fromString(String value) {
    switch (value) {
      case 'missing_word':
        return QuizType.missingWord;
      case 'reference':
        return QuizType.reference;
      case 'theme':
        return QuizType.theme;
      default:
        return QuizType.missingWord;
    }
  }
}
