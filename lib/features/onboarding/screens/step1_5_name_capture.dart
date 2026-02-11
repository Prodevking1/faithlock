import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:faithlock/shared/widgets/inputs/fast_text_input.dart';
import 'package:flutter/cupertino.dart';
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
  int _userAge = 21;
  late FixedExtentScrollController _ageScrollController;

  double _opacity = 1.0;

  // Age range: 13 to 110
  static const int _minAge = 13;
  static const int _maxAge = 110;
  List<int> get _ageItems => List.generate(_maxAge - _minAge + 1, (i) => _minAge + i);

  @override
  void initState() {
    super.initState();
    // Initialize scroll controller to position at default age (21)
    _ageScrollController = FixedExtentScrollController(
      initialItem: _userAge - _minAge,
    );
    _startAnimation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _ageScrollController.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(Duration(milliseconds: 300));

    // Show Judah mascot first
    // setState(() => _showMascot = true);
    // await Future.delayed(Duration(milliseconds: 600));

    // Ask for name first (iOS-optimized timing)
    await AnimationUtils.typeText(
      fullText: 'nameCapture_intro'.tr,
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
      fullText: 'nameCapture_ageQuestion'.trParams({'name': name}),
      onUpdate: (text) => setState(() => _introText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showIntroCursor = visible),
    );

    await AnimationUtils.pause(durationMs: AnimationUtils.pauseShort);

    setState(() => _showAgeInput = true);
    await AnimationUtils.mediumHaptic();
  }

  void _onAgeChanged(int value) {
    setState(() => _userAge = value);
  }

  Future<void> _proceedToNextStep() async {
    await controller.saveUserAge(_userAge);
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
          child: SingleChildScrollView(
            child: Column(
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
                      hintText: 'nameCapture_hint'.tr,
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
                      text: 'continue_btn'.tr,
                      onTap: _onNameSubmit,
                      backgroundColor: OnboardingTheme.goldColor,
                      textColor: OnboardingTheme.backgroundColor,
                      style: FastButtonStyle.filled,
                    ),
                  ),
                ],

                if (_showAgeInput) ...[
                  const SizedBox(height: OnboardingTheme.space24),
                  // Age picker wheel
                  SizedBox(
                    height: 180,
                    child: Stack(
                      children: [
                        // Selection highlight
                        Center(
                          child: Container(
                            height: 44,
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            decoration: BoxDecoration(
                              color: OnboardingTheme.goldColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: OnboardingTheme.goldColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        // Picker wheel
                        CupertinoPicker(
                          scrollController: _ageScrollController,
                          itemExtent: 44,
                          diameterRatio: 1.2,
                          selectionOverlay: const SizedBox.shrink(),
                          onSelectedItemChanged: (index) {
                            _onAgeChanged(_ageItems[index]);
                          },
                          children: _ageItems.map((age) {
                            final isSelected = age == _userAge;
                            return Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    age.toString(),
                                    style: OnboardingTheme.displayNumber.copyWith(
                                      color: isSelected
                                          ? OnboardingTheme.goldColor
                                          : OnboardingTheme.labelSecondary,
                                      fontSize: isSelected ? 32 : 24,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'nameCapture_yearsOld'.tr,
                                    style: OnboardingTheme.subhead.copyWith(
                                      color: isSelected
                                          ? OnboardingTheme.goldColor.withOpacity(0.7)
                                          : OnboardingTheme.labelTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: OnboardingTheme.space32),
                  // Continue button
                  Center(
                    child: FastButton(
                      text: 'continue_btn'.tr,
                      onTap: _proceedToNextStep,
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
      ),
    );
  }
}
