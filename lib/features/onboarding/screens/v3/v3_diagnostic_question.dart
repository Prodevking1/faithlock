import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v3_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Generic single-question diagnostic screen for V3.
/// Used for qualitative reflection questions (no slider, just choices).
class V3DiagnosticQuestion extends StatefulWidget {
  final VoidCallback onComplete;
  final String questionKey;
  final String question;
  final List<String> options;

  const V3DiagnosticQuestion({
    super.key,
    required this.onComplete,
    required this.questionKey,
    required this.question,
    required this.options,
  });

  @override
  State<V3DiagnosticQuestion> createState() => _V3DiagnosticQuestionState();
}

class _V3DiagnosticQuestionState extends State<V3DiagnosticQuestion> {
  final controller = Get.find<ScriptureOnboardingV3Controller>();
  String? _selected;
  double _opacity = 1.0;

  Future<void> _select(String option) async {
    setState(() => _selected = option);
    await AnimationUtils.lightHaptic();
  }

  Future<void> _onContinue() async {
    if (_selected == null) return;

    await controller.saveDiagnosticAnswer(widget.questionKey, _selected!);
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
                widget.question,
                style: OnboardingTheme.title2.copyWith(
                  color: OnboardingTheme.labelPrimary,
                ),
              ),
              const SizedBox(height: OnboardingTheme.space32),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.options.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: OnboardingTheme.space12),
                  itemBuilder: (context, index) {
                    final option = widget.options[index];
                    final isSelected = _selected == option;
                    return _OptionCard(
                      label: option,
                      isSelected: isSelected,
                      onTap: () => _select(option),
                    );
                  },
                ),
              ),
              const SizedBox(height: OnboardingTheme.space16),
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

class _OptionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? OnboardingTheme.goldColor.withValues(alpha: 0.15)
              : OnboardingTheme.cardBackground,
          borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
          border: Border.all(
            color: isSelected
                ? OnboardingTheme.goldColor
                : OnboardingTheme.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: OnboardingTheme.callout.copyWith(
                  color: isSelected
                      ? OnboardingTheme.goldColor
                      : OnboardingTheme.labelPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.check_circle,
                color: OnboardingTheme.goldColor,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
