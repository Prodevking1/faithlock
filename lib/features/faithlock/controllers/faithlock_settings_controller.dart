import 'dart:convert';
import 'package:faithlock/features/faithlock/services/export.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:faithlock/shared/widgets/dialogs/fast_alert_dialog.dart';
import 'package:faithlock/shared/widgets/notifications/fast_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Controller for FaithLock Settings Screen
/// Manages permissions and app configuration
class FaithLockSettingsController extends GetxController {
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  final LockService _lockService = LockService();

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
    // Load data asynchronously without blocking initialization
    Future.microtask(() => _initializeAsync());
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

  /// Load count of selected apps
  Future<void> loadSelectedAppsCount() async {
    try {
      final hasApps = await _screenTimeService.hasSelectedApps();
      // We can't get exact count, but we know if apps are selected
      selectedAppsCount.value = hasApps ? 1 : 0; // 1 means "some apps selected"
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
          title: 'Permission Granted',
          message: 'Screen Time access has been enabled',
        );
        await checkScreenTimePermission();
      } else {
        FastToast.showWarning(
          context: context,
          title: 'Permission Denied',
          message: 'Please enable Screen Time access in iOS Settings',
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      FastToast.showError(
        context: context,
        title: 'Error',
        message: 'Failed to request Screen Time permission: $e',
      );
    }
  }

  /// Check Notifications permission status
  Future<void> checkNotificationsPermission() async {
    // TODO: Implement notifications permission check
    // For now, set as granted
    isNotificationsAuthorized.value = true;
    notificationsStatus.value = 'Granted';
  }

  /// Request Notifications permission
  Future<void> requestNotificationsPermission() async {
    final context = Get.context;
    if (context == null) return;

    // TODO: Implement notifications permission request
    FastToast.showInfo(
      context: context,
      title: 'Coming Soon',
      message: 'Notification permissions will be implemented next',
    );
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
        title: enabled ? 'Lock System Enabled' : 'Lock System Disabled',
        message: enabled
            ? 'Schedules will now activate automatically'
            : 'All schedules are temporarily disabled',
      );
    } catch (e) {
      FastToast.showError(
        context: context,
        title: 'Error',
        message: 'Failed to toggle lock system: $e',
      );
    }
  }

  /// Show emergency bypass information
  void showEmergencyBypassInfo() {
    final context = Get.context;
    if (context == null) return;

    FastAlertDialog.show(
      context: context,
      title: 'Emergency Bypass',
      message:
          'If you need to unlock your device during an active lock period:\n\n'
          '1. Answer the Bible verse quiz correctly\n'
          '2. Use the "Emergency Bypass" option (breaks your streak)\n'
          '3. Force close and restart the app (in emergency only)\n\n'
          'Remember: The goal is to build spiritual discipline!',
      actions: [
        FastDialogAction(
          text: 'Got it',
          isDefault: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  /// Select apps to block
  Future<void> selectAppsToBlock() async {
    final context = Get.context;
    if (context == null) return;

    try {
      if (!isScreenTimeAuthorized.value) {
        FastToast.showWarning(
          context: context,
          title: 'Permission Required',
          message: 'Please grant Screen Time access first',
        );
        return;
      }

      // Present the native FamilyActivityPicker
      await _screenTimeService.presentAppPicker();

      // Reload apps count after selection
      await loadSelectedAppsCount();

      // Auto-setup schedules after app selection
      await _setupSchedulesFromStorage();

      // Show success message after selection
      FastToast.showSuccess(
        context: context,
        title: 'Apps Selected & Locked',
        message: 'Your apps will be automatically blocked during scheduled times',
      );
    } catch (e) {
      FastToast.showError(
        context: context,
        title: 'Error',
        message: 'Failed to show app picker: $e',
      );
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
      title: 'About FaithLock',
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      middleText: 'FaithLock helps you build spiritual discipline by combining '
          'Bible verse memorization with screen time management.\n\n'
          'Unlock your device by correctly answering questions about '
          'Bible verses. Build streaks, track your progress, and grow '
          'in faith while reducing digital distractions.\n\n'
          'Version 1.0.0',
      textConfirm: 'Close',
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
          'Coming Soon',
          'Privacy policy will be available soon',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open privacy policy',
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
          'Email Support',
          'Contact us at: support@faithlock.app',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Contact Us',
        'Email: support@faithlock.app',
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
