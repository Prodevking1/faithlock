import 'package:faithlock/features/faithlock/services/screen_time_service.dart';
import 'package:faithlock/services/app_launch_service.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:faithlock/shared/widgets/dialogs/fast_alert_dialog.dart';
import 'package:flutter/material.dart';

/// Service to perform startup checks when app launches
class StartupCheckService {
  static final StartupCheckService _instance = StartupCheckService._internal();
  factory StartupCheckService() => _instance;
  StartupCheckService._internal();

  final ScreenTimeService _screenTimeService = ScreenTimeService();
  final AppLaunchService _launchService = AppLaunchService();
  final StorageService _storage = StorageService();

  bool _hasChecked = false;

  /// Perform startup checks (call from main screen or splash)
  /// This handles Screen Time authorization and app selection prompts
  Future<void> performStartupChecks(BuildContext context) async {
    // Only check once per app session
    if (_hasChecked) return;
    _hasChecked = true;

    // Only prompt on natural launches (not from notifications)
    final isNatural = await _launchService.isNaturalLaunch();
    if (!isNatural) {
      debugPrint('📱 Skipping startup check - launched via notification');
      return;
    }

    debugPrint('📱 Performing startup checks (natural launch)');

    // Wait a bit for UI to settle
    await Future.delayed(const Duration(milliseconds: 500));

    // Check Screen Time authorization first
    final isAuthorized = await _screenTimeService.isAuthorized();
    if (!isAuthorized) {
      debugPrint('⚠️ Screen Time not authorized - prompting user');
      final granted = await _promptScreenTimeAuthorization(context);

      if (!granted) {
        debugPrint('⚠️ User declined Screen Time authorization');
        return;
      }

      // Wait a bit after Screen Time authorization
      await Future.delayed(const Duration(seconds: 2));
    }

    // Check if apps are selected
    final hasApps = await _screenTimeService.hasSelectedApps();
    if (!hasApps) {
      debugPrint('⚠️ No apps selected - prompting user');
      await _promptToSelectApps(context);
      return;
    }

    debugPrint('✅ Startup checks passed - Screen Time authorized and apps selected');
  }

  /// Prompt user to authorize Screen Time
  Future<bool> _promptScreenTimeAuthorization(BuildContext context) async {
    if (!context.mounted) return false;

    // Check if we already asked
    final hasAskedBefore = await _storage.readBool('screen_time_prompt_shown') ?? false;

    // Show explanatory dialog
    await FastAlertDialog.show(
      context: context,
      title: '🛡️ Enable Screen Time',
      message:
          'FaithLock needs Screen Time permissions to protect your apps.\n\n'
          'This allows the app to:\n'
          '• Block distracting apps\n'
          '• Unlock apps temporarily after prayer\n'
          '• Help you stay focused on God\n\n'
          'Tap "Enable" to grant permission.',
      actions: [
        if (hasAskedBefore)
          FastDialogAction(
            text: 'Later',
            isCancel: true,
            onPressed: () => Navigator.pop(context, false),
          ),
        FastDialogAction(
          text: 'Enable',
          isDefault: true,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );

    // Wait for dialog animation
    await Future.delayed(const Duration(milliseconds: 300));

    // Request authorization
    final granted = await _screenTimeService.requestAuthorization();

    // Mark that we asked
    await _storage.writeBool('screen_time_prompt_shown', true);

    if (granted) {
      debugPrint('✅ Screen Time authorization granted');
    } else {
      debugPrint('❌ Screen Time authorization denied');
    }

    return granted;
  }

  /// Prompt user to select apps to block
  Future<void> _promptToSelectApps(BuildContext context) async {
    if (!context.mounted) return;

    // Check if we already asked
    final hasAskedBefore = await _storage.readBool('app_selection_prompt_shown') ?? false;

    await FastAlertDialog.show(
      context: context,
      title: '📱 Select Apps to Block',
      message:
          'Choose which apps to protect with FaithLock.\n\n'
          'You can select social media, games, or any distracting apps.\n\n'
          'These apps will be blocked until you complete your daily prayer.',
      actions: [
        if (hasAskedBefore)
          FastDialogAction(
            text: 'Later',
            isCancel: true,
            onPressed: () => Navigator.pop(context),
          ),
        FastDialogAction(
          text: 'Select Apps',
          isDefault: true,
          onPressed: () async {
            Navigator.pop(context);

            // Wait for dialog animation
            await Future.delayed(const Duration(milliseconds: 300));

            // Open app picker
            try {
              await _screenTimeService.presentAppPicker();
              debugPrint('✅ User selected apps from startup prompt');

              // Mark that we asked
              await _storage.writeBool('app_selection_prompt_shown', true);
            } catch (e) {
              debugPrint('❌ Error showing app picker: $e');
            }
          },
        ),
      ],
    );
  }

  /// Reset check flag (for testing)
  void resetCheck() {
    _hasChecked = false;
  }
}
