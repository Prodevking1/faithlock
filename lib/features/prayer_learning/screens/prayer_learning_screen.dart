import 'package:faithlock/features/faithlock/services/stats_service.dart';
import 'package:faithlock/features/prayer_learning/controllers/prayer_learning_controller.dart';
import 'package:faithlock/shared/widgets/animations/confetti_celebration.dart';
import 'package:faithlock/shared/widgets/dialogs/unlock_duration_dialog.dart';
import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/shared/widgets/inputs/fast_text_input.dart';
import 'package:faithlock/shared/widgets/cozy/cozy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Prayer Learning Screen — cozy design system (warm, chunky).
// Flow: Read → Meditate → Remember → Complete
// ─────────────────────────────────────────────────────────────────────────────

class PrayerLearningScreen extends StatelessWidget {
  const PrayerLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrayerLearningController());

    return Scaffold(
      backgroundColor: CozyColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom header bar ──────────────────────────────────────
            _PrayerNavBar(controller: controller),

            // ── Step progress bar ──────────────────────────────────────
            _StepProgressBar(controller: controller),

            // ── Step content (scrollable) ──────────────────────────────
            Expanded(
              child: _buildStepContent(context, controller),
            ),

            // ── Bottom actions ─────────────────────────────────────────
            _BottomActions(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    PrayerLearningController controller,
  ) {
    return Obx(() {
      switch (controller.currentStep.value) {
        case 0:
          return _ReadingStep(controller: controller);
        case 1:
          return _MeditationStep(controller: controller);
        case 2:
          return _RecitationStep(controller: controller);
        case 3:
          return _CompletionStep(controller: controller);
        default:
          return const SizedBox.shrink();
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _PrayerNavBar extends StatelessWidget {
  const _PrayerNavBar({required this.controller});
  final PrayerLearningController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CozyColors.divider, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          // Close button
          CozyTappable(
            onTap: () => _handleClose(controller),
            pressedScale: 0.94,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCancel01,
                color: CozyColors.inkMuted,
                size: 22,
              ),
            ),
          ),
          // Title (centred in the remaining space)
          Expanded(
            child: Obx(() => Text(
                  controller.currentStepTitle,
                  textAlign: TextAlign.center,
                  style: CozyText.heading.copyWith(color: CozyColors.primary),
                )),
          ),
          // Spacer to mirror close button width
          const SizedBox(width: 46),
        ],
      ),
    );
  }

  Future<void> _handleClose(PrayerLearningController controller) async {
    HapticFeedback.mediumImpact();

    final streak = await _getCurrentStreak();
    final currentStepNum = controller.currentStep.value + 1;
    final totalSteps = controller.stepTitles.length;
    final progressPercent = (controller.progress * 100).round();

    final ctx = Get.context;
    if (ctx == null) return;

    final shouldExit = await showDialog<bool>(
          context: ctx,
          barrierDismissible: false,
          builder: (dialogCtx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 32),
            child: CozyCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CozyIconChip(
                    icon: HugeIcons.strokeRoundedAlert02,
                    background: CozyColors.peach,
                    iconColor: CozyColors.ink,
                    size: 56,
                    iconSize: 30,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'prayer_closePrayerSession'.tr,
                    style: CozyText.heading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'prayer_progressPercent'.trParams({
                      'percent': '$progressPercent',
                      'current': '$currentStepNum',
                      'total': '$totalSteps',
                    }),
                    style: CozyText.subtitle,
                    textAlign: TextAlign.center,
                  ),
                  if (streak > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: ShapeDecoration(
                        color: CozyColors.warning.withValues(alpha: 0.14),
                        shape: CozyTokens.smooth(
                          CozyTokens.radiusSm,
                          side: BorderSide(
                            color: CozyColors.warning.withValues(alpha: 0.4),
                            width: CozyTokens.borderWidthThin,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedFire,
                            color: CozyColors.warning,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'prayer_dayCount'.trParams({
                              'count': '$streak',
                              'suffix': streak > 1 ? 's' : '',
                            }),
                            style: CozyText.heading
                                .copyWith(color: CozyColors.ink),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'prayer_streakReset'.tr,
                      style: CozyText.label.copyWith(color: CozyColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  CozyButton(
                    text: 'prayer_continuePraying'.tr,
                    onTap: () => Navigator.of(dialogCtx).pop(false),
                  ),
                  const SizedBox(height: 10),
                  CozyButton(
                    text: 'prayer_giveUpStreak'.tr,
                    variant: CozyButtonVariant.secondary,
                    onTap: () => Navigator.of(dialogCtx).pop(true),
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;

    if (shouldExit) {
      if (streak > 0) {
        final statsService = StatsService();
        await statsService.resetStreak();
      }
      Get.offAllNamed('/main');
    }
  }

  Future<int> _getCurrentStreak() async {
    try {
      final stats = await StatsService().getUserStats();
      return stats.currentStreak;
    } catch (_) {
      return 0;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step progress bar — 4 segments, terracotta fill
// ─────────────────────────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.controller});
  final PrayerLearningController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Obx(() {
        final step = controller.currentStep.value;
        final total = controller.stepTitles.length;
        return Row(
          children: List.generate(total, (i) {
            final filled = i <= step;
            return Expanded(
              child: AnimatedContainer(
                duration: CozyTokens.base,
                curve: Curves.easeOut,
                height: 6,
                margin: EdgeInsets.only(right: i < total - 1 ? 5 : 0),
                decoration: BoxDecoration(
                  color: filled ? CozyColors.primary : CozyColors.divider,
                  borderRadius: BorderRadius.circular(CozyTokens.radiusPill),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1: Read & Absorb
// ─────────────────────────────────────────────────────────────────────────────

class _ReadingStep extends StatelessWidget {
  const _ReadingStep({required this.controller});
  final PrayerLearningController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final verse = controller.selectedVerse.value;
      if (verse == null) return const SizedBox.shrink();

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Icon
                const Center(
                  child: CozyIconChip(
                    icon: HugeIcons.strokeRoundedBookOpen01,
                    background: CozyColors.sage,
                    iconColor: CozyColors.ink,
                    size: 74,
                    iconSize: 36,
                  ),
                ),
                const SizedBox(height: 24),

                // Heading
                Text(
                  'prayer_readSlowly'.tr,
                  textAlign: TextAlign.center,
                  style: CozyText.title.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 28),

                // Verse card
                CozyCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verse.verse,
                        style: CozyText.body.copyWith(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '— ${verse.reference}',
                        style: CozyText.label.copyWith(
                          color: CozyColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tip banner
                _TipBanner(tip: 'prayer_readTip'.tr),
              ]),
            ),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2: Meditate
// ─────────────────────────────────────────────────────────────────────────────

class _MeditationStep extends StatelessWidget {
  const _MeditationStep({required this.controller});
  final PrayerLearningController controller;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Icon
              const Center(
                child: CozyIconChip(
                  icon: HugeIcons.strokeRoundedHandPrayer,
                  background: CozyColors.peach,
                  iconColor: CozyColors.ink,
                  size: 74,
                  iconSize: 36,
                ),
              ),
              const SizedBox(height: 24),

              // Timer countdown
              Obx(() {
                final seconds = controller.meditationTimer.value;
                final running = controller.isTimerRunning.value;
                if (!running) return const SizedBox.shrink();
                return Column(
                  children: [
                    Text(
                      'prayer_takeYourTime'.tr,
                      textAlign: TextAlign.center,
                      style: CozyText.body.copyWith(color: CozyColors.inkMuted),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      decoration: ShapeDecoration(
                        color: CozyColors.primaryLight.withValues(alpha: 0.4),
                        shape: CozyTokens.smooth(
                          CozyTokens.radiusPill,
                          side: const BorderSide(
                            color: CozyColors.outline,
                            width: CozyTokens.borderWidthThin,
                          ),
                        ),
                      ),
                      child: Text(
                        '${seconds}s',
                        style: CozyText.title.copyWith(
                          fontSize: 32,
                          color: CozyColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    CozyTappable(
                      onTap: controller.skipTimer,
                      pressedScale: 0.96,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'prayer_skipTimer'.tr,
                          style: CozyText.subtitle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),

              // Prompt
              Text(
                'prayer_whatMeansToYou'.tr,
                style: CozyText.title.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'prayer_reflectDeeply'.tr,
                style: CozyText.body.copyWith(color: CozyColors.inkMuted),
              ),
              const SizedBox(height: 20),

              // Multi-line text input
              FastTextInput(
                controller: controller.meditationTextController,
                hintText: 'prayer_writeThoughts'.tr,
                maxLines: 5,
                textStyle: CozyText.body.copyWith(fontSize: 16),
                placeholderStyle: CozyText.body
                    .copyWith(fontSize: 16, color: CozyColors.inkMuted),
              ),
              const SizedBox(height: 10),

              // Character count
              Obx(() => Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'prayer_characters'.trParams({
                        'count': '${controller.meditationInput.value.length}'
                      }),
                      style: CozyText.label
                          .copyWith(color: CozyColors.inkMuted, fontSize: 12),
                    ),
                  )),
              const SizedBox(height: 16),

              // Validate button
              Obx(() {
                final state = controller.meditationValidationState.value;
                final hasInput =
                    controller.meditationInput.value.trim().length >= 5;
                if (state == ValidationState.valid) {
                  return const SizedBox.shrink();
                }
                final isValidating = state == ValidationState.validating;
                return CozyButton(
                  text: isValidating
                      ? 'prayer_validating'.tr
                      : 'prayer_validate'.tr,
                  isDisabled: !hasInput || isValidating,
                  onTap: controller.validateMeditationResponse,
                );
              }),
              const SizedBox(height: 14),

              // AI validation feedback
              Obx(() {
                final feedback = controller.validationFeedback.value;
                final state = controller.meditationValidationState.value;
                if (feedback.isEmpty) return const SizedBox.shrink();

                final Color color;
                final List<List<dynamic>> icon;
                if (state == ValidationState.valid) {
                  color = CozyColors.success;
                  icon = HugeIcons.strokeRoundedCheckmarkCircle01;
                } else if (state == ValidationState.invalid) {
                  color = CozyColors.error;
                  icon = HugeIcons.strokeRoundedCancelCircle;
                } else {
                  color = CozyColors.primary;
                  icon = HugeIcons.strokeRoundedHourglass;
                }

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: ShapeDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: CozyTokens.smooth(
                      CozyTokens.radiusSm,
                      side: BorderSide(
                        color: color.withValues(alpha: 0.4),
                        width: CozyTokens.borderWidthThin,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HugeIcon(icon: icon, color: color, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feedback,
                          style: CozyText.body
                              .copyWith(fontSize: 14, color: color),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3: Remember (fill-in-the-blank)
// ─────────────────────────────────────────────────────────────────────────────

class _RecitationStep extends StatelessWidget {
  const _RecitationStep({required this.controller});
  final PrayerLearningController controller;

  @override
  Widget build(BuildContext context) {
    final verse = controller.selectedVerse.value;
    if (verse == null) return const SizedBox.shrink();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Center(
                child: CozyIconChip(
                  icon: HugeIcons.strokeRoundedBrain02,
                  background: CozyColors.primaryLight,
                  iconColor: CozyColors.ink,
                  size: 74,
                  iconSize: 36,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'prayer_completeMissing'.tr,
                textAlign: TextAlign.center,
                style: CozyText.title.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 28),

              // Verse with blank
              CozyCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verse.verseWithBlank,
                      style: CozyText.body.copyWith(fontSize: 18, height: 1.6),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '— ${verse.reference}',
                      style: CozyText.label.copyWith(
                        color: CozyColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              Text(
                'prayer_yourAnswer'.tr,
                style: CozyText.body.copyWith(color: CozyColors.inkMuted),
              ),
              const SizedBox(height: 10),

              FastTextInput(
                controller: controller.recitationTextController,
                hintText: 'prayer_typeMissing'.tr,
                textCapitalization: TextCapitalization.none,
                textStyle: CozyText.body.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                placeholderStyle: CozyText.body
                    .copyWith(fontSize: 18, color: CozyColors.inkMuted),
              ),
              const SizedBox(height: 16),

              // Hint toggle / display
              Obx(() {
                if (controller.showHint.value) {
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: ShapeDecoration(
                      color: CozyColors.warning.withValues(alpha: 0.12),
                      shape: CozyTokens.smooth(
                        CozyTokens.radiusSm,
                        side: BorderSide(
                          color: CozyColors.warning.withValues(alpha: 0.4),
                          width: CozyTokens.borderWidthThin,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedIdea01,
                          color: CozyColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Hint: ${verse.correctAnswer}',
                            style: CozyText.body.copyWith(
                              fontSize: 15,
                              color: CozyColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return CozyTappable(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.toggleHint();
                  },
                  pressedScale: 0.97,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'prayer_needHint'.tr,
                      style: CozyText.body.copyWith(color: CozyColors.primary),
                    ),
                  ),
                );
              }),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4: Complete — confetti celebration
// ─────────────────────────────────────────────────────────────────────────────

class _CompletionStep extends StatelessWidget {
  const _CompletionStep({required this.controller});
  final PrayerLearningController controller;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              // Victory heading
              Text(
                'prayer_wellDone'.tr,
                textAlign: TextAlign.center,
                style: CozyText.display.copyWith(color: CozyColors.primary),
              ),
              const SizedBox(height: 14),

              Text(
                'prayer_completedMessage'.tr,
                textAlign: TextAlign.center,
                style: CozyText.body.copyWith(
                  fontSize: 17,
                  height: 1.5,
                  color: CozyColors.inkMuted,
                ),
              ),
              const SizedBox(height: 40),

              // Score card
              CozyCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    Text(
                      'prayer_learningScore'.tr,
                      style: CozyText.label.copyWith(color: CozyColors.inkMuted),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                          '${(controller.completionScore.value * 100).toInt()}%',
                          style: CozyText.display.copyWith(
                            fontSize: 52,
                            color: CozyColors.primary,
                            letterSpacing: -1,
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedSquareUnlock02,
                    color: CozyColors.inkMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'prayer_chooseUnlockDuration'.tr,
                      textAlign: TextAlign.center,
                      style:
                          CozyText.body.copyWith(color: CozyColors.inkMuted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

    // Confetti only fires once the completion screen is actually visible —
    // i.e. after any badge dialog has been dismissed (see controller.showConfetti).
    return Obx(
      () => controller.showConfetti.value
          ? ConfettiCelebration(child: content)
          : content,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom actions bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.controller});
  final PrayerLearningController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canProceed = controller.canProceed;
      final isLastStep =
          controller.currentStep.value == controller.stepTitles.length - 1;

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: CozyColors.divider, width: 1.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLastStep) ...[
                CozyButton(
                  text: 'prayer_chooseUnlockBtn'.tr,
                  onTap: () async {
                    final duration =
                        await UnlockDurationDialog.show(context: Get.context!);
                    if (duration != null) {
                      final a = PostHogService.instance;
                      if (a.isReady) {
                        a.events.trackCustom('unlock_duration_selected', {
                          'duration_minutes': duration.inMinutes,
                        });
                      }
                      await controller.startUnlockTimer(duration);
                    }
                    Get.offAllNamed('/main');
                  },
                ),
              ] else ...[
                // Next / Submit button
                if (canProceed || controller.currentStep.value != 1)
                  CozyButton(
                    text: controller.currentStep.value == 2
                        ? 'prayer_submit'.tr
                        : 'onboarding_next'.tr,
                    isDisabled: !canProceed,
                    onTap: canProceed ? controller.nextStep : null,
                  ),

                // Skip anyway (meditation invalid)
                if (controller.canSkipMeditation) ...[
                  const SizedBox(height: 10),
                  CozyButton(
                    text: 'prayer_skipAnyway'.tr,
                    variant: CozyButtonVariant.secondary,
                    onTap: controller.nextStep,
                  ),
                ],
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Small tip info banner (light-bulb style), cozy soft card.
class _TipBanner extends StatelessWidget {
  const _TipBanner({required this.tip});
  final String tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: CozyColors.surfaceMuted,
        shape: CozyTokens.smooth(
          CozyTokens.radiusSm,
          side: const BorderSide(
            color: CozyColors.border,
            width: CozyTokens.borderWidthThin,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedIdea01,
            color: CozyColors.gold,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: CozyText.body.copyWith(
                fontSize: 14,
                color: CozyColors.inkMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
