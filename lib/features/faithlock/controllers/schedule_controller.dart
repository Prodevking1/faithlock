import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/faithlock/services/export.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:faithlock/shared/widgets/notifications/fast_toast.dart';
import 'package:faithlock/shared/widgets/dialogs/fast_alert_dialog.dart';

/// Controller for Schedule Management Screen
/// Manages creating, editing, and deleting lock schedules
class ScheduleController extends GetxController {
  final LockService _lockService = LockService();
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  final StorageService _storage = StorageService();

  // Storage key for tracking if user has seen the app selection prompt
  static const String _keyHasSeenAppsPrompt = 'faithlock_has_seen_apps_prompt';

  // Observable state
  final RxList<LockSchedule> schedules = <LockSchedule>[].obs;
  final RxBool isLoading = RxBool(true);
  final RxString errorMessage = RxString('');
  final RxBool isScreenTimeAuthorized = RxBool(false);
  final RxString screenTimeStatus = RxString('Unknown');

  @override
  void onInit() {
    super.onInit();
    loadSchedules();
    checkScreenTimeAuthorization();
    _checkForSelectedApps();
  }

  /// Check if apps have been selected, prompt if not
  Future<void> _checkForSelectedApps() async {
    try {
      // Wait a bit for UI to settle
      await Future.delayed(const Duration(seconds: 1));

      final isAuth = await _screenTimeService.isAuthorized();
      if (!isAuth) return; // Don't prompt if not authorized

      // Check if user has already seen this prompt
      final hasSeenPrompt = await _storage.readBool(_keyHasSeenAppsPrompt) ?? false;
      if (hasSeenPrompt) return; // Don't show again if already dismissed

      final hasApps = await _screenTimeService.hasSelectedApps();
      if (!hasApps) {
        _showSelectAppsPrompt();
      } else {
        // User has apps selected, mark prompt as seen
        await _storage.writeBool(_keyHasSeenAppsPrompt, true);
      }
    } catch (e) {
      debugPrint('Error checking for selected apps: $e');
    }
  }

  /// Show prompt to select apps
  void _showSelectAppsPrompt() {
    final context = Get.context;
    if (context == null) return;

    FastAlertDialog.show(
      context: context,
      title: 'Select Apps to Block',
      message:
          'To make FaithLock work, you need to select which apps should be blocked during lock times.\n\n'
          'Tap "Select Apps" below to choose the apps you want to block.',
      actions: [
        FastDialogAction(
          text: 'Later',
          isCancel: true,
          onPressed: () async {
            Navigator.pop(context);
            // Mark as seen so we don't show again
            await _storage.writeBool(_keyHasSeenAppsPrompt, true);
          },
        ),
        FastDialogAction(
          text: 'Select Apps',
          isDefault: true,
          onPressed: () async {
            Navigator.pop(context);
            // Mark as seen
            await _storage.writeBool(_keyHasSeenAppsPrompt, true);
            await selectAppsToBlock();
          },
        ),
      ],
    );
  }

  /// Check Screen Time authorization status
  Future<void> checkScreenTimeAuthorization() async {
    try {
      final isAuth = await _screenTimeService.isAuthorized();
      final status = await _screenTimeService.getAuthorizationStatusText();

      isScreenTimeAuthorized.value = isAuth;
      screenTimeStatus.value = status;
    } catch (e) {
      screenTimeStatus.value = 'Error';
    }
  }

  /// Request Screen Time authorization
  Future<void> requestScreenTimeAuthorization() async {
    final context = Get.context;
    if (context == null) return;

    try {
      final granted = await _screenTimeService.requestAuthorization();

      if (granted) {
        FastToast.showSuccess(
          context: context,
          message: 'Screen Time access granted',
        );
        await checkScreenTimeAuthorization();
      } else {
        FastToast.showWarning(
          context: context,
          title: 'Authorization Denied',
          message: 'Please grant Screen Time access in Settings to use app blocking',
        );
      }
    } catch (e) {
      FastToast.showError(
        context: context,
        title: 'Error',
        message: 'Failed to request authorization: $e',
      );
    }
  }

