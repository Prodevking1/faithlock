import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:faithlock/features/faithlock/services/export.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:faithlock/shared/widgets/notifications/fast_toast.dart';
import 'package:faithlock/shared/widgets/dialogs/fast_alert_dialog.dart';

/// Controller for Schedule Management Screen
/// Manages lock schedules from onboarding with DeviceActivity
class ScheduleController extends GetxController {
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  final StorageService _storage = StorageService();

  // Storage key for tracking if user has seen the app selection prompt
  static const String _keyHasSeenAppsPrompt = 'faithlock_has_seen_apps_prompt';
  static const String _keyOnboardingSchedules = 'onboarding_schedules';

  // Observable state
  final RxList<Map<String, dynamic>> schedules = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = RxBool(true);
  final RxString errorMessage = RxString('');
  final RxBool isScreenTimeAuthorized = RxBool(false);
  final RxString screenTimeStatus = RxString('Unknown');
  final RxInt selectedAppsCount = RxInt(0);

  @override
  void onInit() {
    super.onInit();
    // Load asynchronously without blocking
    Future.microtask(() async {
      await loadSchedules();
      await checkScreenTimeAuthorization();
      await _loadSelectedAppsCount();
      await _checkForSelectedApps();
    });
  }

  /// Load count of selected apps
  Future<void> _loadSelectedAppsCount() async {
    try {
      final hasApps = await _screenTimeService.hasSelectedApps();
      selectedAppsCount.value = hasApps ? 1 : 0;
    } catch (e) {
      selectedAppsCount.value = 0;
    }
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

      // Reload apps count after selection
      await _loadSelectedAppsCount();

      // Auto-setup DeviceActivity schedules from onboarding data
      await _setupSchedulesFromOnboarding();

      // Check if we're currently in an active schedule and apply blocking immediately
      await _checkAndApplyCurrentSchedule();

      // Show success message after selection
      if (context.mounted) {
        FastToast.showSuccess(
          context: context,
          title: 'Apps Selected & Locked',
          message: 'Your apps will be automatically blocked during scheduled times',
        );
      }
    } catch (e) {
      if (context.mounted) {
        FastToast.showError(
          context: context,
          title: 'Error',
          message: 'Failed to show app picker: $e',
        );
      }
    }
  }

  /// Setup DeviceActivity schedules from onboarding data
  Future<void> _setupSchedulesFromOnboarding() async {
    try {
      final schedulesJson = await _storage.readString('onboarding_schedules');

      if (schedulesJson == null || schedulesJson.isEmpty) {
        debugPrint('⚠️ No onboarding schedules found');
        return;
      }

      final List<dynamic> schedulesData = jsonDecode(schedulesJson);
      final List<Map<String, dynamic>> schedules =
          schedulesData.map((s) => Map<String, dynamic>.from(s)).toList();

      await _screenTimeService.setupSchedules(schedules);
      debugPrint('✅ DeviceActivity schedules setup successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to setup DeviceActivity schedules: $e');
    }
  }

  /// Load all schedules from onboarding data
  Future<void> loadSchedules() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final schedulesJson = await _storage.readString(_keyOnboardingSchedules);

      if (schedulesJson != null && schedulesJson.isNotEmpty) {
        final List<dynamic> schedulesData = jsonDecode(schedulesJson);
        schedules.value = schedulesData
            .map((s) => Map<String, dynamic>.from(s))
            .toList();
      } else {
        schedules.value = [];
      }
    } catch (e) {
      errorMessage.value = 'Failed to load schedules: $e';
      schedules.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle schedule enabled status
  Future<void> toggleScheduleEnabled(int index) async {
    final context = Get.context;
    if (context == null) return;

    try {
      // Create a new Map to force GetX to detect the change
      final updatedSchedule = Map<String, dynamic>.from(schedules[index]);
      updatedSchedule['enabled'] = !updatedSchedule['enabled'];

      // Replace the schedule in the list
      schedules[index] = updatedSchedule;

      // Force refresh
      schedules.refresh();

      await _saveAndResetupSchedules();

      if (context.mounted) {
        FastToast.showSuccess(
          context: context,
          message: 'Schedule updated successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        FastToast.showError(
          context: context,
          title: 'Error',
          message: 'Failed to update schedule: $e',
        );
      }
    }
  }

  /// Edit schedule time
  Future<void> editScheduleTime(int index, bool isStart) async {
    final context = Get.context;
    if (context == null) return;

    final currentHour = schedules[index][isStart ? 'startHour' : 'endHour'] as int;
    final currentMinute = schedules[index][isStart ? 'startMinute' : 'endMinute'] as int;

    DateTime selectedTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      currentHour,
      currentMinute,
    );

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Done button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () async {
                      // Create a new Map to force GetX to detect the change
                      final updatedSchedule = Map<String, dynamic>.from(schedules[index]);
                      updatedSchedule[isStart ? 'startHour' : 'endHour'] = selectedTime.hour;
                      updatedSchedule[isStart ? 'startMinute' : 'endMinute'] = selectedTime.minute;

                      // Replace the schedule in the list
                      schedules[index] = updatedSchedule;

                      // Force refresh
                      schedules.refresh();

                      Navigator.of(context).pop();

                      await _saveAndResetupSchedules();

                      if (context.mounted) {
                        FastToast.showSuccess(
                          context: context,
                          message: 'Schedule time updated',
                        );
                      }
                    },
                  ),
                ],
              ),
              // Time picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: selectedTime,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newTime) {
                    selectedTime = newTime;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Save and re-setup schedules
  Future<void> _saveAndResetupSchedules() async {
    try {
      // Save to storage
      await _storage.writeString(
        _keyOnboardingSchedules,
        jsonEncode(schedules),
      );

      // Re-setup DeviceActivity with enabled schedules
      await _screenTimeService.setupSchedules(schedules);

      // Debug: Print all schedules and their status
      debugPrint('📋 Checking schedules:');
      for (var s in schedules) {
        final enabled = s['enabled'] as bool;
        final isActive = isScheduleActive(s);
        debugPrint('   ${s['name']}: enabled=$enabled, active=$isActive');
      }

      // Check if there's an active schedule right now
      final activeSchedule = schedules.firstWhereOrNull(
        (s) => s['enabled'] == true && isScheduleActive(s)
      );

      if (activeSchedule != null) {
        // We're in an active schedule - apply blocking immediately
        debugPrint('🔒 Active schedule detected: ${activeSchedule['name']}');
        debugPrint('⚡ Applying blocking immediately...');
        await _screenTimeService.applyBlockingNow();
      } else {
        // No active schedule - remove blocking
        debugPrint('🔓 No active schedules - removing blocking');
        await _screenTimeService.stopBlocking();
      }

      debugPrint('✅ Schedules saved and re-setup successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to save/re-setup schedules: $e');
      rethrow;
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

  /// Format time from hours and minutes
  String formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Calculate schedule duration
  String getScheduleDuration(Map<String, dynamic> schedule) {
    final startHour = schedule['startHour'] as int;
    final startMinute = schedule['startMinute'] as int;
    final endHour = schedule['endHour'] as int;
    final endMinute = schedule['endMinute'] as int;

    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    var durationMinutes = endMinutes - startMinutes;
    if (durationMinutes < 0) durationMinutes += 24 * 60;

    final durationHours = (durationMinutes / 60).floor();
    final durationMins = durationMinutes % 60;

    return '${durationHours}h ${durationMins}m';
  }

  /// Check if schedule is currently active
  bool isScheduleActive(Map<String, dynamic> schedule) {
    if (!(schedule['enabled'] as bool)) return false;

    final now = DateTime.now();
    final startHour = schedule['startHour'] as int;
    final startMinute = schedule['startMinute'] as int;
    final endHour = schedule['endHour'] as int;
    final endMinute = schedule['endMinute'] as int;

    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    if (endMinutes > startMinutes) {
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    } else {
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    }
  }

  /// Refresh schedules
  Future<void> refreshSchedules() async {
    await loadSchedules();
  }

  /// Test blocking for 15 minutes (iOS minimum interval)
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

      // Create temporary test schedule (15 min minimum for iOS)
      final now = TimeOfDay.now();
      final endTime = TimeOfDay(
        hour: (now.hour + ((now.minute + 15) ~/ 60)) % 24,
        minute: (now.minute + 15) % 60,
      );

      final testSchedules = [
        {
          'name': 'Test_Lock',
          'icon': '🧪',
          'startHour': now.hour,
          'startMinute': now.minute,
          'endHour': endTime.hour,
          'endMinute': endTime.minute,
          'enabled': true,
        }
      ];

      // Setup test schedule
      await _screenTimeService.setupSchedules(testSchedules);

      if (context.mounted) {
        FastToast.showSuccess(
          context: context,
          title: 'Test Lock Active',
          message: 'Apps will be blocked for 15 minutes. Try opening a selected app.',
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      if (context.mounted) {
        FastToast.showError(
          context: context,
          title: 'Error',
          message: 'Failed to start test: ${e.toString().contains('intervalTooShort') ? 'iOS requires 15 min minimum' : e}',
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  /// Check if we're in an active schedule and apply blocking
  Future<void> _checkAndApplyCurrentSchedule() async {
    try {
      // Find any currently active schedule
      final activeSchedule = schedules.firstWhereOrNull(
        (schedule) => isScheduleActive(schedule),
      );

      if (activeSchedule != null) {
        debugPrint('🔒 Currently in active schedule: ${activeSchedule['name']}');
        debugPrint('⚡ Applying blocking immediately via native...');

        // Apply blocking through native DeviceActivity
        // The DeviceActivityMonitor will eventually take over, but we apply it now too
        await _screenTimeService.applyBlockingNow();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to check/apply current schedule: $e');
    }
  }

  /// Stop blocking immediately
  Future<void> stopBlockingNow() async {
    final context = Get.context;
    if (context == null) return;

    try {
      await _screenTimeService.stopBlocking();

      if (context.mounted) {
        FastToast.showInfo(
          context: context,
          title: 'Blocking Stopped',
          message: 'All restrictions have been removed',
        );
      }
    } catch (e) {
      if (context.mounted) {
        FastToast.showError(
          context: context,
          title: 'Error',
          message: 'Failed to stop blocking: $e',
        );
      }
    }
  }
}
