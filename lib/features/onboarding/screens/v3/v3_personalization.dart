import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v3_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V3 Personalization - Tradition + spiritual state + prayer practice + moments.
/// Single scrollable screen, all selections required.
class V3Personalization extends StatefulWidget {
  final VoidCallback onComplete;
  const V3Personalization({super.key, required this.onComplete});

  @override
  State<V3Personalization> createState() => _V3PersonalizationState();
}

class _V3PersonalizationState extends State<V3Personalization> {
  final controller = Get.find<ScriptureOnboardingV3Controller>();

  String? _tradition;
  String? _state;
  final Set<String> _practices = {};
  final Set<String> _moments = {};
  double _opacity = 1.0;

  static const _traditions = [
    'Catholic',
    'Protestant',
    'Evangelical',
    'Orthodox',
    'Still figuring it out',
  ];

  static const _states = [
    "We're close, but I've drifted",
    'I want to rebuild something real',
    "I'm just starting this journey",
    "I'm strong — I want to go deeper",
  ];

  static const _practiceOptions = [
    'Daily Mass',
    'The Rosary',
    'Lectio Divina',
    'The Divine Office',
    'Simple personal prayer',
    'Not sure yet',
  ];

  static const _momentOptions = [
    'First thing in the morning',
    'During my commute',
    'At lunch',
    'Before bed',
    'None — I need help finding one',
  ];

  bool get _isValid =>
      _tradition != null &&
      _state != null &&
      _practices.isNotEmpty &&
      _moments.isNotEmpty;

  Future<void> _onContinue() async {
    if (!_isValid) return;

    await controller.saveFaithTradition(_tradition!);
    await controller.saveSpiritualState(_state!);
    await controller.savePrayerPractices(_practices.toList());
    await controller.savePrayerMoments(_moments.toList());
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
        child: Stack(
          children: [
            Positioned.fill(
              bottom: 100,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: OnboardingTheme.horizontalPadding,
                  right: OnboardingTheme.horizontalPadding,
                  top: 100,
                  bottom: OnboardingTheme.space24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Let's tailor this to your faith.",
                      style: OnboardingTheme.title2,
                    ),
                    const SizedBox(height: OnboardingTheme.space32),
                    _Section(
                      label: 'Which tradition best describes you?',
                      child: _ChipGroup(
                        options: _traditions,
                        selected: _tradition == null ? const {} : {_tradition!},
                        onSelect: (v) {
                          AnimationUtils.lightHaptic();
                          setState(() => _tradition = v);
                        },
                      ),
                    ),
                    _Section(
                      label: 'Where are you with God right now?',
                      child: _ChipGroup(
                        options: _states,
                        selected: _state == null ? const {} : {_state!},
                        onSelect: (v) {
                          AnimationUtils.lightHaptic();
                          setState(() => _state = v);
                        },
                      ),
                    ),
                    _Section(
                      label:
                          'Prayer practices you\'d like to rebuild or discover?',
                      hint: 'Select all that apply',
                      child: _ChipGroup(
                        options: _practiceOptions,
                        selected: _practices,
                        multi: true,
                        onSelect: (v) {
                          AnimationUtils.lightHaptic();
                          setState(() {
                            if (_practices.contains(v)) {
                              _practices.remove(v);
                            } else {
                              _practices.add(v);
                            }
                          });
                        },
                      ),
                    ),
                    _Section(
                      label: 'Which moments feel most open to God?',
                      hint: 'Select one or more',
                      child: _ChipGroup(
                        options: _momentOptions,
                        selected: _moments,
                        multi: true,
                        onSelect: (v) {
                          AnimationUtils.lightHaptic();
                          setState(() {
                            if (_moments.contains(v)) {
                              _moments.remove(v);
                            } else {
                              _moments.add(v);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: OnboardingTheme.horizontalPadding,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      OnboardingTheme.backgroundColor.withValues(alpha: 0.0),
                      OnboardingTheme.backgroundColor,
                    ],
                  ),
                ),
                child: FastButton(
                  text: 'Continue',
                  onTap: _isValid ? _onContinue : null,
                  backgroundColor: OnboardingTheme.goldColor,
                  textColor: OnboardingTheme.backgroundColor,
                  style: FastButtonStyle.filled,
                  isDisabled: !_isValid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget child;
  const _Section({required this.label, required this.child, this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OnboardingTheme.space32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: OnboardingTheme.callout
                .copyWith(color: OnboardingTheme.labelPrimary),
          ),
          if (hint != null) ...[
            const SizedBox(height: OnboardingTheme.space4),
            Text(
              hint!,
              style: OnboardingTheme.footnote,
            ),
          ],
          const SizedBox(height: OnboardingTheme.space16),
          child,
        ],
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final bool multi;
  final ValueChanged<String> onSelect;

  const _ChipGroup({
    required this.options,
    required this.selected,
    required this.onSelect,
    this.multi = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? OnboardingTheme.goldColor.withValues(alpha: 0.15)
                  : OnboardingTheme.cardBackground,
              borderRadius:
                  BorderRadius.circular(OnboardingTheme.radiusMedium),
              border: Border.all(
                color: isSelected
                    ? OnboardingTheme.goldColor
                    : OnboardingTheme.cardBorder,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              opt,
              style: OnboardingTheme.subhead.copyWith(
                color: isSelected
                    ? OnboardingTheme.goldColor
                    : OnboardingTheme.labelPrimary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
