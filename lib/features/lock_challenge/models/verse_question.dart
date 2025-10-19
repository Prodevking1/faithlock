/// Model for Bible verse quiz questions
class VerseQuestion {
  final String verse;
  final String reference;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;

  VerseQuestion({
    required this.verse,
    required this.reference,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
  });

  /// Get the correct answer text
  String get correctAnswer => options[correctAnswerIndex];

  /// Check if an answer is correct
  bool isCorrect(int answerIndex) => answerIndex == correctAnswerIndex;

  /// Get verse with blank for fill-in question
  String get verseWithBlank {
    return verse.replaceFirst(
      correctAnswer,
      '___',
    );
  }
}

/// Database of verse questions organized by spiritual battle category
class VerseQuestionDatabase {
  /// Get questions for specific categories
  static List<VerseQuestion> getQuestionsForCategories(
    List<String> categories, {
    int count = 2,
  }) {
    final List<VerseQuestion> questions = [];

    for (final category in categories) {
      final categoryQuestions = _questionsByCategory[category] ?? [];
      if (categoryQuestions.isNotEmpty) {
        // Add random question from this category
        categoryQuestions.shuffle();
        questions.add(categoryQuestions.first);
      }

      if (questions.length >= count) break;
    }

    // If not enough questions, add from general pool
    while (questions.length < count) {
      final allQuestions = _questionsByCategory.values
          .expand((list) => list)
          .toList()
        ..shuffle();
      if (allQuestions.isNotEmpty) {
        questions.add(allQuestions.first);
      } else {
        break;
      }
    }

    return questions.take(count).toList()..shuffle();
  }

  /// Database of questions organized by spiritual battle category
  static final Map<String, List<VerseQuestion>> _questionsByCategory = {
    'Temptation': [
      VerseQuestion(
        verse:
            'No temptation has overtaken you except what is common to mankind. And God is faithful; he will not let you be tempted beyond what you can bear.',
        reference: '1 Corinthians 10:13',
        question: 'Complete the verse: "And God is ___"',
        options: ['faithful', 'merciful', 'powerful', 'loving'],
        correctAnswerIndex: 0,
        category: 'Temptation',
      ),
      VerseQuestion(
        verse:
            'Submit yourselves, then, to God. Resist the devil, and he will flee from you.',
        reference: 'James 4:7',
        question: 'What will the devil do when you resist?',
        options: ['flee', 'fight', 'strengthen', 'persist'],
        correctAnswerIndex: 0,
        category: 'Temptation',
      ),
      VerseQuestion(
        verse:
            'Watch and pray so that you will not fall into temptation. The spirit is willing, but the flesh is weak.',
        reference: 'Matthew 26:41',
        question: 'Complete: "The spirit is willing, but the ___ is weak"',
        options: ['flesh', 'mind', 'heart', 'soul'],
        correctAnswerIndex: 0,
        category: 'Temptation',
      ),
    ],
    'Fear & Anxiety': [
      VerseQuestion(
        verse:
            'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.',
        reference: 'Philippians 4:6',
        question: 'How should we present our requests to God?',
        options: [
            'with thanksgiving',
            'with fear',
            'with doubt',
            'with hesitation'
        ],
        correctAnswerIndex: 0,
        category: 'Fear & Anxiety',
      ),
      VerseQuestion(
        verse: 'For God has not given us a spirit of fear, but of power and of love and of a sound mind.',
        reference: '2 Timothy 1:7',
        question: 'What has God NOT given us?',
        options: ['spirit of fear', 'spirit of power', 'spirit of love', 'sound mind'],
        correctAnswerIndex: 0,
        category: 'Fear & Anxiety',
      ),
      VerseQuestion(
        verse: 'Cast all your anxiety on him because he cares for you.',
        reference: '1 Peter 5:7',
        question: 'Why should we cast our anxiety on God?',
        options: ['he cares for you', 'it\'s required', 'he demands it', 'it\'s tradition'],
        correctAnswerIndex: 0,
        category: 'Fear & Anxiety',
      ),
    ],
    'Pride': [
      VerseQuestion(
        verse: 'God opposes the proud but shows favor to the humble.',
        reference: 'James 4:6',
        question: 'What does God do to the proud?',
        options: ['opposes', 'ignores', 'blesses', 'tolerates'],
        correctAnswerIndex: 0,
        category: 'Pride',
      ),
      VerseQuestion(
        verse: 'Pride goes before destruction, a haughty spirit before a fall.',
        reference: 'Proverbs 16:18',
        question: 'What comes before destruction?',
        options: ['Pride', 'Anger', 'Greed', 'Laziness'],
        correctAnswerIndex: 0,
        category: 'Pride',
      ),
      VerseQuestion(
        verse: 'Do nothing out of selfish ambition or vain conceit. Rather, in humility value others above yourselves.',
        reference: 'Philippians 2:3',
        question: 'How should we value others?',
        options: ['above yourselves', 'equally', 'below yourselves', 'sometimes'],
        correctAnswerIndex: 0,
        category: 'Pride',
      ),
    ],
    'Lust': [
      VerseQuestion(
        verse: 'Flee from sexual immorality. All other sins a person commits are outside the body, but whoever sins sexually, sins against their own body.',
        reference: '1 Corinthians 6:18',
        question: 'What should we do with sexual immorality?',
        options: ['Flee', 'Resist', 'Fight', 'Ignore'],
        correctAnswerIndex: 0,
        category: 'Lust',
      ),
      VerseQuestion(
        verse: 'But I tell you that anyone who looks at a woman lustfully has already committed adultery with her in his heart.',
        reference: 'Matthew 5:28',
        question: 'Where does lustful looking commit adultery?',
        options: ['in his heart', 'in his mind', 'in his soul', 'in his spirit'],
        correctAnswerIndex: 0,
        category: 'Lust',
      ),
      VerseQuestion(
        verse: 'Put to death, therefore, whatever belongs to your earthly nature: sexual immorality, impurity, lust, evil desires and greed.',
        reference: 'Colossians 3:5',
        question: 'What should we put to death?',
        options: ['earthly nature', 'spiritual nature', 'rational nature', 'emotional nature'],
        correctAnswerIndex: 0,
        category: 'Lust',
      ),
    ],
    'Anger': [
      VerseQuestion(
        verse: 'In your anger do not sin: Do not let the sun go down while you are still angry.',
        reference: 'Ephesians 4:26',
        question: 'What should not go down while you are angry?',
        options: ['the sun', 'your pride', 'your guard', 'your spirit'],
        correctAnswerIndex: 0,
        category: 'Anger',
      ),
      VerseQuestion(
        verse: 'Everyone should be quick to listen, slow to speak and slow to become angry.',
        reference: 'James 1:19',
        question: 'We should be slow to become what?',
        options: ['angry', 'happy', 'tired', 'hopeful'],
        correctAnswerIndex: 0,
        category: 'Anger',
      ),
      VerseQuestion(
        verse: 'A gentle answer turns away wrath, but a harsh word stirs up anger.',
        reference: 'Proverbs 15:1',
        question: 'What turns away wrath?',
        options: ['gentle answer', 'loud voice', 'harsh word', 'silence'],
        correctAnswerIndex: 0,
        category: 'Anger',
      ),
    ],
  };
}
