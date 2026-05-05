import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v3_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V3 Apps & Rules - Apps to block + unblock rules.
/// Reuses controller.saveSelectedApps (inherited from V1).
class V3AppsAndRules extends StatefulWidget {
  final VoidCallback onComplete;
  const V3AppsAndRules({super.key, required this.onComplete});

  @override
  State<V3AppsAndRules> createState() => _V3AppsAndRulesState();
}

class _V3AppsAndRulesState extends State<V3AppsAndRules> {
  final controller = Get.find<ScriptureOnboardingV3Controller>();

  final Set<String> _apps = {};
  String? _unblockRule;
  double _opacity = 1.0;

  static const _appOptions = [
    _AppEntry('Instagram', '📸'),
    _AppEntry('TikTok', '🎵'),
    _AppEntry('X / Twitter', '𝕏'),
    _AppEntry('YouTube', '▶️'),
    _AppEntry('Facebook', 'f'),
    _AppEntry('Reddit', '🅡'),
    _AppEntry('News apps', '📰'),
    _AppEntry('Other', '➕'),
  ];

  static const _ruleOptions = [
    'Yes, during work hours',
    'Yes, for specific contacts',
    'No — block them fully',
    "I'll decide later",
  ];

  bool get _isValid => _apps.isNotEmpty && _unblockRule != null;

  Future<void> _onContinue() async {
    if (!_isValid) return;

    await controller.saveSelectedApps(_apps.toList());
    await controller.saveUnblockRules([_unblockRule!]);
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
                      'Which apps steal the most of your time?',
                      style: OnboardingTheme.title2,
                    ),
                    const SizedBox(height: OnboardingTheme.space12),
                    Text(
                      'Select all that apply',
                      style: OnboardingTheme.footnote,
                    ),
                    const SizedBox(height: OnboardingTheme.space20),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                      children: _appOptions.map((app) {
                        final selected = _apps.contains(app.label);
                        return _AppTile(
                          entry: app,
                          selected: selected,
                          onTap: () {
                            AnimationUtils.lightHaptic();
                            setState(() {
                              if (selected) {
                                _apps.remove(app.label);
                              } else {
                                _apps.add(app.label);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: OnboardingTheme.space40),
                    Text(
                      'Need them unblocked sometimes — for work or family?',
                      style: OnboardingTheme.callout,
                    ),
                    const SizedBox(height: OnboardingTheme.space16),
                    ..._ruleOptions.map((rule) {
                      final selected = _unblockRule == rule;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            AnimationUtils.lightHaptic();
                            setState(() => _unblockRule = rule);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? OnboardingTheme.goldColor
                                      .withValues(alpha: 0.15)
                                  : OnboardingTheme.cardBackground,
                              borderRadius: BorderRadius.circular(
                                  OnboardingTheme.radiusMedium),
                              border: Border.all(
                                color: selected
                                    ? OnboardingTheme.goldColor
                                    : OnboardingTheme.cardBorder,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    rule,
                                    style: OnboardingTheme.callout.copyWith(
                                      color: selected
                                          ? OnboardingTheme.goldColor
                                          : OnboardingTheme.labelPrimary,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(Icons.check_circle,
                                      color: OnboardingTheme.goldColor,
                                      size: 22),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
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

class _AppEntry {
  final String label;
  final String icon;
  const _AppEntry(this.label, this.icon);
}

class _AppTile extends StatelessWidget {
  final _AppEntry entry;
  final bool selected;
  final VoidCallback onTap;

  const _AppTile({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected
              ? OnboardingTheme.goldColor.withValues(alpha: 0.18)
              : OnboardingTheme.cardBackground,
          borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
          border: Border.all(
            color:
                selected ? OnboardingTheme.goldColor : OnboardingTheme.cardBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(entry.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              entry.label,
              style: OnboardingTheme.caption.copyWith(
                color: selected
                    ? OnboardingTheme.goldColor
                    : OnboardingTheme.labelPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
