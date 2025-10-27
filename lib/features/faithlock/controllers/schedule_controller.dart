import 'dart:convert';

import 'package:faithlock/features/faithlock/controllers/faithlock_settings_controller.dart';
import 'package:faithlock/features/faithlock/services/export.dart';
import 'package:faithlock/navigation/controllers/navigation_controller.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:faithlock/shared/widgets/dialogs/fast_alert_dialog.dart';
import 'package:faithlock/shared/widgets/notifications/fast_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller for Schedule Management Screen
/// Manages lock schedules from onboarding with DeviceActivity
class ScheduleController extends GetxController with WidgetsBindingObserver {
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
    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Load asynchronously without blocking
    Future.microtask(() async {
      await loadSchedules();
      await checkScreenTimeAuthorization();
      await _loadSelectedAppsCount();
      await _checkForSelectedApps();
    });
  }

  @override
  void onClose() {
    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed - refreshing Screen Time permissions');
      checkScreenTimeAuthorization();
      _loadSelectedAppsCount();
      _checkScheduleEndedFlag();
    }
  }

  Future<void> _checkScheduleEndedFlag() async {
    try {
      final scheduleEnded = await _screenTimeService.checkScheduleEnded();
      if (scheduleEnded != null && scheduleEnded.isNotEmpty) {
        debugPrint('📋 Schedule ended: $scheduleEnded');
        await _screenTimeService.clearScheduleEndedFlag();

        final scheduleName = scheduleEnded.replaceAll('_', ' ');

        FastToast.info(
          'Schedule "$scheduleName" has ended. Apps are now unlocked.',
          title: 'Schedule Completed',
        );
      }
    } catch (e) {
      debugPrint('⚠️ Error checking schedule ended flag: $e');
    }
  }

  /// Load count of selected apps
  Future<void> _loadSelectedAppsCount() async {
    try {
      final count = await _screenTimeService.getSelectedAppsCount();
      selectedAppsCount.value = count;
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
      final hasSeenPrompt =
          await _storage.readBool(_keyHasSeenAppsPrompt) ?? false;
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
        FastToast.success('Screen Time access granted');
        // Refresh this controller
        await checkScreenTimeAuthorization();
        await _loadSelectedAppsCount();

        // Sync with other controllers if they exist
        _syncPermissionsWithOtherControllers();
      } else {
        FastToast.warning(
          'Please grant Screen Time access in Settings to use app blocking',
          title: 'Authorization Denied',
        );
      }
    } catch (e) {
      FastToast.error(
        'Failed to request authorization: $e',
        title: 'Error',
      );
    }
  }

  /// Sync permissions with other controllers to keep UI in sync
  void _syncPermissionsWithOtherControllers() {
    try {
      // Try to find and refresh FaithLockSettingsController if it exists
      if (Get.isRegistered<FaithLockSettingsController>()) {
        final faithLockController = Get.find<FaithLockSettingsController>();
        faithLockController.checkScreenTimePermission();
        faithLockController.loadSelectedAppsCount();
        debugPrint('✅ Synced permissions with FaithLockSettingsController');
      }
    } catch (e) {
      // Controller not registered yet, that's fine
      debugPrint('ℹ️ FaithLockSettingsController not registered: $e');
    }
  }

  /// Show app picker to select apps to block
  Future<void> selectAppsToBlock() async {
    final context = Get.context;
    if (context == null) return;

    try {
      if (!isScreenTimeAuthorized.value) {
        FastToast.warning(
          'Please authorize Screen Time access first',
          title: 'Authorization Required',
        );
        return;
      }

      await _screenTimeService.presentAppPicker();
      await _loadSelectedAppsCount();

      try {
        final settingsController = Get.find<FaithLockSettingsController>();
        await settingsController.loadSelectedAppsCount();
      } catch (e) {}

      if (selectedAppsCount.value > 0) {
        await loadSchedules();
        await _setupSchedulesFromOnboarding();

        final hasActiveSchedule = schedules.any((s) {
          if (s['enabled'] != true) return false;

          final currentTime = TimeOfDay.now();
          final currentMinutes = currentTime.hour * 60 + currentTime.minute;

          final startHour = s['startHour'] as int;
          final startMinute = s['startMinute'] as int;
          final endHour = s['endHour'] as int;
          final endMinute = s['endMinute'] as int;

          final startMinutes = startHour * 60 + startMinute;
          final endMinutes = endHour * 60 + endMinute;

          if (endMinutes < startMinutes) {
            return currentMinutes >= startMinutes ||
                currentMinutes < endMinutes;
          }

          return currentMinutes >= startMinutes && currentMinutes < endMinutes;
        });

        if (hasActiveSchedule) {
          try {
            await _screenTimeService.applyBlockingNow();
            debugPrint(
                '✅ Applied blocking immediately - currently in active schedule');
          } catch (e) {
            debugPrint('⚠️ Failed to apply immediate blocking: $e');
          }
        }

        final enabledCount =
            schedules.where((s) => s['enabled'] == true).length;

        if (enabledCount > 0) {
          FastToast.success(
            'Your apps will be automatically blocked during scheduled times',
            title: 'Apps Selected & Locked',
          );
        } else {
          FastToast.info(
            'Apps selected. Enable at least one schedule to activate blocking.',
            title: 'Apps Selected',
          );
        }
      } else {
        FastToast.info(
          'Select apps to enable blocking',
          title: 'No Apps Selected',
        );
      }
    } catch (e) {
      debugPrint('❌ Error in selectAppsToBlock: $e');
      // Only show toast if we have a valid context with overlay
      try {
        FastToast.error(
          'Failed to show app picker: $e',
          title: 'Error',
        );
      } catch (toastError) {
        debugPrint('⚠️ Could not show error toast: $toastError');
      }
    }
  }

  /// Setup DeviceActivity schedules from loaded schedule data
  Future<void> _setupSchedulesFromOnboarding() async {
    try {
      // ✅ Use local schedules list (should be loaded before calling this)
      if (schedules.isEmpty) {
        debugPrint('⚠️ No schedules available to setup');
        return;
      }

      // ✅ Only send ENABLED schedules to native side
      final enabledSchedules =
          schedules.where((s) => s['enabled'] == true).toList();

      await _screenTimeService.setupSchedules(enabledSchedules);
      debugPrint(
          '✅ DeviceActivity schedules setup successfully (${enabledSchedules.length} enabled out of ${schedules.length} total)');
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
        schedules.value =
            schedulesData.map((s) => Map<String, dynamic>.from(s)).toList();
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
      final schedule = schedules[index];
      final willBeEnabled = !(schedule['enabled'] as bool);

      if (willBeEnabled) {
        // Check if apps are selected
        if (selectedAppsCount.value == 0) {
          final result = await FastAlertDialog.show(
            context: context,
            title: 'No Apps Selected',
            message:
                'You need to select apps to block first. Go to Profile tab to select apps.',
            actions: [
              FastDialogAction(
                text: 'Cancel',
                isCancel: true,
                onPressed: () => Navigator.pop(context, false),
              ),
              FastDialogAction(
                text: 'Go to Profile',
                isDefault: true,
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          );

          if (result == true) {
            // Navigate to profile tab (index 3)
            Get.back(); // Go back to main screen
            try {
              final navController = Get.find<NavigationController>();
              navController.changePage(3); // Profile tab
            } catch (e) {
              debugPrint('⚠️ Navigation controller not found: $e');
            }
          }
          return;
        }

        final isActive = isScheduleActive(schedule);
        if (isActive) {
          final scheduleName = schedule['name'] as String;

          final confirmed = await FastAlertDialog.show(
            context: context,
            title: 'Block Apps Now?',
            message:
                '"$scheduleName" is currently active. Your apps will be blocked immediately.',
            actions: [
              FastDialogAction(
                text: 'Cancel',
                isCancel: true,
                onPressed: () => Navigator.pop(context, false),
              ),
              FastDialogAction(
                text: 'Block Now',
                isDefault: true,
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          );

          if (confirmed != true) return;
        }
      }

      final updatedSchedule = Map<String, dynamic>.from(schedules[index]);
      updatedSchedule['enabled'] = !updatedSchedule['enabled'];

      schedules[index] = updatedSchedule;
      schedules.refresh();

      await _saveAndResetupSchedules();

      FastToast.success('Schedule updated successfully');
    } catch (e) {
      FastToast.error(
        'Failed to update schedule: $e',
        title: 'Error',
      );
    }
  }

  /// Edit schedule time
  Future<void> editScheduleTime(int index, bool isStart) async {
    final context = Get.context;
    if (context == null) return;

    final currentHour =
        schedules[index][isStart ? 'startHour' : 'endHour'] as int;
    final currentMinute =
        schedules[index][isStart ? 'startMinute' : 'endMinute'] as int;

    DateTime selectedTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      currentHour,
      currentMinute,
    );

    await showCupertinoModalPopup<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
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
                      final updatedSchedule =
                          Map<String, dynamic>.from(schedules[index]);
                      updatedSchedule[isStart ? 'startHour' : 'endHour'] =
                          selectedTime.hour;
                      updatedSchedule[isStart ? 'startMinute' : 'endMinute'] =
                          selectedTime.minute;

                      // Replace the schedule in the list
                      schedules[index] = updatedSchedule;

                      // Force refresh
                      schedules.refresh();

                      Navigator.of(context).pop();

                      await _saveAndResetupSchedules();

                      FastToast.success('Schedule time updated');
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

      // ✅ Re-setup DeviceActivity with ONLY enabled schedules
      final enabledSchedules =
          schedules.where((s) => s['enabled'] == true).toList();
      await _screenTimeService.setupSchedules(enabledSchedules);

      // Debug: Print all schedules and their status
      debugPrint('📋 Schedules re-setup:');
      for (var s in schedules) {
        final enabled = s['enabled'] as bool;
        final isActive = isScheduleActive(s);
        debugPrint('   ${s['name']}: enabled=$enabled, active=$isActive');
      }

      // ❌ REMOVED: No immediate blocking/unblocking
      // DeviceActivityMonitor will automatically handle blocking based on schedules

      debugPrint(
          '✅ Schedules saved and re-setup successfully (${enabledSchedules.length} enabled)');
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

  Future<void> refreshSchedules() async {
    await loadSchedules();
    await _loadSelectedAppsCount();
  }

  /// Test blocking for 15 minutes (iOS minimum interval)
  Future<void> testBlockingNow() async {
    final context = Get.context;
    if (context == null) return;

    try {
      if (!isScreenTimeAuthorized.value) {
        FastToast.warning(
          'Please grant Screen Time access first',
          title: 'Authorization Required',
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

      // ✅ Using Get.context for custom duration toast
      final ctx = Get.context;
      if (ctx != null) {
        FastToast.showSuccess(
          context: ctx,
          title: 'Test Lock Active',
          message:
              'Apps will be blocked for 15 minutes. Try opening a selected app.',
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      final ctx = Get.context;
      if (ctx != null) {
        FastToast.showError(
          context: ctx,
          title: 'Error',
          message:
              'Failed to start test: ${e.toString().contains('intervalTooShort') ? 'iOS requires 15 min minimum' : e}',
          duration: const Duration(seconds: 5),
        );
      }
    }
  }
}
