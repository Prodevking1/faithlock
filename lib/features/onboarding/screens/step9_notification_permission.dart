import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/services/notifications/daily_verse_notification_service.dart';
import 'package:faithlock/services/notifications/local_notification_service.dart';
import 'package:faithlock/services/storage/preferences_service.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/dialogs/fast_confirmation_dialog.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Step 9: Notification Permission - Enable prayer reminders and relock alerts
/// After permission is granted, shows daily verses time selection (V2 feature)
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
  final DailyVerseNotificationService _dailyVerseService =
      DailyVerseNotificationService();

  // Current phase: 'permission' or 'timeSelection'
  String _currentPhase = 'permission';

  // Phase 9.1 - Introduction
  String _introText = '';
  bool _showIntroCursor = false;

  // Phase 9.2 - Explanation
  String _explanationText = '';
  bool _showExplanationCursor = false;

  // Phase 9.3 - Call to Action
  bool _showButton = false;
  bool _isRequestingPermission = false;

  // Phase 9.4 - Daily Verses Time Selection
  bool _showTimeSelection = false;
  int _selectedFrequency = 1; // 1, 2, or 3 times per day
  final List<TimeOfDay> _selectedTimes = [
    const TimeOfDay(hour: 8, minute: 0), // Morning
  ];
  bool _isSavingTimes = false;

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

      // Initialize notification service first (if not already done)
      await _notificationService.initialize();
      debugPrint('✅ [STEP 9] LocalNotificationService initialized');

      // Request permission and wait for user response
      final granted = await _notificationService.requestPermissions();

      debugPrint('📱 [STEP 9] Permission response received: $granted');

      // Mark that we asked for permission
      await _prefs.writeBool('notification_permission_asked', true);

      // Wait a bit for the dialog to dismiss smoothly
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Transition to time selection phase
      _transitionToTimeSelection();
    } catch (e) {
      debugPrint('❌ Error requesting Notifications permission: $e');

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Still transition to time selection even if there's an error
      _transitionToTimeSelection();
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
      }
    }
  }

  void _transitionToTimeSelection() {
    setState(() {
      _currentPhase = 'timeSelection';
      _showButton = false;
      _showTimeSelection = true;
    });
    AnimationUtils.mediumHaptic();
  }

  void _onFrequencyChanged(int frequency) {
    setState(() {
      _selectedFrequency = frequency;
      // Adjust time slots based on frequency
      _selectedTimes.clear();
      if (frequency >= 1) {
        _selectedTimes.add(const TimeOfDay(hour: 8, minute: 0)); // Morning
      }
      if (frequency >= 2) {
        _selectedTimes.add(const TimeOfDay(hour: 12, minute: 30)); // Noon
      }
      if (frequency >= 3) {
        _selectedTimes.add(const TimeOfDay(hour: 20, minute: 0)); // Evening
      }
    });
    AnimationUtils.lightHaptic();
  }

  Future<void> _showTimePicker(int index) async {
    final currentTime = _selectedTimes[index];
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: OnboardingTheme.goldColor,
              surface: Color(0xFF1C1C1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTimes[index] = picked);
      await AnimationUtils.lightHaptic();
    }
  }

  Future<void> _onActivateDailyVerses() async {
    if (_isSavingTimes) return;

    setState(() => _isSavingTimes = true);

    try {
      await AnimationUtils.heavyHaptic();

      // Enable daily verse notifications with selected times
      await _dailyVerseService.enableWithMultipleTimes(_selectedTimes);

      debugPrint(
          '✅ [STEP 9] Daily verses enabled with ${_selectedTimes.length} time(s)');

      // Complete onboarding and proceed
      await controller.completeOnboarding();

      if (!mounted) return;

      // Fade out and go to next step
      setState(() => _opacity = 0.0);
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      controller.nextStep();
    } catch (e) {
      debugPrint('❌ Error saving daily verse times: $e');

      // Still proceed even if there's an error
      await controller.completeOnboarding();

      if (!mounted) return;

      controller.nextStep();
    } finally {
      if (mounted) {
        setState(() => _isSavingTimes = false);
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
      controller.nextStep();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getTimeLabel(int index) {
    switch (index) {
      case 0:
        return 'dailyVerses_morning'.tr;
      case 1:
        return 'dailyVerses_afternoon'.tr;
      case 2:
        return 'dailyVerses_evening'.tr;
      default:
        return '';
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

  Widget _buildFrequencyChip(int frequency) {
    final isSelected = _selectedFrequency == frequency;
    final label = '${frequency}x';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () => _onFrequencyChanged(frequency),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? OnboardingTheme.goldColor
                : OnboardingTheme.cardBackground,
            border: Border.all(
              color: isSelected
                  ? OnboardingTheme.goldColor
                  : OnboardingTheme.cardBorder,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
          ),
          child: Text(
            label,
            style: OnboardingTheme.body.copyWith(
              color: isSelected
                  ? OnboardingTheme.backgroundColor
                  : OnboardingTheme.labelPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OnboardingTheme.space12),
      child: GestureDetector(
        onTap: () => _showTimePicker(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: OnboardingTheme.cardBackground,
            border: Border.all(
              color: OnboardingTheme.goldColor.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.clock,
                color: OnboardingTheme.goldColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                _getTimeLabel(index),
                style: OnboardingTheme.subhead.copyWith(
                  color: OnboardingTheme.labelSecondary,
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(_selectedTimes[index]),
                style: OnboardingTheme.body.copyWith(
                  color: OnboardingTheme.labelPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.chevron_right,
                color: OnboardingTheme.labelTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionPhase() {
    return Column(
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
          const SizedBox(height: 20),

          // Judah with time selection
          Center(
            child: Transform.scale(
              scale: 1.8,
              child: JudahMascot(
                state: JudahState.timeSelection,
                size: JudahSize.l,
                showMessage: false,
              ),
            ),
          ),

          const SizedBox(height: 42),

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
              onTap: _isRequestingPermission ? null : _onEnableNotifications,
              backgroundColor: OnboardingTheme.goldColor,
              textColor: OnboardingTheme.backgroundColor,
              style: FastButtonStyle.filled,
              isLoading: _isRequestingPermission,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeSelectionPhase() {
    return AnimatedOpacity(
      opacity: _showTimeSelection ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          // Judah pointing with clock context
          JudahMascot(
            state: JudahState.pointing,
            size: JudahSize.l,
            message: 'dailyVerses_mascot'.tr,
          ),
          const SizedBox(height: OnboardingTheme.space24),

          // Title
          Text(
            'dailyVerses_title'.tr,
            style: OnboardingTheme.title2.copyWith(
              color: OnboardingTheme.labelPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: OnboardingTheme.space8),
          Text(
            'dailyVerses_subtitle'.tr,
            style: OnboardingTheme.callout.copyWith(
              color: OnboardingTheme.labelSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: OnboardingTheme.space32),

          // Frequency selection
          Text(
            'dailyVerses_frequency'.tr,
            style: OnboardingTheme.subhead.copyWith(
              color: OnboardingTheme.goldColor,
            ),
          ),
          const SizedBox(height: OnboardingTheme.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                [1, 2, 3].map((freq) => _buildFrequencyChip(freq)).toList(),
          ),
          const SizedBox(height: OnboardingTheme.space32),

          // Time pickers
          Text(
            'dailyVerses_when'.tr,
            style: OnboardingTheme.subhead.copyWith(
              color: OnboardingTheme.goldColor,
            ),
          ),
          const SizedBox(height: OnboardingTheme.space16),
          ...List.generate(
            _selectedTimes.length,
            (index) => _buildTimePicker(index),
          ),
          const SizedBox(height: OnboardingTheme.space40),

          // Activate button
          FastButton(
            text: 'dailyVerses_activate'.tr,
            onTap: _isSavingTimes ? null : _onActivateDailyVerses,
            backgroundColor: OnboardingTheme.goldColor,
            textColor: OnboardingTheme.backgroundColor,
            style: FastButtonStyle.filled,
            isLoading: _isSavingTimes,
          ),
          const SizedBox(height: OnboardingTheme.space16),

          // Skip link
          GestureDetector(
            onTap: () async {
              await AnimationUtils.lightHaptic();
              await controller.completeOnboarding();
              controller.nextStep();
            },
            child: Text(
              'dailyVerses_later'.tr,
              style: OnboardingTheme.subhead.copyWith(
                color: OnboardingTheme.labelTertiary,
              ),
            ),
          ),
        ],
      ),
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
            padding: EdgeInsets.only(
              left: OnboardingTheme.horizontalPadding,
              right: OnboardingTheme.horizontalPadding,
              top: _currentPhase == 'timeSelection' ? 70 : 40,
              bottom: OnboardingTheme.verticalPadding,
            ),
            child: _currentPhase == 'permission'
                ? _buildPermissionPhase()
                : _buildTimeSelectionPhase(),
          ),
        ),
      ),
    );
  }
}
