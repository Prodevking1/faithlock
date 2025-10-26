import 'dart:async';

import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/faithlock/services/question_generator.dart';
import 'package:faithlock/features/faithlock/services/screen_time_service.dart';
import 'package:faithlock/features/faithlock/services/stats_service.dart';
import 'package:faithlock/features/faithlock/services/verse_selection_strategy.dart';
import 'package:faithlock/features/lock_challenge/models/verse_question.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller for guided prayer learning (Balanced mode)
class PrayerLearningController extends GetxController {
  final StorageService _storage = StorageService();
  final StatsService _statsService = StatsService();
  final VerseSelectionStrategy _verseStrategy = VerseSelectionStrategy();

  // Text controllers - persist across rebuilds
  late final TextEditingController meditationTextController;
  late final TextEditingController recitationTextController;

  // Observable state
  final RxInt currentStep = RxInt(0);
  final RxString meditationInput = RxString('');
  final RxString recitationInput = RxString('');
  final RxInt meditationTimer = RxInt(30);
  final RxBool isTimerRunning = RxBool(false);
  final RxBool showHint = RxBool(false);
  final RxDouble completionScore = RxDouble(0.0);
  final Rxn<VerseQuestion> selectedVerse = Rxn<VerseQuestion>();
  final RxInt unlockDurationMinutes = RxInt(0);

  // Steps in Balanced mode
  final List<String> stepTitles = [
    'Read & Absorb',
    'Meditate',
    'Remember',
    'Complete',
  ];

  // Timer
  Timer? _timer;

  // Session tracking
  DateTime? _sessionStartTime;

  @override
  void onInit() {
    super.onInit();
    _sessionStartTime = DateTime.now();

    // Initialize text controllers
    meditationTextController = TextEditingController();
    recitationTextController = TextEditingController();

    // Listen to text changes
    meditationTextController.addListener(() {
      meditationInput.value = meditationTextController.text;
    });
    recitationTextController.addListener(() {
      recitationInput.value = recitationTextController.text;
      showHint.value = false;
    });

    _loadVerse();
  }

  @override
  void onClose() {
    _timer?.cancel();
    meditationTextController.dispose();
    recitationTextController.dispose();
    super.onClose();
  }

  /// Load a verse based on user's selected categories and current streak
  /// Uses intelligent curriculum progression for Days 1-28
  Future<void> _loadVerse() async {
    try {
      // Get user's selected categories from onboarding
      final categoriesStr =
          await _storage.readString('selected_verse_categories');
      final categoryNames = categoriesStr?.split(',') ?? ['Temptation'];

      // Convert category names to VerseCategory enum
      final List<VerseCategory> selectedCategories = categoryNames
          .map((name) => VerseCategoryExtension.fromString(name.trim()))
          .toList();

      // Get current streak for curriculum progression
      final userStats = await _statsService.getUserStats();
      final currentStreak = userStats.currentStreak;
      debugPrint(
          '🎓 Loading verse for streak: $currentStreak, categories: $categoryNames');

      // Get recently shown verses for spaced repetition (last 7 days)
      final todayUnlocks = await _statsService.getTodayUnlocks();
      final excludeIds =
          todayUnlocks.map((attempt) => attempt.verseId).toList();

      // Use intelligent verse selection strategy
      final BibleVerse? verse = await _verseStrategy.selectVerse(
        currentStreak: currentStreak,
        selectedCategories: selectedCategories,
        excludeIds: excludeIds,
      );

      if (verse == null) {
        debugPrint('⚠️ No verse found, using fallback');
        _loadFallbackVerse();
        return;
      }

      // Generate question from selected verse
      final question = QuestionGenerator.generateQuestion(verse);
      selectedVerse.value = question;

      debugPrint('✅ Loaded verse: ${verse.reference}');
    } catch (e) {
      debugPrint('❌ Error loading verse: $e');
      _loadFallbackVerse();
    }
  }

  /// Fallback verse when intelligent selection fails
  void _loadFallbackVerse() {
    selectedVerse.value = VerseQuestionDatabase.getQuestionsForCategories(
      ['Temptation'],
      count: 1,
    ).first;
  }

  /// Get current step title
  String get currentStepTitle => currentStep.value < stepTitles.length
      ? stepTitles[currentStep.value]
      : '';

  /// Get progress percentage
  double get progress => (currentStep.value + 1) / stepTitles.length;

  /// Check if we can proceed to next step
  bool get canProceed {
    switch (currentStep.value) {
      case 0: // Reading step - can always proceed
        return true;
      case 1: // Meditation - must have input
        return meditationInput.value.trim().isNotEmpty;
      case 2: // Fill-in-the-blank - must be correct
        return _isRecitationCorrect();
      case 3: // Complete
        return true;
      default:
        return false;
    }
  }

  /// Move to next step
  Future<void> nextStep() async {
    print('🟡 nextStep called - currentStep: ${currentStep.value}, stepTitles.length: ${stepTitles.length}, last step: ${stepTitles.length - 1}');
    print('🟡 canProceed: $canProceed');

    // final screenTimeService = Get.find<ScreenTimeService>();
    // await screenTimeService.temporaryUnlock(durationMinutes: 10);

    if (canProceed && currentStep.value < stepTitles.length - 1) {
      print('🟢 Entering IF - incrementing step');
      // Calculate partial score for this step
      _updateCompletionScore();

      currentStep.value++;

      // Start timer for meditation step
      if (currentStep.value == 1) {
        _startMeditationTimer();
      }
    } else if (currentStep.value == stepTitles.length - 1) {
      print('🟢 Entering ELSE IF - calling _completeSession');
      // Complete the learning session
      // ✅ CRITICAL: Wait for unlock to complete before allowing navigation

      // final screenTimeService = Get.find<ScreenTimeService>();
      // await screenTimeService.temporaryUnlock(
      //     durationMinutes: unlockDurationMinutes.value);

      await _completeSession();
    } else {
      print('🔴 Neither IF nor ELSE IF matched!');
    }
  }