  /// Show app picker to select apps to block
  Future<void> selectAppsToBlock() async {
    final context = Get.context;
    if (context == null) return;

    try {
      if (!isScreenTimeAuthorized.value) {
        FastToast.showWarning(
          context: context,
          title: 'Authorization Required',
          message: 'Please authorize Screen Time access first',
        );
        return;
      }

      // Present the native FamilyActivityPicker
      await _screenTimeService.presentAppPicker();

      // Show success message after selection
      FastToast.showSuccess(
        context: context,
        title: 'Apps Selected',
        message: 'Your selected apps will be blocked during lock times',
      );
    } catch (e) {
      FastToast.showError(
        context: context,
        title: 'Error',
        message: 'Failed to show app picker: $e',
      );
    }
  }

  /// Load all schedules
  Future<void> loadSchedules() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final allSchedules = await _lockService.getAllSchedules();
      schedules.value = allSchedules;
    } catch (e) {
      errorMessage.value = 'Failed to load schedules: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle schedule enabled status
  Future<void> toggleScheduleEnabled(LockSchedule schedule) async {
    final context = Get.context;
    if (context == null) return;

    try {
      final updatedSchedule = LockSchedule(
        id: schedule.id,
        name: schedule.name,
        startTime: schedule.startTime,
        endTime: schedule.endTime,
        daysOfWeek: schedule.daysOfWeek,
        isEnabled: !schedule.isEnabled,
        type: schedule.type,
        createdAt: schedule.createdAt,
      );

      await _lockService.updateSchedule(updatedSchedule);
      await loadSchedules();
    } catch (e) {
      FastToast.showError(
        context: context,
        title: 'Error',
        message: 'Failed to update schedule: $e',
      );
    }
  }

  /// Delete schedule
  Future<void> deleteSchedule(String scheduleId) async {
    final context = Get.context;
    if (context == null) return;

    try {
      await _lockService.deleteSchedule(scheduleId);
      schedules.removeWhere((s) => s.id == scheduleId);

      FastToast.showSuccess(
        context: context,
        message: 'Schedule deleted successfully',
      );
    } catch (e) {
      FastToast.showError(
        context: context,
        title: 'Error',
        message: 'Failed to delete schedule: $e',
      );
    }
  }

  /// Create new schedule
  Future<void> createSchedule({
    required String name,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<int> daysOfWeek,
    required ScheduleType type,
  }) async {
    final context = Get.context;
    if (context == null) return;

    try {
      final schedule = LockSchedule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        startTime: startTime,
        endTime: endTime,
        daysOfWeek: daysOfWeek,
        isEnabled: true,
        type: type,
        createdAt: DateTime.now(),
      );

      await _lockService.createSchedule(schedule);
      await loadSchedules();

      Get.back();
      FastToast.showSuccess(
        context: context,
        message: 'Schedule created successfully',
      );
    } catch (e) {
      FastToast.showError(
        context: context,
        title: 'Error',
        message: 'Failed to create schedule: $e',
      );
    }
  }

  /// Update existing schedule
  Future<void> updateSchedule({
    required String id,
    required String name,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<int> daysOfWeek,
    required bool isEnabled,
    required ScheduleType type,
  }) async {
    final context = Get.context;
    if (context == null) return;

    try {
      final schedule = LockSchedule(
        id: id,
        name: name,
        startTime: startTime,
        endTime: endTime,
        daysOfWeek: daysOfWeek,
        isEnabled: isEnabled,
        type: type,
        createdAt: DateTime.now(),
      );

      await _lockService.updateSchedule(schedule);
      await loadSchedules();

      Get.back();
      FastToast.showSuccess(
        context: context,
        message: 'Schedule updated successfully',
      );
    } catch (e) {
      FastToast.showError(
        context: context,
        title: 'Error',
        message: 'Failed to update schedule: $e',
      );
    }
  }

  /// Get formatted time string
  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get day names from day numbers
  String getDayNames(List<int> days) {
    if (days.length == 7) return 'Every day';

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => dayNames[d - 1]).join(', ');
  }

  /// Get schedule type label
  String getScheduleTypeLabel(ScheduleType type) {
    switch (type) {
      case ScheduleType.daily:
        return 'Daily';
      case ScheduleType.bedtime:
        return 'Bedtime';
      case ScheduleType.workHours:
        return 'Work Hours';
      case ScheduleType.mealTime:
        return 'Meal Time';
      case ScheduleType.custom:
        return 'Custom';
    }
  }

  /// Check if schedule is currently active
  bool isScheduleActive(LockSchedule schedule) {
    return schedule.isActiveNow();
  }

  /// Get next trigger time for schedule
  String getNextTriggerText(LockSchedule schedule) {
    if (!schedule.isEnabled) return 'Disabled';
    if (schedule.isActiveNow()) return 'Active now';

    // Simple next trigger logic
    final now = DateTime.now();
    final currentDay = now.weekday;

    // Find next occurrence
    for (int i = 0; i <= 7; i++) {
      final checkDay = ((currentDay - 1 + i) % 7) + 1;
      if (schedule.daysOfWeek.contains(checkDay)) {
        if (i == 0) {
          // Today - check if start time is in future
          final startMinutes = schedule.startTime.hour * 60 + schedule.startTime.minute;
          final nowMinutes = now.hour * 60 + now.minute;
          if (startMinutes > nowMinutes) {
            return 'Today at ${formatTimeOfDay(schedule.startTime)}';
          }
        } else if (i == 1) {
          return 'Tomorrow at ${formatTimeOfDay(schedule.startTime)}';
        } else {
          const dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return '${dayNames[checkDay]} at ${formatTimeOfDay(schedule.startTime)}';
        }
      }
    }

    return 'Not scheduled';
  }

  /// Refresh schedules
  Future<void> refreshSchedules() async {
    await loadSchedules();
  }

  /// Test blocking for 1 minute (for testing purposes)
  Future<void> testBlockingNow() async {
    final context = Get.context;
    if (context == null) return;

    try {
      if (!isScreenTimeAuthorized.value) {
        FastToast.showWarning(
          context: context,
          title: 'Authorization Required',
          message: 'Please grant Screen Time access first',
        );
        return;
      }

      // Create a test schedule that starts now and lasts 1 minute
      final now = TimeOfDay.now();
      final endTime = TimeOfDay(
        hour: (now.hour + ((now.minute + 1) ~/ 60)) % 24,
        minute: (now.minute + 1) % 60,
      );

      final testSchedule = LockSchedule(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Lock (1 minute)',
        startTime: now,
        endTime: endTime,
        daysOfWeek: [DateTime.now().weekday],
        isEnabled: true,
        type: ScheduleType.custom,
        createdAt: DateTime.now(),
      );

      // Start blocking with the test schedule
      await _screenTimeService.startBlocking(schedule: testSchedule);

      FastToast.showSuccess(
        context: context,
        title: 'Test Lock Active',
        message: 'Apps will be blocked for 1 minute. Check if restrictions are applied.',
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      FastToast.showError(
        context: context,
        title: 'Error',
        message: 'Failed to start test blocking: $e',
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Stop blocking immediately
  Future<void> stopBlockingNow() async {
    final context = Get.context;
    if (context == null) return;

    try {
      await _screenTimeService.stopBlocking();

      FastToast.showInfo(
        context: context,
        title: 'Blocking Stopped',
        message: 'All restrictions have been removed',
      );
    } catch (e) {
      FastToast.showError(
        context: context,
        title: 'Error',
        message: 'Failed to stop blocking: $e',
      );
    }
  }
}
