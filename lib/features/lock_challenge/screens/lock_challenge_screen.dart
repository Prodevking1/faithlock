import 'package:faithlock/features/lock_challenge/controllers/lock_challenge_controller.dart';
import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Lock Challenge Screen - Powerful conviction-based quiz to unlock apps
class LockChallengeScreen extends StatelessWidget {
  const LockChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LockChallengeController());

    return Scaffold(
      backgroundColor: OnboardingTheme.backgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isCompleted.value) {
            return _buildVictoryScreen(controller);
          }

          return _buildQuizScreen(controller);
        }),
      ),
    );
  }

  Widget _buildQuizScreen(LockChallengeController controller) {
    return Column(
      children: [
        // Progress bar
        _buildProgressBar(controller),

        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header icon
                Center(
                  child: Text(
                    '🔥⚔️🔥',
                    style: TextStyle(fontSize: 48),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'MOMENT OF TRUTH',
                  style: OnboardingTheme.title1.copyWith(
                    color: Colors.orange,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Challenge message
                Obx(() => Text(
                      controller.challengeMessage.value,
                      style: OnboardingTheme.body.copyWith(
                        color: OnboardingTheme.labelPrimary,
                        fontSize: 17,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    )),

                const SizedBox(height: 40),

                // Verse card
                Obx(() => _buildVerseCard(controller)),

                const SizedBox(height: 32),

                // Answer options
                Obx(() => _buildAnswerOptions(controller)),

                const SizedBox(height: 40),

                // Emergency bypass
                _buildEmergencyBypass(controller),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(LockChallengeController controller) {
    return Obx(() {
      final progress = controller.progress;
      return Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: OnboardingTheme.cardBackground,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: OnboardingTheme.goldColor,
                  boxShadow: [
                    BoxShadow(
                      color: OnboardingTheme.goldColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Question ${controller.currentQuestionIndex.value + 1} of ${controller.totalQuestions}',
            style: OnboardingTheme.footnote.copyWith(
              color: OnboardingTheme.labelTertiary,
              fontSize: 13,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildVerseCard(LockChallengeController controller) {
    final question = controller.currentQuestion;
    if (question == null) return const SizedBox();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OnboardingTheme.cardBackground,
        borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
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
          // Verse with blank
          Text(
            question.verseWithBlank,
            style: OnboardingTheme.body.copyWith(
              fontSize: 18,
              height: 1.6,
              color: OnboardingTheme.labelPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Reference
          Text(
            '— ${question.reference}',
            style: OnboardingTheme.footnote.copyWith(
              fontSize: 14,
              color: OnboardingTheme.goldColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(LockChallengeController controller) {
    final question = controller.currentQuestion;
    if (question == null) return const SizedBox();

    return Column(
      children: List.generate(
        question.options.length,
        (index) => _buildAnswerOption(
          controller,
          index,
          question.options[index],
        ),
      ),
    );
  }

  Widget _buildAnswerOption(
    LockChallengeController controller,
    int index,
    String option,
  ) {
    return Obx(() {
      final isSelected = controller.selectedAnswerIndex.value == index;
      final showResult = controller.showResult.value;
      final isCorrect = controller.isAnswerCorrect.value;

      Color backgroundColor;
      Color borderColor;
      Color textColor;

      if (showResult && isSelected) {
        // Show result colors
        backgroundColor = isCorrect
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.red.withValues(alpha: 0.15);
        borderColor = isCorrect ? Colors.green : Colors.red;
        textColor = isCorrect ? Colors.green : Colors.red;
      } else if (isSelected) {
        // Selected but not submitted
        backgroundColor = OnboardingTheme.goldColor.withValues(alpha: 0.15);
        borderColor = OnboardingTheme.goldColor;
        textColor = OnboardingTheme.goldColor;
      } else {
        // Default state
        backgroundColor = OnboardingTheme.cardBackground;
        borderColor = OnboardingTheme.cardBorder;
        textColor = OnboardingTheme.labelPrimary;
      }

      return GestureDetector(
        onTap: showResult ? null : () => controller.selectAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Answer icon
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ),
                ),
                child: showResult && isSelected
                    ? Icon(
                        isCorrect ? Icons.check : Icons.close,
                        color: textColor,
                        size: 18,
                      )
                    : Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),

              const SizedBox(width: 16),

              // Answer text
              Expanded(
                child: Text(
                  option,
                  style: OnboardingTheme.body.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButtons(LockChallengeController controller) {
    return Obx(() {
      final showResult = controller.showResult.value;
      final isCorrect = controller.isAnswerCorrect.value;

      if (!showResult) {
        return const SizedBox();
      }

      if (isCorrect) {
        // Correct answer - show continue button
        return Center(
          child: FastButton(
            text: controller.hasNextQuestion ? 'Next Question' : 'Complete',
            onTap: () => controller.nextQuestion(),
            backgroundColor: Colors.green,
            textColor: Colors.white,
            style: FastButtonStyle.filled,
          ),
        );
      } else {
        // Incorrect answer - show retry button
        return Center(
          child: FastButton(
            text: 'Try Again',
            onTap: () => controller.retryQuestion(),
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            style: FastButtonStyle.filled,
          ),
        );
      }
    });
  }

  Widget _buildEmergencyBypass(LockChallengeController controller) {
    return Center(
      child: Column(
        children: [
          Obx(() => _buildActionButtons(controller)),
          const SizedBox(height: 24),
          Text(
            '⚠️ The easy way out breaks your covenant with God',
            style: OnboardingTheme.footnote.copyWith(
              color: OnboardingTheme.labelTertiary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _showBreakCovenantDialog(controller),
            child: Text(
              'Surrender & Break Covenant',
              style: TextStyle(
                color: Colors.red.withValues(alpha: 0.7),
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBreakCovenantDialog(LockChallengeController controller) {
    Get.defaultDialog(
      title: 'Break Covenant?',
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
      middleText:
          'This will break your streak and record a spiritual defeat.\n\nGod saw your choice. Are you sure?',
      textConfirm: 'Break Covenant',
      textCancel: 'Stay Strong',
      confirmTextColor: Colors.white,
      cancelTextColor: OnboardingTheme.goldColor,
      buttonColor: Colors.red,
      onConfirm: () async {
        await controller.breakCovenant();
        Get.back(); // Close dialog
        Get.back(); // Close challenge screen
        // TODO: Trigger temporary unlock via native code
      },
    );
  }

  Widget _buildVictoryScreen(LockChallengeController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Victory icon
            Text(
              '🏆✨',
              style: TextStyle(fontSize: 80),
            ),

            const SizedBox(height: 32),

            // Victory message
            Text(
              'VICTORY!',
              style: OnboardingTheme.title1.copyWith(
                color: OnboardingTheme.goldColor,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'You resisted temptation.\nGod is proud of you.',
              style: OnboardingTheme.body.copyWith(
                color: OnboardingTheme.labelPrimary,
                fontSize: 18,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Stats
            Obx(() => Text(
                  'Correct: ${controller.correctAnswersCount.value}/${controller.totalQuestions}',
                  style: OnboardingTheme.footnote.copyWith(
                    color: OnboardingTheme.labelSecondary,
                    fontSize: 15,
                  ),
                )),

            const SizedBox(height: 48),

            // Continue button
            FastButton(
              text: 'Continue',
              onTap: () {
                Get.back(); // Return to previous screen
                // TODO: Trigger temporary unlock via native code
              },
              backgroundColor: OnboardingTheme.goldColor,
              textColor: OnboardingTheme.backgroundColor,
              style: FastButtonStyle.filled,
            ),
          ],
        ),
      ),
    );
  }
}