  /// Start meditation countdown timer
  void _startMeditationTimer() {
    isTimerRunning.value = true;
    meditationTimer.value = 30;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (meditationTimer.value > 0) {
        meditationTimer.value--;
      } else {
        _timer?.cancel();
        isTimerRunning.value = false;
      }
    });
  }

  /// Skip meditation timer
  void skipTimer() {
    _timer?.cancel();
    meditationTimer.value = 0;
    isTimerRunning.value = false;
  }

  /// Check if recitation is correct
  bool _isRecitationCorrect() {
    if (selectedVerse.value == null) return false;

    final userAnswer = recitationInput.value.trim().toLowerCase();
    final correctAnswer = selectedVerse.value!.correctAnswer.toLowerCase();

    // Allow some flexibility (80% match)
    final similarity = _calculateSimilarity(userAnswer, correctAnswer);
    return similarity >= 0.8;
  }

  /// Calculate similarity between two strings (simple version)
  double _calculateSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    // Simple contains check for now
    if (b.contains(a) || a.contains(b)) {
      return 0.85;
    }

    return a == b ? 1.0 : 0.0;
  }

  /// Show hint for recitation
  void toggleHint() {
    showHint.value = !showHint.value;
  }

  /// Update completion score based on performance
  void _updateCompletionScore() {
    switch (currentStep.value) {
      case 0: // Reading
        completionScore.value += 0.25;
        break;
      case 1: // Meditation
        final quality = meditationInput.value.length > 20 ? 0.25 : 0.15;
        completionScore.value += quality;
        break;
      case 2: // Recitation
        final accuracy = _isRecitationCorrect() ? 0.50 : 0.30;
        completionScore.value += accuracy;
        break;
    }
  }

  /// Complete the learning session
  Future<void> _completeSession() async {
    print('🔵 DEBUG: _completeSession called');

    // Calculate session duration
    final sessionDuration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : 60; // Default fallback
    print('🔵 DEBUG: Session duration calculated: $sessionDuration seconds');

    // 🆕 Record unlock attempt with streak update
    // This will automatically update the streak if successful
    if (selectedVerse.value != null) {
      try {
        await _statsService.recordUnlockAttempt(
          verseId: selectedVerse.value!.reference, // Use verse reference as ID
          wasSuccessful:
              true, // Prayer learning is always successful completion
          attemptCount: 1, // Prayer learning doesn't have multiple attempts
          timeToUnlockSeconds: sessionDuration,
        );
        debugPrint('✅ Prayer stats recorded - streak updated');
      } catch (e) {
        debugPrint('⚠️ Failed to record prayer stats: $e');
      }
    }
    print('🔵 DEBUG: Stats recording done');

    // Save basic stats (legacy support)
    try {
      await _saveStats();
      print('🔵 DEBUG: _saveStats done');
    } catch (e) {
      print('🔴 ERROR in _saveStats: $e');
    }

    // Calculate remaining time in active schedule
    print('🔵 DEBUG: Calculating remaining minutes...');
    try {
      // final autoNavService = AutoNavigationService();
      // final remainingMinutes =
      //     await autoNavService.getRemainingMinutesInActiveSchedule();
      // unlockDurationMinutes.value = remainingMinutes;
      // print('🔵 DEBUG: Remaining minutes: $remainingMinutes');
    } catch (e) {
      print('🔴 ERROR in getRemainingMinutes: $e');
      unlockDurationMinutes.value = 5;
    }

    // Trigger temporary unlock until end of schedule
    // This will use DeviceActivity to auto-relock after time expires
    print('🔵 DEBUG: About to call temporaryUnlock...');
    try {
      final screenTimeService = Get.find<ScreenTimeService>();
      await screenTimeService.temporaryUnlock(
          durationMinutes: unlockDurationMinutes.value);
      print(
          '✅ Temporary unlock granted for ${unlockDurationMinutes.value} minutes (until end of schedule)');
    } catch (e) {
      print('⚠️ Failed to trigger unlock: $e');
    }
    print('🔵 DEBUG: temporaryUnlock call completed');

    // Move to completion step
    currentStep.value = stepTitles.length - 1;
  }

  /// Save learning statistics
  Future<void> _saveStats() async {
    try {
      // Increment prayer completions
      final completions =
          await _storage.readString('prayer_completions') ?? '0';
      final newCompletions = (int.tryParse(completions) ?? 0) + 1;
      await _storage.writeString(
          'prayer_completions', newCompletions.toString());

      // Update today's count
      final today = DateTime.now().toIso8601String().split('T')[0];
      final todayKey = 'prayers_$today';
      final todayPrayers = await _storage.readString(todayKey) ?? '0';
      final newTodayPrayers = (int.tryParse(todayPrayers) ?? 0) + 1;
      await _storage.writeString(todayKey, newTodayPrayers.toString());

      // Save completion score
      await _storage.writeString(
          'last_prayer_score', completionScore.value.toString());
    } catch (e) {
      print('Error saving stats: $e');
    }
  }

  /// Reset for new session
  void reset() {
    currentStep.value = 0;
    meditationInput.value = '';
    recitationInput.value = '';
    meditationTextController.clear();
    recitationTextController.clear();
    meditationTimer.value = 30;
    isTimerRunning.value = false;
    showHint.value = false;
    completionScore.value = 0.0;
    unlockDurationMinutes.value = 0;
    _timer?.cancel();
    _sessionStartTime = DateTime.now(); // Reset session start time
    _loadVerse();
  }
}
