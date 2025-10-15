import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:faithlock/core/constants/core/fast_spacing.dart';
import 'package:faithlock/features/faithlock/controllers/unlock_controller.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/layout/export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UnlockScreen extends StatelessWidget {
  const UnlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UnlockController());

    return Scaffold(
      backgroundColor: FastColors.surface(context),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator.adaptive(),
                  FastSpacing.h16,
                  Text(
                    'Loading verse...',
                    style: TextStyle(color: FastColors.secondaryText(context)),
                  ),
                ],
              ),
            );
          }

          if (controller.currentVerse.value == null || controller.currentQuiz.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: FastColors.error),
                  FastSpacing.h16,
                  Text(
                    'Failed to load verse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: FastColors.primaryText(context),
                    ),
                  ),
                  FastSpacing.h8,
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: FastColors.secondaryText(context)),
                  ),
                  FastSpacing.h24,
                  FastButton(
                    text: 'Retry',
                    onTap: controller.retryWithNewVerse,
                  ),
                ],
              ),
            );
          }

          final verse = controller.currentVerse.value!;
          final quiz = controller.currentQuiz.value!;

          return FastScrollableLayout(
            padding: FastSpacing.px16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FastSpacing.h24,

                // Lock icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: FastColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: FastColors.primary,
                    ),
                  ),
                ),

                FastSpacing.h24,

                // Title
                Text(
                  'Read & Answer to Unlock',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: FastColors.primaryText(context),
                  ),
                ),

                FastSpacing.h8,

                Text(
                  'Reflect on this verse before continuing',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: FastColors.secondaryText(context),
                  ),
                ),

                FastSpacing.h32,

                // Verse card
                Container(
                  padding: FastSpacing.p24,
                  decoration: BoxDecoration(
                    color: FastColors.surfaceVariant(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: FastColors.border(context),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${verse.text}"',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                          color: FastColors.primaryText(context),
                        ),
                      ),
                      FastSpacing.h16,
                      Text(
                        verse.reference,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: FastColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                FastSpacing.h32,

                // Quiz question
                Text(
                  quiz.question,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: FastColors.primaryText(context),
                  ),
                ),

                FastSpacing.h16,

                // Answer options
                ...List.generate(quiz.options.length, (index) {
                  final isSelected = controller.selectedAnswer.value == index;
                  final isCorrect = index == quiz.correctAnswerIndex;
                  final showCorrect = controller.isAnswerRevealed.value && isCorrect;
                  final showWrong = controller.isAnswerRevealed.value && isSelected && !isCorrect;

                  Color borderColor = FastColors.border(context);
                  Color bgColor = FastColors.surface(context);

                  if (showCorrect) {
                    borderColor = FastColors.success;
                    bgColor = FastColors.success.withValues(alpha: 0.1);
                  } else if (showWrong) {
                    borderColor = FastColors.error;
                    bgColor = FastColors.error.withValues(alpha: 0.1);
                  } else if (isSelected) {
                    borderColor = FastColors.primary;
                    bgColor = FastColors.primary.withValues(alpha: 0.05);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => controller.selectAnswer(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                            width: isSelected || showCorrect || showWrong ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: borderColor,
                                  width: 2,
                                ),
                                color: isSelected || showCorrect ? borderColor : Colors.transparent,
                              ),
                              child: (isSelected || showCorrect) ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                quiz.options[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: FastColors.primaryText(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                FastSpacing.h16,

                // Error message
                if (controller.showError.value)
                  Container(
                    padding: FastSpacing.p16,
                    decoration: BoxDecoration(
                      color: controller.isAnswerRevealed.value
                          ? FastColors.warning.withValues(alpha: 0.1)
                          : FastColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.isAnswerRevealed.value ? FastColors.warning : FastColors.error,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          controller.isAnswerRevealed.value ? Icons.info_outline : Icons.error_outline,
                          color: controller.isAnswerRevealed.value ? FastColors.warning : FastColors.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: FastColors.primaryText(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (controller.showError.value) FastSpacing.h16,

                // Attempt counter
                Text(
                  'Attempt ${controller.attemptCount.value} of ${UnlockController.maxAttempts}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: FastColors.tertiaryText(context),
                  ),
                ),

                FastSpacing.h24,

                // Submit button
                if (!controller.isAnswerRevealed.value)
                  FastButton(
                    text: 'Submit Answer',
                    onTap: controller.submitAnswer,
                    isDisabled: controller.selectedAnswer.value == -1,
                  )
                else
                  FastButton(
                    text: 'Try New Verse',
                    onTap: controller.retryWithNewVerse,
                  ),

                FastSpacing.h16,

                // Emergency bypass button
                FastButton(
                  text: 'Emergency Bypass',
                  style: FastButtonStyle.plain,
                  textColor: FastColors.tertiaryText(context),
                  onTap: () {
                    Get.defaultDialog(
                      title: 'Emergency Bypass',
                      titleStyle: TextStyle(color: FastColors.primaryText(context)),
                      backgroundColor: FastColors.surface(context),
                      middleText: 'Using emergency bypass will break your streak and count as a failed attempt. Are you sure?',
                      middleTextStyle: TextStyle(color: FastColors.secondaryText(context)),
                      textCancel: 'Cancel',
                      textConfirm: 'Bypass',
                      confirmTextColor: FastColors.error,
                      onConfirm: () {
                        Get.back();
                        controller.useEmergencyBypass();
                      },
                    );
                  },
                ),

                FastSpacing.h24,
              ],
            ),
          );
        }),
      ),
    );
  }
}
