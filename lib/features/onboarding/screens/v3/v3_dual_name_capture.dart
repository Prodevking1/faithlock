import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v3_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/inputs/fast_text_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V3 Dual Name Capture - Laura's poetic dual prompt.
/// "What should Toby call you — and what name do you carry before God?"
///
/// Field 1 (required) → controller.userName (used everywhere downstream)
/// Field 2 (optional) → controller.godName (V3-only, faith name)
class V3DualNameCapture extends StatefulWidget {
  final VoidCallback onComplete;
  const V3DualNameCapture({super.key, required this.onComplete});

  @override
  State<V3DualNameCapture> createState() => _V3DualNameCaptureState();
}

class _V3DualNameCaptureState extends State<V3DualNameCapture> {
  final controller = Get.find<ScriptureOnboardingV3Controller>();
  final _displayCtrl = TextEditingController();
  final _godCtrl = TextEditingController();
  final _displayFocus = FocusNode();
  final _godFocus = FocusNode();

  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _displayFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _displayCtrl.dispose();
    _godCtrl.dispose();
    _displayFocus.dispose();
    _godFocus.dispose();
    super.dispose();
  }

  bool get _isValid => _displayCtrl.text.trim().isNotEmpty;

  Future<void> _onContinue() async {
    if (!_isValid) return;

    await controller.saveUserName(_displayCtrl.text.trim());
    await controller.saveGodName(_godCtrl.text.trim());
    await AnimationUtils.heavyHaptic();

    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 400));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 400),
        child: Padding(
          padding: const EdgeInsets.only(
            left: OnboardingTheme.horizontalPadding,
            right: OnboardingTheme.horizontalPadding,
            top: 100,
            bottom: OnboardingTheme.verticalPadding,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What should ${ScriptureOnboardingV3Controller.mascotName} call you?',
                  style: OnboardingTheme.title2,
                ),
                const SizedBox(height: OnboardingTheme.space24),
                FastTextInput(
                  controller: _displayCtrl,
                  focusNode: _displayFocus,
                  hintText: 'Your everyday name',
                  textCapitalization: TextCapitalization.words,
                  textStyle: OnboardingTheme.title3.copyWith(
                    color: OnboardingTheme.goldColor,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: OnboardingTheme.space40),
                Text(
                  'And the name you carry before God?',
                  style: OnboardingTheme.title2,
                ),
                const SizedBox(height: OnboardingTheme.space8),
                Text(
                  'Optional. A baptismal name, a confirmation name, or whatever feels right.',
                  style: OnboardingTheme.footnote.copyWith(
                    color: OnboardingTheme.labelSecondary,
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space16),
                FastTextInput(
                  controller: _godCtrl,
                  focusNode: _godFocus,
                  hintText: 'Your name before God',
                  textCapitalization: TextCapitalization.words,
                  textStyle: OnboardingTheme.title3.copyWith(
                    color: OnboardingTheme.goldColor.withValues(alpha: 0.85),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space40),
                FastButton(
                  text: 'Continue',
                  onTap: _isValid ? _onContinue : null,
                  backgroundColor: OnboardingTheme.goldColor,
                  textColor: OnboardingTheme.backgroundColor,
                  style: FastButtonStyle.filled,
                  isDisabled: !_isValid,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
