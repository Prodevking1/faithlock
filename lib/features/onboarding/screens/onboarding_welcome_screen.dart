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

/// Onboarding Welcome Screen - First onboarding step
/// Introduces Judah mascot, app purpose, and language selection (EN/FR)
class OnBoardingWelcomeScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnBoardingWelcomeScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnBoardingWelcomeScreen> createState() => _OnBoardingWelcomeScreenState();
}

class _OnBoardingWelcomeScreenState extends State<OnBoardingWelcomeScreen> {
  final PostHogService _analytics = PostHogService.instance;

  bool _showMascot = false;
  bool _showButton = false;
  bool _showLanguagePicker = false;
  bool _showCursor = false;
  int _currentCharIndex = 0;
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
    await AnimationUtils.mediumHaptic();
    await Future.delayed(const Duration(milliseconds: 600));

    // Type the message character by character with colors
    await _typeStyledMessage();

    await AnimationUtils.pause(durationMs: 200);

    // Show language picker and button
    setState(() {
      _showLanguagePicker = true;
      _showButton = true;
    });
    await AnimationUtils.mediumHaptic();
  }

  /// Get the full message text from all parts
  String get _fullMessage =>
      'welcome_part1'.tr +
      'welcome_name'.tr +
      'welcome_part2'.tr +
      'welcome_highlight1'.tr +
      'welcome_part3'.tr +
      'welcome_highlight2'.tr +
      'welcome_part4'.tr;

  /// Type the styled message character by character
  Future<void> _typeStyledMessage() async {
    final fullText = _fullMessage;
    // Use characters to properly count grapheme clusters (handles accents, emojis)
    final charCount = fullText.characters.length;

    setState(() {
      _currentCharIndex = 0;
      _showCursor = true;
    });

    for (int i = 0; i <= charCount; i++) {
      if (!mounted) return;
      setState(() => _currentCharIndex = i);
      await Future.delayed(const Duration(milliseconds: 35));
    }

    setState(() => _showCursor = false);
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
      _currentCharIndex = 0;
      _showButton = false;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    await _typeStyledMessage();

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
                    state: JudahState.happy,
                    size: JudahSize.xl,
                    showMessage: false,
                  ),
                ),

              if (_showMascot) const SizedBox(height: OnboardingTheme.space32),

              // Typed welcome message with colors
              if (_showMascot) _buildTypingStyledMessage(),

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

  Widget _buildTypingStyledMessage() {
    final baseStyle = OnboardingTheme.title3.copyWith(
      color: OnboardingTheme.labelPrimary,
    );
    final goldStyle = OnboardingTheme.title3.copyWith(
      color: OnboardingTheme.goldColor,
      fontWeight: FontWeight.w600,
    );

    // Define text parts with their styles
    final parts = [
      ('welcome_part1'.tr, false),
      ('welcome_name'.tr, true), // gold
      ('welcome_part2'.tr, false),
      ('welcome_highlight1'.tr, true), // gold
      ('welcome_part3'.tr, false),
      ('welcome_highlight2'.tr, true), // gold
      ('welcome_part4'.tr, false),
    ];

    // Build spans based on current character index
    // Use characters for proper grapheme cluster handling (accents, emojis)
    final spans = <InlineSpan>[];
    int charCount = 0;

    for (final (text, isGold) in parts) {
      if (charCount >= _currentCharIndex) break;

      final textChars = text.characters;
      final textLength = textChars.length;
      final remainingChars = _currentCharIndex - charCount;

      // Use characters.take() for proper grapheme cluster slicing
      final visibleText = textLength <= remainingChars
          ? text
          : textChars.take(remainingChars).toString();

      if (visibleText.isNotEmpty) {
        spans.add(TextSpan(
          text: visibleText,
          style: isGold ? goldStyle : baseStyle,
        ));
      }

      charCount += textLength;
    }

    // Add cursor at the end
    if (_showCursor) {
      spans.add(const WidgetSpan(
        child: FeatherCursor(),
        alignment: PlaceholderAlignment.middle,
      ));
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        children: spans,
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
