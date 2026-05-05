import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v3_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/controls/fast_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V3 Diagnostic - Hours per day on phone.
/// Slider input. Saves to controller.hoursPerDay (inherited from V1).
class V3DiagnosticHours extends StatefulWidget {
  final VoidCallback onComplete;
  const V3DiagnosticHours({super.key, required this.onComplete});

  @override
  State<V3DiagnosticHours> createState() => _V3DiagnosticHoursState();
}

class _V3DiagnosticHoursState extends State<V3DiagnosticHours> {
  final controller = Get.find<ScriptureOnboardingV3Controller>();
  double _hours = 0;
  double _opacity = 1.0;

  Color _color() {
    if (_hours == 0) return OnboardingTheme.labelTertiary;
    if (_hours < 2) return OnboardingTheme.systemGreen;
    if (_hours < 4) return OnboardingTheme.goldColor;
    if (_hours < 6) return OnboardingTheme.systemOrange;
    return OnboardingTheme.systemRed;
  }

  String _format() {
    if (_hours == _hours.roundToDouble()) return _hours.toInt().toString();
    return _hours.toStringAsFixed(1);
  }

  Future<void> _onContinue() async {
    if (_hours <= 0) return;
    await controller.saveHoursPerDay(_hours);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "What's your daily average screen time?",
                style: OnboardingTheme.title2,
              ),
              const Spacer(),
              Center(
                child: Text(
                  _format(),
                  style: OnboardingTheme.displayNumber.copyWith(color: _color()),
                ),
              ),
              const SizedBox(height: OnboardingTheme.space4),
              Center(
                child: Text(
                  'hours per day',
                  style: OnboardingTheme.displayUnit,
                ),
              ),
              const SizedBox(height: OnboardingTheme.space40),
              FastSlider(
                value: _hours,
                min: 0,
                max: 16,
                divisions: 32,
                activeColor: _color(),
                onChanged: (v) {
                  AnimationUtils.selectionHaptic();
                  setState(() => _hours = v);
                },
              ),
              const Spacer(),
              FastButton(
                text: 'Continue',
                onTap: _hours > 0 ? _onContinue : null,
                backgroundColor: OnboardingTheme.goldColor,
                textColor: OnboardingTheme.backgroundColor,
                style: FastButtonStyle.filled,
                isDisabled: _hours <= 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
