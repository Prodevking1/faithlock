import 'package:faithlock/features/faithlock/services/screen_time_service.dart';
import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:faithlock/shared/widgets/dialogs/fast_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Step 7: Screen Time Permission - Connect to iOS Screen Time
/// Request permission to access Screen Time API for app blocking
class Step7ScreenTimePermission extends StatefulWidget {
  final VoidCallback onComplete;

  const Step7ScreenTimePermission({
    super.key,
    required this.onComplete,
  });

  @override
  State<Step7ScreenTimePermission> createState() =>
      _Step7ScreenTimePermissionState();
}

class _Step7ScreenTimePermissionState extends State<Step7ScreenTimePermission> {
  final controller = Get.find<ScriptureOnboardingController>();
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  final StorageService _storage = StorageService();

  // Phase 7.1 - Introduction
  String _introText = '';
  bool _showIntroCursor = false;

  // Phase 7.2 - Explanation
  String _explanationText = '';
  bool _showExplanationCursor = false;

  // Phase 7.3 - Call to Action
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

    // Phase 7.1: Introduction
    await _phase71Introduction();

    // Phase 7.2: Explanation
    await _phase72Explanation();

    // Phase 7.3: Show button
    await _phase73CallToAction();
  }

  Future<void> _phase71Introduction() async {
    await AnimationUtils.typeText(
      fullText:
          '${controller.userName.value}, this is the final step to activate your spiritual shield...',
      onUpdate: (text) => setState(() => _introText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showIntroCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2000);
  }

  Future<void> _phase72Explanation() async {
    setState(() {
      _introText = '';
      _showIntroCursor = false;
    });

    await AnimationUtils.typeText(
      fullText:
          'To protect you with Scripture every time you unlock, I need Screen Time permission.\n\nWithout this, your shield cannot activate.',
      onUpdate: (text) => setState(() => _explanationText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showExplanationCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2500);
  }

  Future<void> _phase73CallToAction() async {
    setState(() {
      _explanationText = '';
      _showExplanationCursor = false;
      _showButton = true;
    });

    await AnimationUtils.mediumHaptic();
  }

  Future<void> _onConnectScreenTime() async {
    if (_isRequestingPermission) return;

    await AnimationUtils.heavyHaptic();

    setState(() {
      _isRequestingPermission = true;
    });

    try {
      debugPrint('🛡️ Requesting Screen Time permission...');
      final granted = await _screenTimeService.requestAuthorization();

      if (granted) {
        debugPrint('✅ Screen Time permission granted');
      } else {
        debugPrint('❌ Screen Time permission denied');
      }

      // Mark that we asked for permission
      await _storage.writeBool('screen_time_prompt_shown', true);

      // Move to next step (notifications)
      widget.onComplete();
    } catch (e) {
      debugPrint('❌ Error requesting Screen Time permission: $e');
      // Still move forward even if there's an error
      widget.onComplete();
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
      }
    }
  }

  Future<void> _onSkipPermission() async {
    await AnimationUtils.lightHaptic();

    // Show confirmation dialog with high friction using FastConfirmationDialog
    final shouldSkip = await FastConfirmationDialog.show(
      title: 'Continue Without Protection?',
      message:
          'Without Screen Time permission, FaithLock cannot protect you from your chosen apps.\n\nYou can enable this later in Settings.',
      confirmText: 'Skip for Now',
      cancelText: 'Continue',
      isDestructiveConfirm: false,
    );

    if (shouldSkip) {
      widget.onComplete();
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
              top: 100, // Space for progress bar
              bottom: OnboardingTheme.verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Phase 7.1 - Introduction
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

                // Phase 7.2 - Explanation
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

                // Phase 7.3 - Call to Action
                if (_showButton) ...[
                  const SizedBox(height: 40),

                  // Main message
                  Center(
                    child: Text(
                      'Activate Your Spiritual Shield',
                      style: OnboardingTheme.title2.copyWith(
                        color: OnboardingTheme.labelPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Icon illustratif avec animation
                  const Center(
                    child: JudahMascot(
                      state: JudahState.pointing,
                      size: JudahSize.l,
                      showMessage: false,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Benefits list
                  _buildBenefitItem(
                    icon: Icons.menu_book,
                    text: 'Scripture appears before you unlock',
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    icon: Icons.security,
                    text: 'Your chosen apps are protected',
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    icon: Icons.trending_up,
                    text: 'Build discipline through daily verses',
                  ),

                  const SizedBox(height: 40),

                  // Primary button
                  Center(
                    child: FastButton(
                      text: _isRequestingPermission
                          ? 'Requesting...'
                          : 'Continue',
                      onTap:
                          _isRequestingPermission ? null : _onConnectScreenTime,
                      backgroundColor: OnboardingTheme.goldColor,
                      textColor: OnboardingTheme.backgroundColor,
                      style: FastButtonStyle.filled,
                      isLoading: _isRequestingPermission,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Skip button avec friction (using FastPlainButton)
                  // Center(
                  //   child: FastPlainButton(
                  //     text: 'Continue without protection',
                  //     onTap: _onSkipPermission,
                  //     textColor: OnboardingTheme.labelTertiary,
                  //   ),
                  // ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
