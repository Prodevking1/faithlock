import 'dart:math';
import 'package:faithlock/features/faithlock/services/screen_time_service.dart';
import 'package:faithlock/features/lock_challenge/models/verse_question.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:get/get.dart';

/// Controller for managing lock challenge quiz flow
class LockChallengeController extends GetxController {
  final StorageService _storage = StorageService();

  // Observable state
  final RxList<VerseQuestion> questions = <VerseQuestion>[].obs;
  final RxInt currentQuestionIndex = RxInt(0);
  final RxInt selectedAnswerIndex = RxInt(-1);
  final RxBool isAnswerCorrect = RxBool(false);
  final RxBool showResult = RxBool(false);
  final RxBool isCompleted = RxBool(false);
  final RxInt correctAnswersCount = RxInt(0);
  final RxString challengeMessage = RxString('');

  // Getters
  VerseQuestion? get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex.value] : null;
  bool get hasNextQuestion => currentQuestionIndex.value < questions.length - 1;
  int get totalQuestions => questions.length;
  double get progress =>
      totalQuestions > 0 ? (currentQuestionIndex.value + 1) / totalQuestions : 0.0;

  @override
  void onInit() {
    super.onInit();
    _generateChallengeMessage();
    loadQuestions();
  }

  /// Generate powerful challenge message
  void _generateChallengeMessage() {
    final messages = [
      // Conviction
      'You said this time would be different. Was that a lie?',
      'Your future self is watching. What will you choose?',
      'Every warrior faces this moment. Will you retreat?',
      'God is testing your commitment RIGHT NOW',

      // Challenge
      'Prove you\'re not all talk. Answer the Word.',
      '30 seconds of discipline vs. hours of regret. Choose.',
      'Champions are built in moments like this.',
      'The devil wants you to quit. Don\'t.',

      // Spiritual Warfare
      'This is spiritual warfare. Pick up your sword.',
      'Your flesh wants comfort. Your spirit demands victory.',
      'Eternity is watching. What will you choose?',
      'Jesus resisted temptation with Scripture. So can you.',

      // Accountability
      'You promised yourself. Keep your word.',
      'A 30-day covenant requires today\'s obedience.',
      'Break the cycle NOW or repeat it forever.',
      'Your testimony starts with this decision.',
    ];

    final random = Random();
    challengeMessage.value = messages[random.nextInt(messages.length)];
  }

  /// Load questions based on user's selected categories
  Future<void> loadQuestions() async {
    try {
      // Get user's selected categories
      final categoriesStr = await _storage.readString('selected_verse_categories');
      final categories = categoriesStr?.split(',') ?? ['Temptation'];

      // Get intensity level to determine number of questions
      final intensity = await _storage.readString('scripture_intensity_level') ?? 'Balanced';
      final questionCount = _getQuestionCount(intensity);

      // Get questions from database
      final loadedQuestions = VerseQuestionDatabase.getQuestionsForCategories(
        categories,
        count: questionCount,
      );

      questions.value = loadedQuestions;
    } catch (e) {
      // Fallback to default questions
      questions.value = VerseQuestionDatabase.getQuestionsForCategories(
        ['Temptation'],
        count: 2,
      );
    }
  }

  int _getQuestionCount(String intensity) {
    switch (intensity) {
      case 'Gentle':
        return 1;
      case 'Warrior':
        return 3;
      case 'Balanced':
      default:
        return 2;
    }
  }

  /// Select an answer option
  void selectAnswer(int index) {
    if (showResult.value) return; // Already showing result

    selectedAnswerIndex.value = index;

    // Check if answer is correct
    final question = currentQuestion;
    if (question != null) {
      isAnswerCorrect.value = question.isCorrect(index);
      showResult.value = true;

      if (isAnswerCorrect.value) {
        correctAnswersCount.value++;
      }
    }
  }

  /// Move to next question
  void nextQuestion() {
    if (hasNextQuestion) {
      currentQuestionIndex.value++;
      selectedAnswerIndex.value = -1;
      showResult.value = false;
      isAnswerCorrect.value = false;
    } else {
      // Quiz completed
      completeChallenge();
    }
  }

  /// Retry current question (after incorrect answer)
  void retryQuestion() {
    selectedAnswerIndex.value = -1;
    showResult.value = false;
    isAnswerCorrect.value = false;
  }

  /// Complete the challenge
  Future<void> completeChallenge() async {
    isCompleted.value = true;

    // Save stats
    await _saveSuccessStats();

    // Trigger temporary unlock (5 minutes)
    try {
      final screenTimeService = Get.find<ScreenTimeService>();
      await screenTimeService.temporaryUnlock(durationMinutes: 5);
    } catch (e) {
      print('⚠️ Failed to trigger temporary unlock: $e');
    }
  }

  /// Save success statistics
  Future<void> _saveSuccessStats() async {
    try {
      // Increment total victories
      final victories = await _storage.readString('total_victories') ?? '0';
      final newVictories = (int.tryParse(victories) ?? 0) + 1;
      await _storage.writeString('total_victories', newVictories.toString());

      // Update today's victories
      final today = DateTime.now().toIso8601String().split('T')[0];
      final todayKey = 'victories_$today';
      final todayVictories = await _storage.readString(todayKey) ?? '0';
      final newTodayVictories = (int.tryParse(todayVictories) ?? 0) + 1;
      await _storage.writeString(todayKey, newTodayVictories.toString());

      // Update streak (implement later)
      // await _updateStreak();
    } catch (e) {
      print('Error saving stats: $e');
    }
  }

  /// Break covenant and unlock (emergency bypass)
  Future<void> breakCovenant() async {
    // Reset streak
    await _storage.writeString('current_streak', '0');

    // Record defeat
    final defeats = await _storage.readString('total_defeats') ?? '0';
    final newDefeats = (int.tryParse(defeats) ?? 0) + 1;
    await _storage.writeString('total_defeats', newDefeats.toString());

    // Trigger temporary unlock (emergency - 5 minutes only)
    try {
      final screenTimeService = Get.find<ScreenTimeService>();
      await screenTimeService.temporaryUnlock(durationMinutes: 5);
    } catch (e) {
      print('⚠️ Failed to trigger emergency unlock: $e');
    }
  }

  /// Reset for new challenge
  void reset() {
    currentQuestionIndex.value = 0;
    selectedAnswerIndex.value = -1;
    isAnswerCorrect.value = false;
    showResult.value = false;
    isCompleted.value = false;
    correctAnswersCount.value = 0;
    _generateChallengeMessage();
    loadQuestions();
  }
}
