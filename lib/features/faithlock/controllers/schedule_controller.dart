import 'dart:async';
import 'dart:convert';

import 'package:faithlock/features/faithlock/controllers/faithlock_settings_controller.dart';
import 'package:faithlock/features/faithlock/services/export.dart';
import 'package:faithlock/navigation/controllers/navigation_controller.dart';
import 'package:faithlock/services/analytics/posthog/export.dart';
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
  final PostHogService _analytics = PostHogService.instance;

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

  // Timer for periodic schedule checks
  Timer? _scheduleCheckTimer;

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

      // Start periodic check for schedule changes (every minute)
      _startScheduleMonitoring();
    });
  }

  @override
  void onClose() {
    // Cancel timer
    _scheduleCheckTimer?.cancel();

    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// Start monitoring schedules for active state changes
  void _startScheduleMonitoring() {
    // Check every minute if schedule active state has changed
    _scheduleCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) async {
        if (schedules.isNotEmpty && selectedAppsCount.value > 0) {
          await _updateShieldsBasedOnSchedules();
        }
      },
    );
    debugPrint('✅ Started schedule monitoring - checking every minute');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed - refreshing Screen Time permissions');
      checkScreenTimeAuthorization();
      _loadSelectedAppsCount();
      _checkScheduleEndedFlag();
      _updateShieldsBasedOnSchedules();
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
          'schedule_completedMsg'.trParams({'name': scheduleName}),
          title: 'schedule_completed'.tr,
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
      title: 'schedule_selectAppsTitle'.tr,
      message: 'schedule_selectAppsMessage'.tr,
      actions: [
        FastDialogAction(
          text: 'later'.tr,
          isCancel: true,
          onPressed: () async {
            Navigator.pop(context);
            // Mark as seen so we don't show again
            await _storage.writeBool(_keyHasSeenAppsPrompt, true);
          },
        ),
        FastDialogAction(
          text: 'schedule_selectApps'.tr,
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

      if (_analytics.isReady) {
        _analytics.events.trackCustom('schedule_screen_time_permission', {
          'granted': granted,
        });
      }

      if (granted) {
        FastToast.success('settings_screenTimeEnabled'.tr);
        // Refresh this controller
        await checkScreenTimeAuthorization();
        await _loadSelectedAppsCount();

        // Sync with other controllers if they exist
        _syncPermissionsWithOtherControllers();
      } else {
        FastToast.warning(
          'schedule_authDeniedMsg'.tr,
          title: 'schedule_authDenied'.tr,
        );
      }
    } catch (e) {
      FastToast.error(
        'schedule_failedAppPicker'.trParams({'error': '$e'}),
        title: 'settings_error'.tr,
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
          'schedule_authRequiredMsg'.tr,
          title: 'schedule_authRequired'.tr,
        );
        return;
      }

      await _screenTimeService.presentAppPicker();
      await _loadSelectedAppsCount();

      try {
        final settingsController = Get.find<FaithLockSettingsController>();
        await settingsController.loadSelectedAppsCount();
      } catch (e) {}

      if (_analytics.isReady) {
        _analytics.events.trackCustom('schedule_apps_selected', {
          'selected_apps_count': selectedAppsCount.value,
        });
      }

      if (selectedAppsCount.value > 0) {
        await loadSchedules();
        await _setupSchedulesFromOnboarding();
        await _updateShieldsBasedOnSchedules();

        final enabledCount =
            schedules.where((s) => s['enabled'] == true).length;

        if (enabledCount > 0) {
          FastToast.success(
            'schedule_appsSelectedLockedMsg'.tr,
            title: 'schedule_appsSelectedLocked'.tr,
          );
        } else {
          FastToast.info(
            'schedule_appsSelectedMsg'.tr,
            title: 'schedule_appsSelected'.tr,
          );
        }
      } else {
        FastToast.info(
          'schedule_selectAppsToEnable'.tr,
          title: 'schedule_noAppsSelected'.tr,
        );
      }
    } catch (e) {
      debugPrint('❌ Error in selectAppsToBlock: $e');
      // Only show toast if we have a valid context with overlay
      try {
        FastToast.error(
          'schedule_failedAppPicker'.trParams({'error': '$e'}),
          title: 'settings_error'.tr,
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
            title: 'schedule_noAppsSelectedDialog'.tr,
            message: 'schedule_noAppsSelectedDialogMsg'.tr,
            actions: [
              FastDialogAction(
                text: 'cancel'.tr,
                isCancel: true,
                onPressed: () => Navigator.pop(context, false),
              ),
              FastDialogAction(
                text: 'schedule_goToProfile'.tr,
                isDefault: true,
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          );

          if (result == true) {
            // Navigate to profile tab (index 2)
            Get.back(); // Go back to main screen
            try {
              final navController = Get.find<NavigationController>();
              navController.changePage(2); // Profile tab
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
            title: 'schedule_blockAppsNow'.tr,
            message: 'schedule_blockAppsNowMsg'.trParams({'name': scheduleName}),
            actions: [
              FastDialogAction(
                text: 'cancel'.tr,
                isCancel: true,
                onPressed: () => Navigator.pop(context, false),
              ),
              FastDialogAction(
                text: 'schedule_blockNow'.tr,
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

      if (_analytics.isReady) {
        _analytics.events.trackCustom('schedule_toggled', {
          'schedule_name': updatedSchedule['name'],
          'is_enabled': updatedSchedule['enabled'],
          'is_currently_active': isScheduleActive(updatedSchedule),
        });
      }

      FastToast.success('schedule_updated'.tr);
    } catch (e) {
      FastToast.error(
        'schedule_failedUpdate'.trParams({'error': '$e'}),
        title: 'settings_error'.tr,
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
                    child: Text('done'.tr),
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

                      if (_analytics.isReady) {
                        _analytics.events.trackCustom('schedule_time_edited', {
                          'schedule_name': updatedSchedule['name'],
                          'edited_field': isStart ? 'start_time' : 'end_time',
                          'new_hour': selectedTime.hour,
                          'new_minute': selectedTime.minute,
                        });
                      }

                      FastToast.success('schedule_timeUpdated'.tr);
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

      // Update shields based on active schedules
      await _updateShieldsBasedOnSchedules();

      debugPrint(
          '✅ Schedules saved and re-setup successfully (${enabledSchedules.length} enabled)');
    } catch (e) {
      debugPrint('⚠️ Failed to save/re-setup schedules: $e');
      rethrow;
    }
  }

  /// Apply or remove shields based on currently active schedules
  Future<void> _updateShieldsBasedOnSchedules() async {
    try {
      // Check if any schedule is currently active
      final hasActiveSchedule = schedules.any((s) => isScheduleActive(s));

      if (hasActiveSchedule) {
        // At least one schedule is active, apply shields
        await _screenTimeService.applyShields();
        debugPrint('🔒 Shields applied - schedule(s) currently active');

        if (_analytics.isReady) {
          _analytics.events.trackCustom('schedule_shields_applied', {
            'active_schedule_count': schedules.where((s) => isScheduleActive(s)).length,
          });
        }
      } else {
        // No schedules active, remove shields
        await _screenTimeService.removeShields();
        debugPrint('🔓 Shields removed - no schedules currently active');
      }
    } catch (e) {
      debugPrint('⚠️ Error updating shields: $e');
      // Don't rethrow - shield updates shouldn't break the flow
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
    if (days.length == 7) return 'schedule_everyDay'.tr;

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

  /// Test schedule monitoring without immediate blocking
  /// Schedule starts in 5 minutes, lasts 15 minutes (iOS minimum)
  Future<void> testScheduleMonitoring() async {
    final context = Get.context;
    if (context == null) return;

    try {
      if (!isScreenTimeAuthorized.value) {
        FastToast.warning(
          'schedule_authRequiredMsg'.tr,
          title: 'schedule_authRequired'.tr,
        );
        return;
      }

      if (selectedAppsCount.value == 0) {
        FastToast.warning(
          'schedule_selectAppsToEnable'.tr,
          title: 'schedule_noAppsSelected'.tr,
        );
        return;
      }

      // Calculate times: Start in 5 min, last 15 min (iOS minimum)
      final now = DateTime.now();
      final startTime = now.add(const Duration(minutes: 5));
      final endTime = startTime.add(const Duration(minutes: 15));

      debugPrint('========================================');
      debugPrint('🧪 TEST SCHEDULE (NO IMMEDIATE BLOCKING)');
      debugPrint('========================================');
      debugPrint('⏰ Current: ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
      debugPrint('⏰ Will START at: ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} (+5 min)');
      debugPrint('⏰ Will END at: ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')} (+20 min)');
      debugPrint('📱 Apps should NOT be blocked right now');
      debugPrint('📱 Apps WILL be blocked when schedule starts');
      debugPrint('========================================');

      final testSchedules = [
        {
          'name': 'TEST_MONITOR',
          'icon': '🧪',
          'startHour': startTime.hour,
          'startMinute': startTime.minute,
          'endHour': endTime.hour,
          'endMinute': endTime.minute,
          'enabled': true,
        }
      ];

      // Setup test schedule WITHOUT applying shields
      await _screenTimeService.setupSchedules(testSchedules);

      debugPrint('✅ Test schedule setup complete - monitoring started');
      debugPrint('⏳ Waiting for iOS to call intervalDidStart in 5 minutes...');
      debugPrint('📊 Watch Xcode logs for: "🔒 MONITOR: Schedule \'TEST_MONITOR\' started"');

      final ctx = Get.context;
      if (ctx != null) {
        FastToast.showSuccess(
          context: ctx,
          title: 'schedule_testCreated'.tr,
          message: 'schedule_testCreatedMsg'.tr,
          duration: const Duration(seconds: 6),
        );
      }
    } catch (e) {
      debugPrint('❌ Test failed: $e');
      final ctx = Get.context;
      if (ctx != null) {
        FastToast.showError(
          context: ctx,
          title: 'schedule_testFailed'.tr,
          message: 'schedule_testFailedMsg'.trParams({'error': '$e'}),
          duration: const Duration(seconds: 5),
        );
      }
    }
  }
}
