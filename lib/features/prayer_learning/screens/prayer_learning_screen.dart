import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/prayer_learning/controllers/prayer_learning_controller.dart';
import 'package:faithlock/shared/widgets/bars/fast_app_bar.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
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
      appBar: FastAppBar(
        title: FastText(
          controller.currentStepTitle,
          style: FastTextStyleType.headline,
          color: OnboardingTheme.goldColor,
        ),
      ),
      backgroundColor: OnboardingTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            _buildProgressBar(controller),

            // Main content
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

  Widget _buildProgressBar(PrayerLearningController controller) {
    return Column(
      children: [
        Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: OnboardingTheme.cardBackground,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Obx(() => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: controller.progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: OnboardingTheme.goldColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: OnboardingTheme.goldColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              )),
        ),
        const SizedBox(height: 12),
        Obx(() => FastText(
              'Step ${controller.currentStep.value + 1} of ${controller.stepTitles.length}',
              style: FastTextStyleType.footnote,
              color: OnboardingTheme.labelTertiary,
            )),
      ],
    );
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
                        color:
                            OnboardingTheme.goldColor.withValues(alpha: 0.2),
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
                borderRadius:
                    BorderRadius.circular(OnboardingTheme.radiusMedium),
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
    return Center(
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

              Obx(() {
                final duration = controller.unlockDurationMinutes.value;
                final durationText = duration > 60
                    ? '${(duration / 60).toStringAsFixed(1)} hours'
                    : '$duration minutes';

                return FastText(
                  '🔓 Your apps are unlocked for $durationText\n(until the end of this schedule)',
                  style: FastTextStyleType.callout,
                  color: OnboardingTheme.labelSecondary,
                  textAlign: TextAlign.center,
                );
              }),
            ],
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
                  text: 'Continue',
                  onTap: () async {
                    // ✅ CRITICAL: Call nextStep to trigger unlock before navigating away
                    await controller.nextStep();
                    Get.back();
                  },
                  backgroundColor: OnboardingTheme.goldColor,
                  textColor: OnboardingTheme.backgroundColor,
                  style: FastButtonStyle.filled,
                  width: double.infinity,
                  height: 50,
                )
              else
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
            ],
          ),
        ),
      );
    });
  }
}
