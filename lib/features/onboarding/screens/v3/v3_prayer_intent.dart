import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v3_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V3 Prayer Intent - "How many times a day do you want to pray —
/// honestly, not ideally?" 1× / 2× / 3× / More
class V3PrayerIntent extends StatefulWidget {
  final VoidCallback onComplete;
  const V3PrayerIntent({super.key, required this.onComplete});

  @override
  State<V3PrayerIntent> createState() => _V3PrayerIntentState();
}

class _V3PrayerIntentState extends State<V3PrayerIntent> {
  final controller = Get.find<ScriptureOnboardingV3Controller>();
  String? _selected;
  double _opacity = 1.0;

  static const _options = ['1×', '2×', '3×', 'More'];

  Future<void> _onContinue() async {
    if (_selected == null) return;
    await controller.savePrayerIntent(_selected!);
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
                'How many times a day do you want to pray — honestly, not ideally?',
                style: OnboardingTheme.title2,
              ),
              const SizedBox(height: OnboardingTheme.space40),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.6,
                  children: _options.map((opt) {
                    final selected = _selected == opt;
                    return GestureDetector(
                      onTap: () {
                        AnimationUtils.lightHaptic();
                        setState(() => _selected = opt);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: selected
                              ? OnboardingTheme.goldColor
                                  .withValues(alpha: 0.18)
                              : OnboardingTheme.cardBackground,
                          borderRadius: BorderRadius.circular(
                              OnboardingTheme.radiusLarge),
                          border: Border.all(
                            color: selected
                                ? OnboardingTheme.goldColor
                                : OnboardingTheme.cardBorder,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            opt,
                            style: OnboardingTheme.title1.copyWith(
                              color: selected
                                  ? OnboardingTheme.goldColor
                                  : OnboardingTheme.labelPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: OnboardingTheme.space24),
              FastButton(
                text: 'Continue',
                onTap: _selected != null ? _onContinue : null,
                backgroundColor: OnboardingTheme.goldColor,
                textColor: OnboardingTheme.backgroundColor,
                style: FastButtonStyle.filled,
                isDisabled: _selected == null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
