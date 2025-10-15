import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/faithlock/services/export.dart';
import 'package:get/get.dart';

class UnlockController extends GetxController {
  final VerseService _verseService = VerseService();
  final StatsService _statsService = StatsService();
  final LockService _lockService = LockService();
  final ScreenTimeService _screenTimeService = ScreenTimeService();

  // Observable state
  final Rx<BibleVerse?> currentVerse = Rx<BibleVerse?>(null);
  final Rx<VerseQuiz?> currentQuiz = Rx<VerseQuiz?>(null);
  final RxInt selectedAnswer = RxInt(-1);
  final RxBool isLoading = RxBool(true);
  final RxBool showError = RxBool(false);
  final RxString errorMessage = RxString('');
  final RxInt attemptCount = RxInt(0);
  final Rx<DateTime?> unlockStartTime = Rx<DateTime?>(null);
  final RxBool isAnswerRevealed = RxBool(false);

  // Constants
  static const int maxAttempts = 3;

  @override
  void onInit() {
    super.onInit();
    _loadVerseAndQuiz();
  }

  Future<void> _loadVerseAndQuiz() async {
    try {
      isLoading.value = true;
      unlockStartTime.value = DateTime.now();

      // Get current streak for difficulty scaling
      final stats = await _statsService.getUserStats();

      // Get contextual verse based on time and streak
      BibleVerse? verse;

      if (stats.currentStreak > 0) {
        verse = await _verseService.getVerseForStreak(stats.currentStreak);
      } else {
        verse = await _verseService.getContextualVerse();
      }

      if (verse == null) {
        // Fallback to random verse
        verse = await _verseService.getRandomVerse();
      }

      if (verse == null) {
        throw Exception('No verses available');
      }

      currentVerse.value = verse;
      currentQuiz.value = VerseQuiz.fromVerse(verse);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      showError.value = true;
      errorMessage.value = 'Failed to load verse: $e';
    }
  }

  void selectAnswer(int index) {
    if (isAnswerRevealed.value) return;
    selectedAnswer.value = index;
  }

  Future<void> submitAnswer() async {
    if (selectedAnswer.value == -1) {
      errorMessage.value = 'Please select an answer';
      showError.value = true;
      return;
    }

    if (currentQuiz.value == null || currentVerse.value == null) return;

    attemptCount.value++;
    final isCorrect = currentQuiz.value!.isCorrectAnswer(selectedAnswer.value);

    if (isCorrect) {
      await _handleSuccessfulUnlock();
    } else {
      await _handleFailedAttempt();
    }
  }

  Future<void> _handleSuccessfulUnlock() async {
    try {
      // Calculate time to unlock
      final timeToUnlock = unlockStartTime.value != null
          ? DateTime.now().difference(unlockStartTime.value!).inSeconds
          : null;

      // Record successful unlock
      await _statsService.recordUnlockAttempt(
        verseId: currentVerse.value!.id,
        wasSuccessful: true,
        attemptCount: attemptCount.value,
        timeToUnlockSeconds: timeToUnlock,
      );

      // Stop Screen Time blocking
      await _screenTimeService.stopBlocking();

      // Clear active lock
      await _lockService.setActiveLock(null);

      // Show success message and close
      Get.back(result: true);
    } catch (e) {
      errorMessage.value = 'Failed to record unlock: $e';
      showError.value = true;
    }
  }

  Future<void> _handleFailedAttempt() async {
    if (attemptCount.value >= maxAttempts) {
      // Max attempts reached - show correct answer
      isAnswerRevealed.value = true;
      errorMessage.value = 'Maximum attempts reached. The correct answer is shown in green.';
      showError.value = true;

      // Record failed unlock
      await _statsService.recordUnlockAttempt(
        verseId: currentVerse.value!.id,
        wasSuccessful: false,
        attemptCount: attemptCount.value,
      );
    } else {
      // Show error and allow retry
      errorMessage.value = 'Incorrect answer. ${maxAttempts - attemptCount.value} attempts remaining.';
      showError.value = true;
      selectedAnswer.value = -1; // Reset selection
    }
  }

  Future<void> useEmergencyBypass() async {
    // Emergency bypass with penalty
    try {
      await _statsService.recordUnlockAttempt(
        verseId: currentVerse.value?.id ?? 'emergency',
        wasSuccessful: false,
        attemptCount: maxAttempts,
      );

      await _lockService.setActiveLock(null);
      Get.back(result: false); // false indicates emergency bypass
    } catch (e) {
      errorMessage.value = 'Failed to bypass: $e';
      showError.value = true;
    }
  }

  Future<void> retryWithNewVerse() async {
    selectedAnswer.value = -1;
    attemptCount.value = 0;
    isAnswerRevealed.value = false;
    showError.value = false;
    await _loadVerseAndQuiz();
  }
}
