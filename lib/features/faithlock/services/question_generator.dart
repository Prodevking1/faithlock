import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/lock_challenge/models/verse_question.dart';

/// Generates fill-in-the-blank questions from Bible verses
class QuestionGenerator {
  /// Generate a question from a Bible verse
  ///
  /// Uses pre-calculated keyword if available, otherwise applies intelligent
  /// word selection algorithm
  static VerseQuestion generateQuestion(BibleVerse verse) {
    // Use pre-calculated keyword if available
    if (verse.keyword != null && verse.keyword!.isNotEmpty) {
      return _generateFromKeyword(verse, verse.keyword!);
    }

    // Fallback: use intelligent algorithm
    return _generateWithAlgorithm(verse);
  }

  /// Generate question using pre-calculated keyword
  static VerseQuestion _generateFromKeyword(BibleVerse verse, String keyword) {
    final text = verse.text;
    final keywordLower = keyword.toLowerCase();

    // Find the keyword in the text (case-insensitive)
    final textLower = text.toLowerCase();
    final keywordIndex = textLower.indexOf(keywordLower);

    if (keywordIndex == -1) {
      // Keyword not found, fall back to algorithm
      return _generateWithAlgorithm(verse);
    }

    // Extract the actual word from original text (preserves capitalization)
    final actualKeyword = text.substring(keywordIndex, keywordIndex + keyword.length);

    // Create question with blank
    final questionText = 'Complete: "${text.replaceFirst(actualKeyword, '_____')}"';

    // Generate multiple choice options with correct answer
    final options = _generateOptions(actualKeyword);

    return VerseQuestion(
      verse: verse.text,
      question: questionText,
      reference: verse.reference,
      options: options,
      correctAnswerIndex: 0, // Correct answer is always first, then shuffled
      category: verse.category.displayName,
    );
  }

  /// Generate question using intelligent algorithm
  ///
  /// Algorithm selects key words based on:
  /// 1. Word significance (theological terms, action verbs)
  /// 2. Word length (6-12 characters is ideal)
  /// 3. Position (middle of sentence preferred)
  /// 4. Frequency (avoid common words like "the", "and")
  static VerseQuestion _generateWithAlgorithm(BibleVerse verse) {
    final text = verse.text;
    final words = _tokenizeVerse(text);

    if (words.isEmpty) {
      throw Exception('Cannot generate question from empty verse');
    }

    // Score each word and select the best one
    String selectedWord = _selectBestWord(words);

    // Create question with blank
    final questionText = 'Complete: "${text.replaceFirst(selectedWord, '_____')}"';

    // Generate multiple choice options
    final options = _generateOptions(selectedWord);

    return VerseQuestion(
      verse: verse.text,
      question: questionText,
      reference: verse.reference,
      options: options,
      correctAnswerIndex: 0, // Correct answer is always first, then shuffled
      category: verse.category.displayName,
    );
  }

  /// Generate multiple choice options for a word
  ///
  /// Returns a list of 4 options with the correct answer first
  static List<String> _generateOptions(String correctAnswer) {
    final List<String> options = [correctAnswer];

    // Predefined distractors based on common spiritual/theological terms
    final distractors = [
      'faithful',
      'merciful',
      'powerful',
      'loving',
      'grace',
      'faith',
      'hope',
      'peace',
      'joy',
      'wisdom',
      'strength',
      'trust',
      'believe',
      'follow',
      'obey',
      'resist',
      'flee',
      'pray',
      'worship',
      'glory',
      'Spirit',
      'Lord',
      'God',
      'Christ',
      'holy',
      'blessed',
      'righteous',
      'mercy',
      'truth',
      'salvation',
    ];

    // Filter out the correct answer from distractors
    final availableDistractors = distractors
        .where((word) => word.toLowerCase() != correctAnswer.toLowerCase())
        .toList()
      ..shuffle();

    // Add 3 distractors
    for (int i = 0; i < 3 && i < availableDistractors.length; i++) {
      options.add(availableDistractors[i]);
    }

    // If we don't have enough distractors, add generic ones
    if (options.length < 4) {
      final genericOptions = ['always', 'never', 'sometimes', 'often'];
      options.addAll(genericOptions.take(4 - options.length));
    }

    return options;
  }

