import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:faithlock/core/constants/core/fast_spacing.dart';
import 'package:faithlock/features/faithlock/controllers/schedule_controller.dart';
import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Schedule Management Screen
/// Manage lock schedules from onboarding
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScheduleController());

    return Scaffold(
      backgroundColor: FastColors.surface(context),
      appBar: AppBar(
        title: Text(
          'Lock Schedules',
          style: TextStyle(
            color: FastColors.primaryText(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: FastColors.surface(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: FastColors.primaryText(context),
            ),
            onPressed: controller.refreshSchedules,
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // Loading state
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: FastColors.primary,
              ),
            );
          }

          // Error state
          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: FastColors.error,
                  ),
                  FastSpacing.h16,
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      color: FastColors.secondaryText(context),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  FastSpacing.h24,
                  FastButton(
                    text: 'Retry',
                    onTap: controller.loadSchedules,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Screen Time authorization card
              Obx(() => Container(
                    margin: FastSpacing.px16,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: controller.isScreenTimeAuthorized.value
                          ? FastColors.successGreenLight
                          : FastColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.isScreenTimeAuthorized.value
                            ? FastColors.successGreen
                            : FastColors.warning,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              controller.isScreenTimeAuthorized.value
                                  ? Icons.check_circle
                                  : Icons.warning_amber,
                              color: controller.isScreenTimeAuthorized.value
                                  ? FastColors.successGreen
                                  : FastColors.warning,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Screen Time Status',
                                style: TextStyle(
                                  color: FastColors.primaryText(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              controller.screenTimeStatus.value,
                              style: TextStyle(
                                color: FastColors.secondaryText(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (!controller.isScreenTimeAuthorized.value) ...[
                          Text(
                            'Grant Screen Time access to block apps during schedules',
                            style: TextStyle(
                              color: FastColors.secondaryText(context),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FastButton(
                            text: 'Grant Access',
                            onTap: controller.requestScreenTimeAuthorization,
                          ),
                        ] else ...[
                          Text(
                            'Select apps to block during scheduled times',
                            style: TextStyle(
                              color: FastColors.secondaryText(context),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FastButton(
                            text: 'Select Apps',
                            onTap: controller.selectAppsToBlock,
                          ),
                        ],
                      ],
                    ),
                  )),
              FastSpacing.h24,

              // Schedules list
              Expanded(
                child: controller.schedules.isEmpty
                    ? Center(
                        child: Padding(
                          padding: FastSpacing.px24,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 80,
                                color: FastColors.disabled(context),
                              ),
                              FastSpacing.h24,
                              Text(
                                'No schedules found',
                                style: TextStyle(
                                  color: FastColors.primaryText(context),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              FastSpacing.h16,
                              Text(
                                'Complete the onboarding to set up your lock schedules',
                                style: TextStyle(
                                  color: FastColors.secondaryText(context),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: FastSpacing.px16,
                        itemCount: controller.schedules.length,
                        itemBuilder: (context, index) {
                          final schedule = controller.schedules[index];
                          final isActive =
                              controller.isScheduleActive(schedule);
                          final isEnabled = schedule['enabled'] as bool;
                          final name = schedule['name'] as String;
                          final icon = schedule['icon'] as String;
                          final startHour = schedule['startHour'] as int;
                          final startMinute = schedule['startMinute'] as int;
                          final endHour = schedule['endHour'] as int;
                          final endMinute = schedule['endMinute'] as int;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? FastColors.primary.withValues(alpha: 0.1)
                                    : FastColors.surfaceVariant(context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActive
                                      ? FastColors.primary
                                      : isEnabled
                                          ? OnboardingTheme.goldColor
                                              .withValues(alpha: 0.3)
                                          : FastColors.border(context),
                                  width: isActive ? 2 : 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header row
                                  Row(
                                    children: [
                                      Text(
                                        icon,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: TextStyle(
                                                color: FastColors.primaryText(
                                                    context),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              controller.getScheduleDuration(
                                                  schedule),
                                              style: TextStyle(
                                                color: FastColors.secondaryText(
                                                    context),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CupertinoSwitch(
                                        value: isEnabled,
                                        activeTrackColor:
                                            OnboardingTheme.goldColor,
                                        onChanged: (_) => controller
                                            .toggleScheduleEnabled(index),
                                      ),
                                    ],
                                  ),

                                  if (isEnabled) ...[
                                    const SizedBox(height: 12),
                                    Divider(
                                      color: FastColors.separator(context),
                                      height: 1,
                                    ),
                                    const SizedBox(height: 12),

                                    // Time display
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => controller
                                                .editScheduleTime(index, true),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                color: OnboardingTheme
                                                    .backgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: OnboardingTheme
                                                      .goldColor
                                                      .withValues(alpha: 0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Start',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: FastColors
                                                          .tertiaryText(
                                                              context),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    controller.formatTime(
                                                        startHour, startMinute),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: OnboardingTheme
                                                          .goldColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Text(
                                            '→',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: FastColors.tertiaryText(
                                                  context),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => controller
                                                .editScheduleTime(index, false),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                color: OnboardingTheme
                                                    .backgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: OnboardingTheme
                                                      .goldColor
                                                      .withValues(alpha: 0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'End',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: FastColors
                                                          .tertiaryText(
                                                              context),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    controller.formatTime(
                                                        endHour, endMinute),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: OnboardingTheme
                                                          .goldColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Active status
                                    if (isActive) ...[
                                      const SizedBox(height: 12),
                                      Obx(() => Row(
                                            children: [
                                              Icon(
                                                controller.isScreenTimeAuthorized
                                                            .value &&
                                                        controller
                                                                .selectedAppsCount
                                                                .value >
                                                            0
                                                    ? Icons.lock
                                                    : Icons.schedule,
                                                size: 16,
                                                color: controller
                                                            .isScreenTimeAuthorized
                                                            .value &&
                                                        controller
                                                                .selectedAppsCount
                                                                .value >
                                                            0
                                                    ? FastColors.primary
                                                    : FastColors.warning,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  controller.isScreenTimeAuthorized
                                                              .value &&
                                                          controller
                                                                  .selectedAppsCount
                                                                  .value >
                                                              0
                                                      ? 'Active now - Apps are blocked'
                                                      : 'Active period - Select apps to start blocking',
                                                  style: TextStyle(
                                                    color: controller
                                                                .isScreenTimeAuthorized
                                                                .value &&
                                                            controller
                                                                    .selectedAppsCount
                                                                    .value >
                                                                0
                                                        ? FastColors.primary
                                                        : FastColors.warning,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
