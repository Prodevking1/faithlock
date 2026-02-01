import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:faithlock/shared/widgets/controls/fast_slider.dart';
import 'package:faithlock/shared/widgets/inputs/fast_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Step 1.5: Name Capture - Personal Connection
/// Captures user's name for personalization throughout onboarding
class Step1_5NameCapture extends StatefulWidget {
  final VoidCallback onComplete;

  const Step1_5NameCapture({
    super.key,
    required this.onComplete,
  });

  @override
  State<Step1_5NameCapture> createState() => _Step1_5NameCaptureState();
}

class _Step1_5NameCaptureState extends State<Step1_5NameCapture> {
  final controller = Get.find<ScriptureOnboardingController>();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  String _introText = '';
  bool _showIntroCursor = false;
  bool _showMascot = false;
  bool _showNameInput = false;
  bool _showAgeInput = false;
  double _userAge = 21.0;

  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(Duration(milliseconds: 300));

    // Show Judah mascot first
    setState(() => _showMascot = true);
    await Future.delayed(Duration(milliseconds: 600));

    // Ask for name first (iOS-optimized timing)
    await AnimationUtils.typeText(
      fullText: 'Before we continue...\nWhat is your name?',
      onUpdate: (text) => setState(() => _introText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showIntroCursor = visible),
    );

    // Show input almost immediately after text finishes
    await AnimationUtils.pause(durationMs: 100);

    setState(() => _showNameInput = true);
    await AnimationUtils.mediumHaptic();

    // Auto-focus the name input field
    _nameFocusNode.requestFocus();
  }

  Future<void> _onNameSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await controller.saveUserName(name);
    await AnimationUtils.heavyHaptic();

    // Hide name input, mascot, and ask for age
    setState(() {
      _showNameInput = false;
      _showMascot = false;
      _introText = '';
      _showIntroCursor = false;
    });

    await Future.delayed(Duration(milliseconds: AnimationUtils.pauseShort));

    await AnimationUtils.typeText(
      fullText: 'How old are you, $name?',
      onUpdate: (text) => setState(() => _introText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showIntroCursor = visible),
    );

    await AnimationUtils.pause(durationMs: AnimationUtils.pauseShort);

    setState(() => _showAgeInput = true);
    await AnimationUtils.mediumHaptic();
  }

  void _onAgeChanged(double value) {
    AnimationUtils.mediumHaptic();
    setState(() => _userAge = value);
  }

  Future<void> _proceedToNextStep() async {
    await controller.saveUserAge(_userAge.round());
    await AnimationUtils.heavyHaptic();

    // Transition to next step (iOS-optimized)
    setState(() => _opacity = 0.0);
    await Future.delayed(Duration(milliseconds: AnimationUtils.fadeMs));
    await AnimationUtils.heavyHaptic();
    await Future.delayed(Duration(milliseconds: AnimationUtils.pauseShort));

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 1000),
        child: Padding(
          padding: const EdgeInsets.only(
            left: OnboardingTheme.horizontalPadding,
            right: OnboardingTheme.horizontalPadding,
            top: 100, // Space for progress bar
            bottom: OnboardingTheme.verticalPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judah mascot greeting
              if (_showMascot)
                Center(
                  child: AnimatedOpacity(
                    opacity: _showMascot ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 600),
                    child: const JudahMascot(
                      state: JudahState.neutral,
                      size: JudahSize.xl,
                      showMessage: false,
                    ),
                  ),
                ),
              if (_showMascot && _introText.isNotEmpty)
                const SizedBox(height: OnboardingTheme.space24),

              // Intro text (iOS-styled, centered)
              if (_introText.isNotEmpty)
                RichText(
                  text: TextSpan(
                    style: OnboardingTheme.title3,
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

              // Name Input
              if (_showNameInput) ...[
                const SizedBox(height: OnboardingTheme.space40),
                KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (KeyEvent event) {
                    if (event is KeyDownEvent &&
                        (event.logicalKey == LogicalKeyboardKey.enter ||
                            event.logicalKey ==
                                LogicalKeyboardKey.numpadEnter)) {
                      _onNameSubmit();
                    }
                  },
                  child: FastTextInput(
                    controller: _nameController,
                    hintText: 'Your name',
                    textCapitalization: TextCapitalization.words,
                    focusNode: _nameFocusNode,
                    textStyle: OnboardingTheme.title3.copyWith(
                      color: OnboardingTheme.goldColor,
                    ),
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space32),
                Center(
                  child: FastButton(
                    text: 'Continue',
                    onTap: _onNameSubmit,
                    backgroundColor: OnboardingTheme.goldColor,
                    textColor: OnboardingTheme.backgroundColor,
                    style: FastButtonStyle.filled,
                  ),
                ),
              ],

              if (_showAgeInput) ...[
                const SizedBox(height: OnboardingTheme.space32),
                Center(
                  child: Text(
                    _userAge.round().toString(),
                    style: OnboardingTheme.displayNumber.copyWith(
                      color: OnboardingTheme.goldColor,
                    ),
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space4),
                Center(
                  child: Text(
                    'years old',
                    style: OnboardingTheme.displayUnit,
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space32),
                Center(
                  child: FastSlider(
                    value: _userAge,
                    min: 13,
                    max: 110,
                    divisions: 110,
                    activeColor: OnboardingTheme.goldColor,
                    onChanged: _onAgeChanged,
                  ),
                ),

                const SizedBox(height: OnboardingTheme.space32),
                // // iOS-style instruction
                // Center(
                //   child: Text(
                //     'Slide to select your age',
                //     style: OnboardingTheme.subhead.copyWith(
                //       fontWeight: FontWeight.w600,
                //       color: OnboardingTheme.goldColor
                //           .withValues(alpha: 0.7),
                //     ),
                //     textAlign: TextAlign.center,
                //   ),
                // ),
                // const SizedBox(height: OnboardingTheme.space24),
                // Continue button
                Center(
                  child: FastButton(
                    text: 'Continue',
                    onTap: _userAge >= 13 ? _proceedToNextStep : null,
                    backgroundColor: OnboardingTheme.goldColor,
                    textColor: OnboardingTheme.backgroundColor,
                    style: FastButtonStyle.filled,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
