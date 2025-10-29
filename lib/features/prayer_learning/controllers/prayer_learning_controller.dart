import 'dart:async';

import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/faithlock/services/question_generator.dart';
import 'package:faithlock/features/faithlock/services/stats_service.dart';
import 'package:faithlock/features/faithlock/services/unlock_timer_service.dart';
import 'package:faithlock/features/faithlock/services/verse_selection_strategy.dart';
import 'package:faithlock/features/lock_challenge/models/verse_question.dart';
import 'package:faithlock/services/ai/meditation_validator_service.dart';
import 'package:faithlock/services/rate_app_service.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Validation states for meditation response
enum ValidationState {
  idle,       // Not yet validated
  validating, // AI validation in progress
  valid,      // Validation passed
  invalid,    // Validation failed
}

/// Controller for guided prayer learning (Balanced mode)
class PrayerLearningController extends GetxController {
  final StorageService _storage = StorageService();
  final StatsService _statsService = StatsService();
  final VerseSelectionStrategy _verseStrategy = VerseSelectionStrategy();
  final MeditationValidatorService _validator = MeditationValidatorService();

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

  // Meditation validation state
  final Rx<ValidationState> meditationValidationState = ValidationState.idle.obs;
  final RxString validationFeedback = RxString('');
  final RxDouble meditationQualityScore = RxDouble(0.0); // AI validation score (0.0-1.0)

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
      case 1: // Meditation - must be validated by AI
        return meditationValidationState.value == ValidationState.valid;
      case 2: // Fill-in-the-blank - must be correct
        return _isRecitationCorrect();
      case 3: // Complete
        return true;
      default:
        return false;
    }
  }

  /// Check if user can skip meditation anyway (has some input)
  bool get canSkipMeditation {
    return currentStep.value == 1 &&
        meditationValidationState.value == ValidationState.invalid;
  }

  /// Move to next step
  Future<void> nextStep() async {
    // Allow skip if meditation is invalid but user wants to proceed
    final allowSkip = canSkipMeditation;

    if ((canProceed || allowSkip) && currentStep.value < stepTitles.length - 1) {
      // Calculate partial score for this step
      _updateCompletionScore();

      currentStep.value++;

      // Start timer for meditation step
      if (currentStep.value == 1) {
        _startMeditationTimer();
      }

      // If we just moved to the completion step, save stats
      if (currentStep.value == stepTitles.length - 1) {
        await _completeSession();
      }
    }
  }

  /// Move to previous step
  void previousStep() {
    if (currentStep.value > 0) {
      // Cancel timer if going back from meditation step
      if (currentStep.value == 1) {
        _timer?.cancel();
        isTimerRunning.value = false;
      }

      currentStep.value--;

      // Reset validation state when going back to meditation
      if (currentStep.value == 1) {
        resetMeditationValidation();
      }
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

  /// Validate meditation response with AI
  Future<void> validateMeditationResponse() async {
    final response = meditationInput.value.trim();

    // Basic validation first - allow very short inputs
    if (response.length < 3) {
      meditationValidationState.value = ValidationState.invalid;
      validationFeedback.value = 'Please share a brief thought (at least 3 characters).';
      return;
    }

    // Start AI validation
    meditationValidationState.value = ValidationState.validating;
    validationFeedback.value = 'Analyzing your reflection...';

    try {
      final verse = selectedVerse.value;
      if (verse == null) {
        meditationValidationState.value = ValidationState.invalid;
        validationFeedback.value = 'Error: No verse selected';
        return;
      }

      // Get user goals and struggles (optional context)
      final userGoals = await _storage.readString('user_goals');
      final userStruggles = await _storage.readString('user_struggles');

      // Validate with AI
      final result = await _validator.validateMeditationResponse(
        verseText: verse.verse,
        verseReference: verse.reference,
        userResponse: response,
        userGoals: userGoals,
        userStruggles: userStruggles,
      );

      // Update state based on result
      meditationValidationState.value =
          result.isValid ? ValidationState.valid : ValidationState.invalid;
      validationFeedback.value = result.feedback;
      meditationQualityScore.value = result.score; // Store AI score (0.0-1.0)

      debugPrint('✅ Meditation validated: ${result.isValid} (score: ${result.score})');
    } catch (e) {
      debugPrint('❌ Validation error: $e');
      // Fallback to basic validation on error
      meditationValidationState.value = response.length >= 3
          ? ValidationState.valid
          : ValidationState.invalid;
      validationFeedback.value = response.length >= 3
          ? 'Thank you for your reflection! 🙏'
          : 'Please share a brief thought.';
      meditationQualityScore.value = response.length >= 3 ? 0.75 : 0.3; // Fallback score
    }
  }

  /// Reset meditation validation state
  void resetMeditationValidation() {
    meditationValidationState.value = ValidationState.idle;
    validationFeedback.value = '';
  }

  /// Update completion score based on performance
  /// Scoring: Reading (20%) + Meditation (30% from AI) + Recitation (50%)
  void _updateCompletionScore() {
    switch (currentStep.value) {
      case 0: // Reading - Fixed 20%
        completionScore.value += 0.20;
        break;

      case 1: // Meditation - 30% (generous scoring)
        double meditationScore = 0.30; // Base meditation weight

        if (meditationValidationState.value == ValidationState.valid) {
          // AI validated - always give 25-30% (generous!)
          // AI score maps to 85-100% of meditation points
          final qualityMultiplier = 0.85 + (meditationQualityScore.value * 0.15);
          completionScore.value += meditationScore * qualityMultiplier;
          debugPrint('📊 Meditation score: ${(meditationScore * qualityMultiplier * 100).toInt()}% (validated ✓)');
        } else if (meditationValidationState.value == ValidationState.invalid) {
          // Invalid but user skipped - still give decent credit for effort
          completionScore.value += meditationScore * 0.7; // 70% of meditation points
          debugPrint('📊 Meditation score: 21% (skipped)');
        } else {
          // Not validated - give credit for having any text (even short)
          final hasMinimalInput = meditationInput.value.trim().length >= 3;
          completionScore.value += hasMinimalInput ? (meditationScore * 0.6) : 0;
          debugPrint('📊 Meditation score: ${hasMinimalInput ? "18%" : "0%"} (not validated)');
        }
        break;

      case 2: // Recitation - 50% (generous scoring)
        final isCorrect = _isRecitationCorrect();
        final accuracy = _calculateRecitationAccuracy();

        if (isCorrect) {
          // Perfect recitation = full 50%
          completionScore.value += 0.50;
          debugPrint('📊 Recitation score: 50% (perfect!)');
        } else if (accuracy >= 0.7) {
          // 70%+ accuracy = 45% (generous!)
          completionScore.value += 0.45;
          debugPrint('📊 Recitation score: 45% (excellent!)');
        } else if (accuracy >= 0.5) {
          // 50-69% accuracy = 40%
          completionScore.value += 0.40;
          debugPrint('📊 Recitation score: 40% (great!)');
        } else {
          // <50% accuracy = 35% (still generous for effort)
          completionScore.value += 0.35;
          debugPrint('📊 Recitation score: 35% (good try!)');
        }
        break;
    }

    debugPrint('📊 Total completion score: ${(completionScore.value * 100).toInt()}%');
  }

  /// Calculate recitation accuracy (0.0-1.0)
  double _calculateRecitationAccuracy() {
    if (selectedVerse.value == null) return 0.0;

    final expected = selectedVerse.value!.verse.toLowerCase().trim();
    final actual = recitationInput.value.toLowerCase().trim();

    if (actual.isEmpty) return 0.0;
    if (expected == actual) return 1.0;

    // Calculate similarity using simple word matching
    final expectedWords = expected.split(RegExp(r'\s+'));
    final actualWords = actual.split(RegExp(r'\s+'));

    int matches = 0;
    for (final word in actualWords) {
      if (expectedWords.contains(word)) {
        matches++;
      }
    }

    return actualWords.isEmpty ? 0.0 : matches / actualWords.length;
  }

  /// Complete the learning session
  Future<void> _completeSession() async {
    final sessionDuration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : 60;

    if (selectedVerse.value != null) {
      try {
        await _statsService.recordUnlockAttempt(
          verseId: selectedVerse.value!.reference,
          wasSuccessful: true,
          attemptCount: 1,
          timeToUnlockSeconds: sessionDuration,
          unlockDurationMinutes: unlockDurationMinutes.value > 0
              ? unlockDurationMinutes.value
              : null, // Pass actual unlock duration
        );
      } catch (e) {
        debugPrint('⚠️ Failed to record prayer stats: $e');
      }
    }

    try {
      await _saveStats();
    } catch (e) {
      debugPrint('⚠️ Failed to save stats: $e');
    }

    await RateAppService().showFirstPrayerPrompt();
  }

  /// Start unlock timer with user-selected duration
  Future<void> startUnlockTimer(Duration duration) async {
    try {
      final unlockTimerService = UnlockTimerService();
      await unlockTimerService.startUnlock(duration: duration);

      final durationMinutes = duration.inMinutes;
      unlockDurationMinutes.value = durationMinutes;

      debugPrint('✅ Started unlock timer for $durationMinutes minutes');
    } catch (e) {
      debugPrint('❌ Failed to start unlock timer: $e');
      rethrow;
    }
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
    meditationValidationState.value = ValidationState.idle;
    validationFeedback.value = '';
    meditationQualityScore.value = 0.0;
    _timer?.cancel();
    _sessionStartTime = DateTime.now(); // Reset session start time
    _loadVerse();
  }
}
