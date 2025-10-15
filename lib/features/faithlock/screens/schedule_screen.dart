import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:faithlock/core/constants/core/fast_spacing.dart';
import 'package:faithlock/features/faithlock/controllers/schedule_controller.dart';
import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Schedule Management Screen
/// Create, edit, and manage lock schedules
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

          // Always show the layout with Screen Time card
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
                          Row(
                            children: [
                              Expanded(
                                child: FastButton(
                                  text: 'Grant Access',
                                  onTap:
                                      controller.requestScreenTimeAuthorization,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Text(
                            'Test app blocking before creating schedules',
                            style: TextStyle(
                              color: FastColors.secondaryText(context),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FastButton(
                                  text: 'Test Lock (1 min)',
                                  style: FastButtonStyle.outlined,
                                  onTap: controller.testBlockingNow,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FastButton(
                                  text: 'Stop Lock',
                                  style: FastButtonStyle.destructive,
                                  onTap: controller.stopBlockingNow,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            color: FastColors.separator(context),
                            height: 1,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Configure blocked apps in iOS Settings > Screen Time',
                            style: TextStyle(
                              color: FastColors.tertiaryText(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )),
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
                                'No schedules yet',
                                style: TextStyle(
                                  color: FastColors.primaryText(context),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              FastSpacing.h16,
                              Text(
                                'Create a schedule to automatically lock your device at specific times',
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
                                      : FastColors.border(context),
                                  width: isActive ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header row (name + type + toggle)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              schedule.name,
                                              style: TextStyle(
                                                color: FastColors.primaryText(
                                                    context),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getScheduleTypeColor(
                                                        schedule.type)
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                controller.getScheduleTypeLabel(
                                                    schedule.type),
                                                style: TextStyle(
                                                  color: _getScheduleTypeColor(
                                                      schedule.type),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CupertinoSwitch(
                                        value: schedule.isEnabled,
                                        activeTrackColor: FastColors.primary,
                                        onChanged: (_) => controller
                                            .toggleScheduleEnabled(schedule),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Divider(
                                    color: FastColors.separator(context),
                                    height: 1,
                                  ),
                                  const SizedBox(height: 12),
                                  // Time and days
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color:
                                            FastColors.secondaryText(context),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${controller.formatTimeOfDay(schedule.startTime)} - ${controller.formatTimeOfDay(schedule.endTime)}',
                                        style: TextStyle(
                                          color:
                                              FastColors.secondaryText(context),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color:
                                            FastColors.secondaryText(context),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        controller
                                            .getDayNames(schedule.daysOfWeek),
                                        style: TextStyle(
                                          color:
                                              FastColors.secondaryText(context),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Next trigger
                                  if (schedule.isEnabled) ...[
                                    Row(
                                      children: [
                                        Icon(
                                          isActive
                                              ? Icons.lock
                                              : Icons.notifications_active,
                                          size: 16,
                                          color: isActive
                                              ? FastColors.primary
                                              : FastColors.info,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          controller
                                              .getNextTriggerText(schedule),
                                          style: TextStyle(
                                            color: isActive
                                                ? FastColors.primary
                                                : FastColors.info,
                                            fontSize: 14,
                                            fontWeight: isActive
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  // Action buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FastButton(
                                          text: 'Edit',
                                          style: FastButtonStyle.outlined,
                                          onTap: () => _showScheduleForm(
                                            context,
                                            controller,
                                            schedule: schedule,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: FastButton(
                                          text: 'Delete',
                                          style: FastButtonStyle.destructive,
                                          onTap: () => _confirmDelete(
                                            context,
                                            controller,
                                            schedule,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Add button
              Padding(
                padding: const EdgeInsets.all(16),
                child: FastButton(
                  text: 'Create Schedule',
                  onTap: () => _showScheduleForm(context, controller),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Show schedule form dialog
  void _showScheduleForm(
    BuildContext context,
    ScheduleController controller, {
    LockSchedule? schedule,
  }) {
    final isEditing = schedule != null;

    // Form state
    final nameController = TextEditingController(text: schedule?.name ?? '');
    final selectedType = (schedule?.type ?? ScheduleType.daily).obs;
    final selectedDays =
        (schedule?.daysOfWeek ?? List.generate(7, (i) => i + 1)).obs;
    final startTime =
        (schedule?.startTime ?? const TimeOfDay(hour: 22, minute: 0)).obs;
    final endTime =
        (schedule?.endTime ?? const TimeOfDay(hour: 6, minute: 0)).obs;

    Get.dialog(
      Dialog(
        backgroundColor: FastColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                isEditing ? 'Edit Schedule' : 'Create Schedule',
                style: TextStyle(
                  color: FastColors.primaryText(context),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FastSpacing.h24,

              // Schedule Name
              TextField(
                controller: nameController,
                style: TextStyle(color: FastColors.primaryText(context)),
                decoration: InputDecoration(
                  labelText: 'Schedule Name',
                  labelStyle:
                      TextStyle(color: FastColors.secondaryText(context)),
                  hintText: 'e.g., Morning Prayer Time',
                  hintStyle: TextStyle(color: FastColors.tertiaryText(context)),
                  filled: true,
                  fillColor: FastColors.surfaceVariant(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              FastSpacing.h16,

              // Schedule Type
              Text(
                'Schedule Type',
                style: TextStyle(
                  color: FastColors.secondaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              FastSpacing.h8,
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ScheduleType.values.map((type) {
                      final isSelected = selectedType.value == type;
                      return GestureDetector(
                        onTap: () => selectedType.value = type,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? FastColors.primary
                                : FastColors.surfaceVariant(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            controller.getScheduleTypeLabel(type),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : FastColors.secondaryText(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              FastSpacing.h16,

              // Time Selection
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Time',
                          style: TextStyle(
                            color: FastColors.secondaryText(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        FastSpacing.h8,
                        Obx(() => GestureDetector(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: startTime.value,
                                );
                                if (time != null) startTime.value = time;
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: FastColors.surfaceVariant(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: FastColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      controller
                                          .formatTimeOfDay(startTime.value),
                                      style: TextStyle(
                                        color: FastColors.primaryText(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Time',
                          style: TextStyle(
                            color: FastColors.secondaryText(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        FastSpacing.h8,
                        Obx(() => GestureDetector(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: endTime.value,
                                );
                                if (time != null) endTime.value = time;
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: FastColors.surfaceVariant(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: FastColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      controller.formatTimeOfDay(endTime.value),
                                      style: TextStyle(
                                        color: FastColors.primaryText(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              FastSpacing.h16,

              // Days of Week
              Text(
                'Active Days',
                style: TextStyle(
                  color: FastColors.secondaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              FastSpacing.h8,
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                        .asMap()
                        .entries
                        .map((entry) {
                      final dayNumber = entry.key + 1;
                      final isSelected = selectedDays.contains(dayNumber);
                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            selectedDays.remove(dayNumber);
                          } else {
                            selectedDays.add(dayNumber);
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? FastColors.primary
                                : FastColors.surfaceVariant(context),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : FastColors.secondaryText(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              FastSpacing.h24,

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: FastButton(
                      text: 'Cancel',
                      style: FastButtonStyle.outlined,
                      onTap: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FastButton(
                      text: isEditing ? 'Save' : 'Create',
                      onTap: () {
                        if (nameController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please enter a schedule name',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: FastColors.error,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (selectedDays.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please select at least one day',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: FastColors.error,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (isEditing) {
                          controller.updateSchedule(
                            id: schedule.id,
                            name: nameController.text.trim(),
                            type: selectedType.value,
                            startTime: startTime.value,
                            endTime: endTime.value,
                            daysOfWeek: selectedDays.toList()..sort(),
                            isEnabled: schedule.isEnabled,
                          );
                        } else {
                          controller.createSchedule(
                            name: nameController.text.trim(),
                            type: selectedType.value,
                            startTime: startTime.value,
                            endTime: endTime.value,
                            daysOfWeek: selectedDays.toList()..sort(),
                          );
                        }

                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Confirm delete dialog
  void _confirmDelete(
    BuildContext context,
    ScheduleController controller,
    LockSchedule schedule,
  ) {
    Get.defaultDialog(
      title: 'Delete Schedule',
      titleStyle: TextStyle(color: FastColors.primaryText(context)),
      backgroundColor: FastColors.surface(context),
      middleText: 'Are you sure you want to delete "${schedule.name}"?',
      middleTextStyle: TextStyle(color: FastColors.secondaryText(context)),
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: FastColors.error,
      onConfirm: () {
        Get.back();
        controller.deleteSchedule(schedule.id);
      },
    );
  }

  /// Get schedule type color
  Color _getScheduleTypeColor(ScheduleType type) {
    switch (type) {
      case ScheduleType.daily:
        return const Color(0xFF03A9F4);
      case ScheduleType.bedtime:
        return const Color(0xFF9C27B0);
      case ScheduleType.workHours:
        return const Color(0xFF2196F3);
      case ScheduleType.mealTime:
        return const Color(0xFF4CAF50);
      case ScheduleType.custom:
        return const Color(0xFF607D8B);
    }
  }
}
