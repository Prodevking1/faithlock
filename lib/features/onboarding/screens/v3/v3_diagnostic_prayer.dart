import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v3_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/controls/fast_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V3 Diagnostic - Prayer frequency per week.
/// Slider input. Saves to controller.prayerTimesPerWeek (inherited from V1).
class V3DiagnosticPrayer extends StatefulWidget {
  final VoidCallback onComplete;
  const V3DiagnosticPrayer({super.key, required this.onComplete});

  @override
  State<V3DiagnosticPrayer> createState() => _V3DiagnosticPrayerState();
}

class _V3DiagnosticPrayerState extends State<V3DiagnosticPrayer> {
  final controller = Get.find<ScriptureOnboardingV3Controller>();
  double _times = 0;
  double _opacity = 1.0;

  Color _color() {
    if (_times == 0) return OnboardingTheme.labelTertiary;
    if (_times < 4) return OnboardingTheme.systemRed;
    if (_times < 7) return OnboardingTheme.systemOrange;
    if (_times < 14) return OnboardingTheme.goldColor;
    return OnboardingTheme.systemGreen;
  }

  Future<void> _onContinue() async {
    await controller.savePrayerFrequency(_times.toInt());
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
                'And how often do you pray each week — honestly?',
                style: OnboardingTheme.title2,
              ),
              const Spacer(),
              Center(
                child: Text(
                  _times.toInt().toString(),
                  style: OnboardingTheme.displayNumber.copyWith(color: _color()),
                ),
              ),
              const SizedBox(height: OnboardingTheme.space4),
              Center(
                child: Text(
                  'times per week',
                  style: OnboardingTheme.displayUnit,
                ),
              ),
              const SizedBox(height: OnboardingTheme.space40),
              FastSlider(
                value: _times,
                min: 0,
                max: 21,
                divisions: 21,
                activeColor: _color(),
                onChanged: (v) {
                  AnimationUtils.selectionHaptic();
                  setState(() => _times = v);
                },
              ),
              const Spacer(),
              FastButton(
                text: 'Continue',
                onTap: _onContinue,
                backgroundColor: OnboardingTheme.goldColor,
                textColor: OnboardingTheme.backgroundColor,
                style: FastButtonStyle.filled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