  /// Tokenize verse into words while preserving original text
  static List<String> _tokenizeVerse(String text) {
    // Split by whitespace and filter out punctuation-only tokens
    return text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && RegExp(r'[a-zA-Z]').hasMatch(word))
        .toList();
  }

  /// Select the best word for the blank using scoring algorithm
  static String _selectBestWord(List<String> words) {
    double maxScore = 0;
    String bestWord = words.first;

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final cleanWord = _cleanWord(word);

      // Skip very short or common words
      if (cleanWord.length < 3 || _isCommonWord(cleanWord)) {
        continue;
      }

      double score = _scoreWord(cleanWord, i, words.length);

      if (score > maxScore) {
        maxScore = score;
        bestWord = word;
      }
    }

    return bestWord;
  }

  /// Clean word of punctuation while preserving original form
  static String _cleanWord(String word) {
    return word.replaceAll(RegExp(r'[^\w]'), '');
  }

  /// Score a word based on multiple factors
  static double _scoreWord(String word, int position, int totalWords) {
    double score = 0.0;

    // 1. Word length (6-12 chars is ideal)
    final length = word.length;
    if (length >= 6 && length <= 12) {
      score += 3.0;
    } else if (length >= 4 && length <= 15) {
      score += 1.5;
    }

    // 2. Position (middle 50% of verse is preferred)
    final middleStart = (totalWords * 0.25).floor();
    final middleEnd = (totalWords * 0.75).ceil();
    if (position >= middleStart && position <= middleEnd) {
      score += 2.0;
    }

    // 3. Theological/spiritual keywords (high priority)
    if (_isTheologicalWord(word)) {
      score += 4.0;
    }

    // 4. Action verbs (medium priority)
    if (_isActionVerb(word)) {
      score += 2.0;
    }

    // 5. Capitalized words (may be names or important terms)
    if (word[0] == word[0].toUpperCase() && position > 0) {
      score += 1.5;
    }

    return score;
  }

  /// Check if word is a common filler word
  static bool _isCommonWord(String word) {
    final commonWords = {
      'the',
      'and',
      'but',
      'for',
      'not',
      'you',
      'with',
      'his',
      'that',
      'this',
      'from',
      'they',
      'have',
      'will',
      'your',
      'all',
      'can',
      'out',
      'who',
      'are',
      'was',
      'has',
      'had',
      'may',
    };
    return commonWords.contains(word.toLowerCase());
  }

  /// Check if word is a theological/spiritual term
  static bool _isTheologicalWord(String word) {
    final wordLower = word.toLowerCase();
    final theologicalTerms = {
      'god',
      'lord',
      'jesus',
      'christ',
      'holy',
      'spirit',
      'grace',
      'faith',
      'love',
      'peace',
      'salvation',
      'righteous',
      'blessed',
      'covenant',
      'mercy',
      'prayer',
      'worship',
      'glory',
      'heaven',
      'kingdom',
      'truth',
      'wisdom',
      'strength',
      'hope',
      'forgive',
      'redeem',
      'sanctify',
    };
    return theologicalTerms.contains(wordLower);
  }

  /// Check if word is an action verb
  static bool _isActionVerb(String word) {
    final wordLower = word.toLowerCase();
    final actionVerbs = {
      'trust',
      'believe',
      'follow',
      'obey',
      'resist',
      'flee',
      'pray',
      'seek',
      'walk',
      'stand',
      'fight',
      'overcome',
      'endure',
      'persevere',
      'rejoice',
      'praise',
      'worship',
      'submit',
      'humble',
      'serve',
    };
    return actionVerbs.contains(wordLower);
  }
}
