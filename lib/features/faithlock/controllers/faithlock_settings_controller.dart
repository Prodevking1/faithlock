import 'dart:convert';
import 'package:faithlock/features/faithlock/services/export.dart';
import 'package:faithlock/features/faithlock/controllers/schedule_controller.dart';
import 'package:faithlock/services/notifications/local_notification_service.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:faithlock/shared/widgets/dialogs/fast_alert_dialog.dart';
import 'package:faithlock/shared/widgets/notifications/fast_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

/// Controller for FaithLock Settings Screen
/// Manages permissions and app configuration
class FaithLockSettingsController extends GetxController with WidgetsBindingObserver {
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  final LockService _lockService = LockService();
  final LocalNotificationService _notificationService = LocalNotificationService();

  // Observable state
  final RxBool isScreenTimeAuthorized = RxBool(false);
  final RxString screenTimeStatus = RxString('Unknown');
  final RxBool isNotificationsAuthorized = RxBool(false);
  final RxString notificationsStatus = RxString('Unknown');
  final RxBool isLockEnabled = RxBool(true);
  final RxInt selectedAppsCount = RxInt(0);

  @override
  void onInit() {
    super.onInit();
    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Load data asynchronously without blocking initialization
    Future.microtask(() => _initializeAsync());
  }

  @override
  void onClose() {
    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh permissions when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed - refreshing permissions');
      checkScreenTimePermission();
      checkNotificationsPermission();
      loadSelectedAppsCount();
    }
  }

  /// Initialize data asynchronously to avoid blocking UI
  Future<void> _initializeAsync() async {
    try {
      await Future.wait([
        loadPermissions(),
        loadSettings(),
        loadSelectedAppsCount(),
      ]);
    } catch (e) {
      print('⚠️ Error during FaithLock initialization: $e');
      // Don't throw - allow UI to load even if initialization fails
    }
  }

  Future<void> loadSelectedAppsCount() async {
    try {
      final hasApps = await _screenTimeService.hasSelectedApps();
      selectedAppsCount.value = hasApps ? 1 : 0;
      debugPrint('📱 Apps selected: $hasApps (count: ${selectedAppsCount.value})');
    } catch (e) {
      selectedAppsCount.value = 0;
    }
  }

  /// Load all permission statuses
  Future<void> loadPermissions() async {
    await checkScreenTimePermission();
    await checkNotificationsPermission();
  }

  /// Load app settings
  Future<void> loadSettings() async {
    try {
      final enabled = await _lockService.isLockEnabled();
      isLockEnabled.value = enabled;
    } catch (e) {
      isLockEnabled.value = true;
    }
  }

  /// Check Screen Time authorization status
  Future<void> checkScreenTimePermission() async {
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
  Future<void> requestScreenTimePermission() async {
    final context = Get.context;
    if (context == null) return;

    try {
      final granted = await _screenTimeService.requestAuthorization();

      if (granted) {
        FastToast.showSuccess(
          context: context,
          title: 'settings_permissionGranted'.tr,
          message: 'settings_screenTimeEnabled'.tr,
        );
        // Refresh this controller
        await checkScreenTimePermission();
        await loadSelectedAppsCount();

        // Sync with other controllers if they exist
        _syncPermissionsWithOtherControllers();
      } else {
        FastToast.showWarning(
          context: context,
          title: 'settings_permissionDenied'.tr,
          message: 'settings_enableScreenTime'.tr,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      FastToast.showError(
        context: context,
        title: 'settings_error'.tr,
        message: 'settings_failedScreenTime'.trParams({'error': '$e'}),
      );
    }
  }

  /// Sync permissions with other controllers to keep UI in sync
  void _syncPermissionsWithOtherControllers() {
    try {
      // Try to find and refresh ScheduleController if it exists
      if (Get.isRegistered<ScheduleController>()) {
        final scheduleController = Get.find<ScheduleController>();
        scheduleController.checkScreenTimeAuthorization();
        debugPrint('✅ Synced permissions with ScheduleController');
      }
    } catch (e) {
      // Controller not registered yet, that's fine
      debugPrint('ℹ️ ScheduleController not registered: $e');
    }
  }

  /// Check Notifications permission status
  Future<void> checkNotificationsPermission() async {
    try {
      final status = await Permission.notification.status;
      isNotificationsAuthorized.value = status.isGranted;

      if (status.isGranted) {
        notificationsStatus.value = 'Granted';
      } else if (status.isDenied) {
        notificationsStatus.value = 'Denied';
      } else if (status.isPermanentlyDenied) {
        notificationsStatus.value = 'Blocked';
      } else {
        notificationsStatus.value = 'Not Set';
      }

      debugPrint('📱 Notification permission status: ${notificationsStatus.value}');
    } catch (e) {
      debugPrint('❌ Error checking notification permission: $e');
      notificationsStatus.value = 'Unknown';
      isNotificationsAuthorized.value = false;
    }
  }

  /// Request Notifications permission
  Future<void> requestNotificationsPermission() async {
    final context = Get.context;
    if (context == null) return;

    try {
      // Check current status first
      final currentStatus = await Permission.notification.status;

      // If permanently denied, go directly to settings
      if (currentStatus.isPermanentlyDenied) {
        debugPrint('⚠️ Notifications permanently denied - opening settings');
        await _openNotificationSettings(context);
        return;
      }

      // Initialize notification service if needed
      await _notificationService.initialize();

      // Request permission
      debugPrint('📱 Requesting notification permission...');
      final granted = await _notificationService.requestPermissions();

      // Refresh status
      await checkNotificationsPermission();

      if (granted) {
        FastToast.showSuccess(
          context: context,
          title: 'settings_notificationsEnabled'.tr,
          message: 'settings_notificationsEnabledMsg'.tr,
        );
      } else {
        // Permission denied - offer to open settings
        FastToast.showWarning(
          context: context,
          title: 'settings_notificationsDisabled'.tr,
          message: 'settings_notificationsDisabledMsg'.tr,
          duration: const Duration(seconds: 4),
        );

        // Wait a bit then open settings
        await Future.delayed(const Duration(milliseconds: 500));
        await _openNotificationSettings(context);
      }
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      FastToast.showError(
        context: context,
        title: 'settings_error'.tr,
        message: 'settings_failedNotifications'.tr,
      );
    }
  }

  /// Open iOS Settings to notification page for the app
  Future<void> _openNotificationSettings(BuildContext context) async {
    try {
      final opened = await openAppSettings();

      if (!opened) {
        FastToast.showError(
          context: context,
          title: 'settings_error'.tr,
          message: 'settings_couldNotOpenSettings'.tr,
        );
      } else {
        debugPrint('✅ Opened app settings for notifications');
      }
    } catch (e) {
      debugPrint('❌ Error opening settings: $e');
      FastToast.showError(
        context: context,
        title: 'settings_error'.tr,
        message: 'settings_couldNotOpenSettingsShort'.tr,
      );
    }
  }

  /// Toggle master lock enabled/disabled
  Future<void> toggleLockEnabled(bool enabled) async {
    final context = Get.context;
    if (context == null) return;

    try {
      await _lockService.setLockEnabled(enabled);
      isLockEnabled.value = enabled;

      FastToast.showSuccess(
        context: context,
        title: enabled ? 'settings_lockEnabled'.tr : 'settings_lockDisabled'.tr,
        message: enabled
            ? 'settings_lockEnabledMsg'.tr
            : 'settings_lockDisabledMsg'.tr,
      );
    } catch (e) {
      FastToast.showError(
        context: context,
        title: 'settings_error'.tr,
        message: 'settings_failedToggleLock'.trParams({'error': '$e'}),
      );
    }
  }

  /// Show emergency bypass information
  void showEmergencyBypassInfo() {
    final context = Get.context;
    if (context == null) return;

    FastAlertDialog.show(
      context: context,
      title: 'emergencyBypass'.tr,
      message: 'settings_emergencyBypassInfo'.tr,
      actions: [
        FastDialogAction(
          text: 'settings_gotIt'.tr,
          isDefault: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Future<void> selectAppsToBlock() async {
    final context = Get.context;
    if (context == null) return;

    try {
      if (!isScreenTimeAuthorized.value) {
        FastToast.showWarning(
          context: context,
          title: 'settings_permissionRequired'.tr,
          message: 'settings_grantScreenTimeFirst'.tr,
        );
        return;
      }

      // Save count before showing picker to detect changes
      final previousCount = selectedAppsCount.value;

      await _screenTimeService.presentAppPicker();
      await loadSelectedAppsCount();

      try {
        final scheduleController = Get.find<ScheduleController>();
        await scheduleController.refreshSchedules();
      } catch (e) {}

      // Only show toast if selection changed
      if (selectedAppsCount.value != previousCount) {
        if (selectedAppsCount.value > 0) {
          await _setupSchedulesFromStorage();
          if (context.mounted) {
            FastToast.showSuccess(
              context: context,
              title: 'settings_appsSelectedLocked'.tr,
              message: 'settings_appsSelectedLockedMsg'.tr,
            );
          }
        } else {
          if (context.mounted) {
            FastToast.showInfo(
              context: context,
              title: 'settings_noAppsSelectedTitle'.tr,
              message: 'settings_selectAppsToEnable'.tr,
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        FastToast.showError(
          context: context,
          title: 'settings_error'.tr,
          message: 'settings_failedAppPicker'.trParams({'error': '$e'}),
        );
      }
    }
  }

  /// Show the list of blocked apps with icons
  /// If no apps are selected, opens the app picker instead
  Future<void> showBlockedApps() async {
    final context = Get.context;
    if (context == null) return;

    try {
      if (!isScreenTimeAuthorized.value) {
        FastToast.showWarning(
          context: context,
          title: 'settings_permissionRequired'.tr,
          message: 'settings_grantScreenTimeFirst'.tr,
        );
        return;
      }

      // If no apps selected, show the picker
      if (selectedAppsCount.value == 0) {
        await selectAppsToBlock();
        return;
      }

      // Show the blocked apps list
      final success = await _screenTimeService.showBlockedAppsList();
      if (!success && context.mounted) {
        // Fallback to showing the picker if list fails
        await selectAppsToBlock();
      }
    } catch (e) {
      debugPrint('❌ Error showing blocked apps: $e');
      // Fallback to picker
      await selectAppsToBlock();
    }
  }

  /// Setup schedules from storage (called after app selection or schedule edit)
  Future<void> _setupSchedulesFromStorage() async {
    try {
      // Read schedules from storage
      final StorageService storage = StorageService();
      final schedulesJson = await storage.readString('onboarding_schedules');
 
      if (schedulesJson == null || schedulesJson.isEmpty) {
        print('⚠️ No schedules found in storage');
        return;
      }

      // Parse schedules
      final List<dynamic> schedulesData = jsonDecode(schedulesJson);
      final List<Map<String, dynamic>> schedules =
          schedulesData.map((s) => Map<String, dynamic>.from(s)).toList();

      // Setup native DeviceActivity schedules
      await _screenTimeService.setupSchedules(schedules);

      print('✅ Schedules setup successfully after app selection');
    } catch (e) {
      print('⚠️ Failed to setup schedules: $e');
    }
  }

  /// Show about info
  void showAboutInfo() {
    Get.defaultDialog(
      title: 'aboutFaithLock'.tr,
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      middleText: 'settings_aboutDescription'.tr,
      textConfirm: 'settings_close'.tr,
      confirmTextColor: Get.theme.colorScheme.primary,
      onConfirm: () => Get.back(),
    );
  }

  /// Open privacy policy
  Future<void> openPrivacyPolicy() async {
    final url = Uri.parse('https://faithlock.app/privacy');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'settings_comingSoon'.tr,
          'settings_privacyComingSoon'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'settings_error'.tr,
        'settings_couldNotOpenPrivacy'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Open support
  Future<void> openSupport() async {
    final url =
        Uri.parse('mailto:support@faithlock.app?subject=FaithLock Support');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar(
          'settings_emailSupport'.tr,
          'settings_contactEmail'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar(
        'settings_contactUs'.tr,
        'settings_email'.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadPermissions();
    await loadSettings();
  }
}
