import 'package:faithlock/features/faithlock/services/stats_service.dart';
import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/prayer_learning/controllers/prayer_learning_controller.dart';
import 'package:faithlock/shared/widgets/animations/confetti_celebration.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/buttons/fast_icon_button.dart';
import 'package:faithlock/shared/widgets/dialogs/unlock_duration_dialog.dart';
import 'package:faithlock/shared/widgets/inputs/fast_text_input.dart';
import 'package:faithlock/shared/widgets/typography/fast_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Prayer Learning Screen - Guided verse memorization (Balanced mode)
///
/// Flow: Read → Meditate → Remember → Complete
class PrayerLearningScreen extends StatelessWidget {
  const PrayerLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrayerLearningController());

    return Scaffold(
      // appBar: FastAppBar(
      //   title: Obx(() => FastText(
      //         controller.currentStepTitle,
      //         style: FastTextStyleType.headline,
      //         color: OnboardingTheme.goldColor,
      //       )),
      //   leading: Obx(() => _buildLeadingButton(controller)),
      //   automaticallyImplyLeading: false,
      // ),
      backgroundColor: OnboardingTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Padding(
              padding: EdgeInsetsGeometry.only(right: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: FastIconButton(
                  onTap: () => _handleClose(controller),
                  enableBackground: true,
                  icon: Icon(
                    CupertinoIcons.clear,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _buildStepContent(controller),
            ),
            // Bottom actions
            _buildBottomActions(controller),
          ],
        ),
      ),
    );
  }

  /// Handle close button press
  Future<void> _handleClose(PrayerLearningController controller) async {
    // Get current streak and calculate progress
    final streak = await _getCurrentStreak();
    final currentStepNum = controller.currentStep.value + 1;
    final totalSteps = controller.stepTitles.length;
    final progressPercent = (controller.progress * 100).round();

    // Show dramatic exit confirmation dialog
    final shouldExit = await showCupertinoDialog<bool>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: Column(
          children: [
            const Text(
              '⚠️',
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              'Close Prayer Session?',
              style: TextStyle(
                fontFamily: OnboardingTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Text(
                'You\'re only ${progressPercent}% through...\n(Step $currentStepNum of $totalSteps)',
                style: TextStyle(
                  fontFamily: OnboardingTheme.fontFamily,
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              if (streak > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        '$streak Day${streak > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontFamily: OnboardingTheme.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Closing now will RESET your streak!',
                  style: TextStyle(
                    fontFamily: OnboardingTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Continue Praying',
              style: TextStyle(
                fontFamily: OnboardingTheme.fontFamily,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Give Up Streak',
              style: TextStyle(
                fontFamily: OnboardingTheme.fontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (shouldExit) {
      // Reset streak if user gives up
      if (streak > 0) {
        final statsService = StatsService();
        await statsService.resetStreak();
        debugPrint('🔥 Streak reset due to prayer abandonment');
      }

      // Navigate back to main screen (can't use Get.back() because navigation stack was cleared)
      Get.offAllNamed('/main');
    }
  }

  /// Get current streak from stats service
  Future<int> _getCurrentStreak() async {
    try {
      final statsService = StatsService();
      final stats = await statsService.getUserStats();
      return stats.currentStreak;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildStepContent(PrayerLearningController controller) {
    return Obx(() {
      switch (controller.currentStep.value) {
        case 0:
          return _buildReadingStep(controller);
        case 1:
          return _buildMeditationStep(controller);
        case 2:
          return _buildRecitationStep(controller);
        case 3:
          return _buildCompletionStep(controller);
        default:
          return const SizedBox();
      }
    });
  }

  // STEP 1: Read & Absorb
  Widget _buildReadingStep(PrayerLearningController controller) {
    return Obx(() {
      final verse = controller.selectedVerse.value;
      if (verse == null) return const SizedBox();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Icon
            Center(
              child: Text(
                '📖✨',
                style: TextStyle(fontSize: 64),
              ),
            ),

            const SizedBox(height: 32),

            // Instruction
            FastText(
              'Read this verse slowly and thoughtfully',
              style: FastTextStyleType.title2,
              color: OnboardingTheme.labelPrimary,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Verse card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: OnboardingTheme.cardBackground,
                borderRadius:
                    BorderRadius.circular(OnboardingTheme.radiusMedium),
                border: Border.all(
                  color: OnboardingTheme.goldColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: OnboardingTheme.goldColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FastText(
                    verse.verse,
                    style: FastTextStyleType.body,
                    color: OnboardingTheme.labelPrimary,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  FastText(
                    '— ${verse.reference}',
                    style: FastTextStyleType.footnote,
                    color: OnboardingTheme.goldColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OnboardingTheme.cardBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text('💡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FastText(
                      'Read it 3 times. Let each word sink into your heart.',
                      style: FastTextStyleType.callout,
                      color: OnboardingTheme.labelSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // STEP 2: Meditate
  Widget _buildMeditationStep(PrayerLearningController controller) {
    final verse = controller.selectedVerse.value;
    if (verse == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Icon
          Center(
            child: Text(
              '🙏💭',
              style: TextStyle(fontSize: 64),
            ),
          ),

          const SizedBox(height: 32),

          // Timer display
          Obx(() {
            final seconds = controller.meditationTimer.value;
            final isRunning = controller.isTimerRunning.value;

            return Center(
              child: Column(
                children: [
                  if (isRunning) ...[
                    FastText(
                      'Take your time...',
                      style: FastTextStyleType.title3,
                      color: OnboardingTheme.labelSecondary,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: OnboardingTheme.goldColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: FastText(
                        '${seconds}s',
                        style: FastTextStyleType.title1,
                        color: OnboardingTheme.goldColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: controller.skipTimer,
                      child: FastText(
                        'Skip timer',
                        style: FastTextStyleType.footnote,
                        color: OnboardingTheme.labelTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Meditation prompt
          FastText(
            'What does this verse mean to you?',
            style: FastTextStyleType.title2,
            color: OnboardingTheme.labelPrimary,
          ),

          const SizedBox(height: 16),

          FastText(
            'Reflect deeply. How can you apply this truth in your life today?',
            style: FastTextStyleType.callout,
            color: OnboardingTheme.labelSecondary,
          ),

          const SizedBox(height: 24),

          // Input field
          FastTextInput(
            controller: controller.meditationTextController,
            hintText: 'Write your thoughts...',
            maxLines: 5,
            textStyle: TextStyle(
              color: OnboardingTheme.labelPrimary,
              fontSize: 16,
            ),
            placeholderStyle: TextStyle(
              color: OnboardingTheme.labelTertiary,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 16),

          // Character count
          Obx(() {
            final length = controller.meditationInput.value.length;
            return FastText(
              '$length characters',
              style: FastTextStyleType.footnote,
              color: OnboardingTheme.labelTertiary,
              textAlign: TextAlign.right,
            );
          }),

          const SizedBox(height: 24),

          // Validate button
          Obx(() {
            final validationState = controller.meditationValidationState.value;
            final hasInput =
                controller.meditationInput.value.trim().length >= 5;

            if (validationState == ValidationState.valid) {
              return const SizedBox();
            }

            return FastButton(
              text: validationState == ValidationState.validating
                  ? 'Validating...'
                  : 'Validate',
              onTap: hasInput && validationState != ValidationState.validating
                  ? controller.validateMeditationResponse
                  : null,
              backgroundColor: OnboardingTheme.goldColor,
              textColor: OnboardingTheme.backgroundColor,
              style: FastButtonStyle.filled,
              width: double.infinity,
              height: 50,
              isDisabled:
                  !hasInput || validationState == ValidationState.validating,
            );
          }),

          const SizedBox(height: 16),

          // Validation feedback
          Obx(() {
            final feedback = controller.validationFeedback.value;
            final validationState = controller.meditationValidationState.value;

            if (feedback.isEmpty) return const SizedBox();

            final color = validationState == ValidationState.valid
                ? Colors.green
                : validationState == ValidationState.invalid
                    ? Colors.red
                    : OnboardingTheme.labelSecondary;

            final icon = validationState == ValidationState.valid
                ? '✅'
                : validationState == ValidationState.invalid
                    ? '❌'
                    : '⏳';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Text(icon, style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FastText(
                      feedback,
                      style: FastTextStyleType.callout,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // STEP 3: Remember (Fill-in-the-blank)
  Widget _buildRecitationStep(PrayerLearningController controller) {
    final verse = controller.selectedVerse.value;
    if (verse == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Icon
          Center(
            child: Text(
              '🧠⚡',
              style: TextStyle(fontSize: 64),
            ),
          ),

          const SizedBox(height: 32),

          // Instruction
          FastText(
            'Complete the missing word',
            style: FastTextStyleType.title2,
            color: OnboardingTheme.labelPrimary,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Verse with blank
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: OnboardingTheme.cardBackground,
              borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
              border: Border.all(
                color: OnboardingTheme.goldColor,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FastText(
                  verse.verseWithBlank,
                  style: FastTextStyleType.body,
                  color: OnboardingTheme.labelPrimary,
                ),
                const SizedBox(height: 16),
                FastText(
                  '— ${verse.reference}',
                  style: FastTextStyleType.footnote,
                  color: OnboardingTheme.goldColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Input for answer
          FastText(
            'Your answer:',
            style: FastTextStyleType.callout,
            color: OnboardingTheme.labelSecondary,
          ),

          const SizedBox(height: 12),

          FastTextInput(
            controller: controller.recitationTextController,
            hintText: 'Type the missing word...',
            textStyle: TextStyle(
              color: OnboardingTheme.labelPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            placeholderStyle: TextStyle(
              color: OnboardingTheme.labelTertiary,
              fontSize: 18,
            ),
            textCapitalization: TextCapitalization.none,
          ),

          const SizedBox(height: 16),

          // Hint button
          Obx(() {
            if (controller.showHint.value) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Text('💡', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FastText(
                        'Hint: ${verse.correctAnswer}',
                        style: FastTextStyleType.callout,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              );
            }

            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: controller.toggleHint,
              child: FastText(
                'Need a hint?',
                style: FastTextStyleType.callout,
                color: OnboardingTheme.labelTertiary,
              ),
            );
          }),
        ],
      ),
    );
  }

  // STEP 4: Complete
  Widget _buildCompletionStep(PrayerLearningController controller) {
    return ConfettiCelebration(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Victory icon
                Text(
                  '🎉✨',
                  style: TextStyle(fontSize: 60),
                ),

                const SizedBox(height: 24),

                // Victory message
                FastText(
                  'Well Done!',
                  style: FastTextStyleType.largeTitle,
                  color: OnboardingTheme.goldColor,
                ),

                const SizedBox(height: 16),

                FastText(
                  'You\'ve completed your prayer time.\nGod is proud of you.',
                  style: FastTextStyleType.body,
                  color: OnboardingTheme.labelPrimary,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Score
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: OnboardingTheme.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: OnboardingTheme.goldColor,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      FastText(
                        'Learning Score',
                        style: FastTextStyleType.footnote,
                        color: OnboardingTheme.labelSecondary,
                      ),
                      const SizedBox(height: 8),
                      Obx(() => FastText(
                            '${(controller.completionScore.value * 100).toInt()}%',
                            style: FastTextStyleType.title1,
                            color: OnboardingTheme.goldColor,
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                FastText(
                  '🔓 Choose how long you\'d like\nto unlock your apps',
                  style: FastTextStyleType.callout,
                  color: OnboardingTheme.labelSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(PrayerLearningController controller) {
    return Obx(() {
      final canProceed = controller.canProceed;
      final isLastStep =
          controller.currentStep.value == controller.stepTitles.length - 1;

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: OnboardingTheme.backgroundColor,
          border: Border(
            top: BorderSide(
              color: OnboardingTheme.cardBorder,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLastStep)
                FastButton(
                  text: 'Choose Unlock Duration',
                  onTap: () async {
                    // Show dialog to select unlock duration
                    final duration =
                        await UnlockDurationDialog.show(context: Get.context!);

                    // If user selected a duration, start the unlock timer
                    if (duration != null) {
                      await controller.startUnlockTimer(duration);
                    }

                    // Navigate back to main screen (can't use Get.back() because navigation stack was cleared)
                    Get.offAllNamed('/main');
                  },
                  backgroundColor: OnboardingTheme.goldColor,
                  textColor: OnboardingTheme.backgroundColor,
                  style: FastButtonStyle.filled,
                  width: double.infinity,
                  height: 50,
                )
              else ...[
                // Show Next button if validated OR not on meditation step
                if (canProceed || controller.currentStep.value != 1)
                  FastButton(
                    text: controller.currentStep.value == 2 ? 'Submit' : 'Next',
                    onTap: canProceed ? controller.nextStep : null,
                    backgroundColor: OnboardingTheme.goldColor,
                    textColor: OnboardingTheme.backgroundColor,
                    style: FastButtonStyle.filled,
                    width: double.infinity,
                    height: 50,
                    isDisabled: !canProceed,
                  ),

                // Show Skip Anyway if meditation is invalid/not validated
                if (controller.canSkipMeditation)
                  FastButton(
                    text: 'Skip Anyway',
                    onTap: controller.nextStep,
                    backgroundColor: OnboardingTheme.cardBackground,
                    textColor: OnboardingTheme.labelSecondary,
                    style: FastButtonStyle.outlined,
                    width: double.infinity,
                    height: 50,
                  ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
