import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// V2 Welcome Screen - First onboarding step
/// Introduces Judah mascot, app purpose, and language selection (EN/FR)
class V2WelcomeScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const V2WelcomeScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<V2WelcomeScreen> createState() => _V2WelcomeScreenState();
}

class _V2WelcomeScreenState extends State<V2WelcomeScreen> {
  final PostHogService _analytics = PostHogService.instance;

  String _messageText = '';
  bool _showCursor = false;
  bool _showMascot = false;
  bool _showButton = false;
  bool _showLanguagePicker = false;
  double _opacity = 1.0;

  // Current language selection
  String _selectedLang = 'en_US';

  @override
  void initState() {
    super.initState();
    // Detect current locale
    final locale = Get.locale;
    if (locale != null && locale.languageCode == 'fr') {
      _selectedLang = 'fr_FR';
    }
    _startAnimation();
    _trackStepEntry();
  }

  Future<void> _trackStepEntry() async {
    if (_analytics.isReady) {
      await _analytics.onboarding.trackStepEntry(
        stepNumber: 1,
        stepName: 'Welcome',
      );
    }
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Show mascot
    setState(() => _showMascot = true);
    await Future.delayed(const Duration(milliseconds: 600));

    // Type the welcome message
    await AnimationUtils.typeText(
      fullText: 'welcome_message'.tr,
      onUpdate: (text) => setState(() => _messageText = text),
      onCursorVisibility: (visible) => setState(() => _showCursor = visible),
    );

    await AnimationUtils.pause(durationMs: 200);

    // Show language picker and button
    setState(() {
      _showLanguagePicker = true;
      _showButton = true;
    });
    await AnimationUtils.mediumHaptic();
  }

  Future<void> _onLanguageSelected(String langCode) async {
    if (_selectedLang == langCode) return;

    await AnimationUtils.lightHaptic();
    setState(() => _selectedLang = langCode);

    // Update locale
    if (langCode == 'fr_FR') {
      Get.updateLocale(const Locale('fr', 'FR'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }

    // Persist choice
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', langCode == 'fr_FR' ? 'fr' : 'en');

    // Track language selection
    if (_analytics.isReady) {
      await _analytics.events.trackCustom(
        'language_selected',
        {
          'language': langCode,
          'step': 'welcome',
        },
      );
    }

    // Re-type message in new language
    setState(() {
      _messageText = '';
      _showCursor = false;
      _showButton = false;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    await AnimationUtils.typeText(
      fullText: 'welcome_message'.tr,
      onUpdate: (text) => setState(() => _messageText = text),
      onCursorVisibility: (visible) => setState(() => _showCursor = visible),
    );

    setState(() => _showButton = true);
  }

  Future<void> _onContinue() async {
    await AnimationUtils.heavyHaptic();

    // Track step exit
    if (_analytics.isReady) {
      await _analytics.onboarding.trackStepExit(
        stepNumber: 1,
        stepName: 'Welcome',
        metadata: {'language': _selectedLang},
      );
    }

    // Fade out
    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 800));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 800),
        child: Padding(
          padding: const EdgeInsets.only(
            left: OnboardingTheme.horizontalPadding,
            right: OnboardingTheme.horizontalPadding,
            top: 80,
            bottom: OnboardingTheme.verticalPadding,
          ),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Judah mascot
              if (_showMascot)
                AnimatedOpacity(
                  opacity: _showMascot ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: const JudahMascot(
                    state: JudahState.neutral,
                    size: JudahSize.xl,
                    showMessage: false,
                  ),
                ),

              if (_showMascot && _messageText.isNotEmpty)
                const SizedBox(height: OnboardingTheme.space32),

              // Typed welcome message
              if (_messageText.isNotEmpty)
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: OnboardingTheme.title3.copyWith(
                      color: OnboardingTheme.labelPrimary,
                    ),
                    children: [
                      TextSpan(text: _messageText),
                      if (_showCursor)
                        const WidgetSpan(
                          child: FeatherCursor(),
                          alignment: PlaceholderAlignment.middle,
                        ),
                    ],
                  ),
                ),

              const Spacer(flex: 2),

              // Continue button
              AnimatedOpacity(
                opacity: _showButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: FastButton(
                  text: 'continue_btn'.tr,
                  onTap: _showButton ? _onContinue : null,
                  backgroundColor: OnboardingTheme.goldColor,
                  textColor: OnboardingTheme.backgroundColor,
                  style: FastButtonStyle.filled,
                ),
              ),

              const SizedBox(height: OnboardingTheme.space32),

              // Language picker
              AnimatedOpacity(
                opacity: _showLanguagePicker ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLanguageOption(
                      flag: '\u{1F1FA}\u{1F1F8}',
                      label: 'English',
                      langCode: 'en_US',
                    ),
                    const SizedBox(width: 24),
                    Container(
                      width: 1,
                      height: 24,
                      color: OnboardingTheme.labelTertiary,
                    ),
                    const SizedBox(width: 24),
                    _buildLanguageOption(
                      flag: '\u{1F1EB}\u{1F1F7}',
                      label: 'Fran\u00e7ais',
                      langCode: 'fr_FR',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: OnboardingTheme.space16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String label,
    required String langCode,
  }) {
    final isSelected = _selectedLang == langCode;

    return GestureDetector(
      onTap: () => _onLanguageSelected(langCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? OnboardingTheme.goldColor.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? OnboardingTheme.goldColor
                : OnboardingTheme.labelTertiary,
            width: isSelected ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: OnboardingTheme.subhead.copyWith(
                color: isSelected
                    ? OnboardingTheme.goldColor
                    : OnboardingTheme.labelSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
