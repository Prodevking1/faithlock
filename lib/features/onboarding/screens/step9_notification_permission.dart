import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/screens/onboarding_summary_screen.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/services/notifications/local_notification_service.dart';
import 'package:faithlock/services/storage/preferences_service.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/buttons/fast_plain_button.dart';
import 'package:faithlock/shared/widgets/dialogs/fast_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Step 9: Notification Permission - Enable prayer reminders and relock alerts
class Step9NotificationPermission extends StatefulWidget {
  const Step9NotificationPermission({super.key});

  @override
  State<Step9NotificationPermission> createState() =>
      _Step9NotificationPermissionState();
}

class _Step9NotificationPermissionState
    extends State<Step9NotificationPermission> {
  final controller = Get.find<ScriptureOnboardingController>();
  final LocalNotificationService _notificationService =
      LocalNotificationService();
  final PreferencesService _prefs = PreferencesService();

  // Phase 9.1 - Introduction
  String _introText = '';
  bool _showIntroCursor = false;

  // Phase 9.2 - Explanation
  String _explanationText = '';
  bool _showExplanationCursor = false;

  // Phase 9.3 - Call to Action
  bool _showButton = false;
  bool _isRequestingPermission = false;

  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 9.1: Introduction
    await _phase91Introduction();

    // Phase 9.2: Explanation
    await _phase92Explanation();

    // Phase 9.3: Show button
    await _phase93CallToAction();
  }

  Future<void> _phase91Introduction() async {
    await AnimationUtils.typeText(
      fullText:
          'One more thing, ${controller.userName.value}... to help you stay focused...',
      onUpdate: (text) => setState(() => _introText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showIntroCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2000);
  }

  Future<void> _phase92Explanation() async {
    setState(() {
      _introText = '';
      _showIntroCursor = false;
    });

    await AnimationUtils.typeText(
      fullText:
          'I need to send you reminders when it\'s time to re-lock your apps and pray.\n\nThese gentle nudges will keep you on track.',
      onUpdate: (text) => setState(() => _explanationText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showExplanationCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2500);
  }

  Future<void> _phase93CallToAction() async {
    setState(() {
      _explanationText = '';
      _showExplanationCursor = false;
      _showButton = true;
    });

    await AnimationUtils.mediumHaptic();
  }

  Future<void> _onEnableNotifications() async {
    if (_isRequestingPermission) return;

    await AnimationUtils.heavyHaptic();

    setState(() {
      _isRequestingPermission = true;
    });

    try {
      debugPrint('🔔 [STEP 9] ========================================');
      debugPrint('🔔 [STEP 9] Starting notification permission request...');
      debugPrint('🔔 [STEP 9] Mounted state: $mounted');
      debugPrint('🔔 [STEP 9] Time: ${DateTime.now()}');

      // Request permission and wait for user response
      final startTime = DateTime.now();
      final granted = await _notificationService.requestPermissions();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      debugPrint('📱 [STEP 9] Permission response received: $granted');
      debugPrint('📱 [STEP 9] Time taken: ${duration.inMilliseconds}ms');
      debugPrint('📱 [STEP 9] Mounted state after request: $mounted');

      // If response was instant (<100ms), permission was already decided
      if (duration.inMilliseconds < 100) {
        debugPrint(
            '⚠️ [STEP 9] INSTANT RESPONSE - Permission was already decided by iOS');
        debugPrint(
            '💡 [STEP 9] User may have already accepted/denied in a previous session');
        debugPrint(
            '💡 [STEP 9] iOS does not show the dialog again after first decision');
      }

      if (granted) {
        debugPrint('✅ Notifications permission granted');
      } else {
        debugPrint('❌ Notifications permission denied');
      }

      // Mark that we asked for permission
      await _prefs.writeBool('notification_permission_asked', true);

      // Wait a bit for the dialog to dismiss smoothly
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Complete onboarding and navigate to summary screen
      await controller.completeOnboarding();

      if (!mounted) return;

      Get.off(() => const OnboardingSummaryScreen());
    } catch (e) {
      debugPrint('❌ Error requesting Notifications permission: $e');

      // Wait a bit before navigating
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Still complete onboarding even if there's an error
      await controller.completeOnboarding();

      if (!mounted) return;

      Get.off(() => const OnboardingSummaryScreen());
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
      }
    }
  }

  Future<void> _onSkipNotifications() async {
    await AnimationUtils.lightHaptic();

    // Show confirmation dialog with high friction using FastConfirmationDialog
    final shouldSkip = await FastConfirmationDialog.show(
      title: 'Skip Reminders?',
      message:
          'Without notifications, you won\'t receive reminders to re-lock your apps and pray.\n\nYou can enable this later in Settings.',
      confirmText: 'Skip for Now',
      cancelText: 'Enable Reminders',
      isDestructiveConfirm: false,
    );

    if (shouldSkip) {
      await _prefs.writeBool('notification_permission_asked', true);
      await controller.completeOnboarding();
      Get.off(() => const OnboardingSummaryScreen());
    }
  }

  Widget _buildBenefitItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: OnboardingTheme.goldColor.withValues(alpha: 0.1),
          ),
          child: Icon(
            icon,
            size: 20,
            color: OnboardingTheme.goldColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: OnboardingTheme.body.copyWith(
              color: OnboardingTheme.labelPrimary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 1000),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: OnboardingTheme.horizontalPadding,
              right: OnboardingTheme.horizontalPadding,
              top: 40,
              bottom: OnboardingTheme.verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Phase 9.1 - Introduction
                if (_introText.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      style: OnboardingTheme.bodyEmphasized,
                      children: [
                        TextSpan(text: _introText),
                        if (_showIntroCursor)
                          const WidgetSpan(
                            child: FeatherCursor(),
                            alignment: PlaceholderAlignment.middle,
                          ),
                      ],
                    ),
                  ),

                // Phase 9.2 - Explanation
                if (_explanationText.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      style: OnboardingTheme.bodyEmphasized,
                      children: [
                        TextSpan(text: _explanationText),
                        if (_showExplanationCursor)
                          const WidgetSpan(
                            child: FeatherCursor(),
                            alignment: PlaceholderAlignment.middle,
                          ),
                      ],
                    ),
                  ),

                // Phase 9.3 - Call to Action
                if (_showButton) ...[
                  const SizedBox(height: 40),

                  // Main message
                  Center(
                    child: Text(
                      'Enable Prayer Reminders',
                      style: OnboardingTheme.title2.copyWith(
                        color: OnboardingTheme.labelPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Icon illustratif avec animation
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            OnboardingTheme.goldColor.withValues(alpha: 0.2),
                            OnboardingTheme.goldColor.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(
                          color:
                              OnboardingTheme.goldColor.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        size: 50,
                        color: OnboardingTheme.goldColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Benefits list
                  _buildBenefitItem(
                    icon: Icons.alarm,
                    text: 'Timely reminders to re-lock your apps',
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    icon: Icons.church,
                    text: 'Prayer time notifications',
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    icon: Icons.psychology,
                    text: 'Stay accountable to your spiritual goals',
                  ),

                  const SizedBox(height: 32),

                  // Info box
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.goldColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: OnboardingTheme.goldColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: OnboardingTheme.goldColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'We\'ll only send helpful reminders, not spam',
                            style: OnboardingTheme.footnote.copyWith(
                              color: OnboardingTheme.goldColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Primary button
                  Center(
                    child: FastButton(
                      text: _isRequestingPermission
                          ? 'Requesting...'
                          : 'Enable Notifications',
                      onTap: _isRequestingPermission
                          ? null
                          : _onEnableNotifications,
                      backgroundColor: OnboardingTheme.goldColor,
                      textColor: OnboardingTheme.backgroundColor,
                      style: FastButtonStyle.filled,
                      isLoading: _isRequestingPermission,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Skip button avec friction (using FastPlainButton)
                  Center(
                    child: FastPlainButton(
                      text: 'Skip reminders',
                      onTap: _onSkipNotifications,
                      textColor: OnboardingTheme.labelTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
