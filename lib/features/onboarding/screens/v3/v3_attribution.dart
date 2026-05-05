import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v3_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V3 Attribution - extends V2 sources with faith-specific channels.
/// Adds "Parish or pastor" and "Podcast or Catholic media" — high-value
/// signals for organic acquisition through the Christian community.
class V3Attribution extends StatefulWidget {
  final VoidCallback onComplete;
  const V3Attribution({super.key, required this.onComplete});

  @override
  State<V3Attribution> createState() => _V3AttributionState();
}

class _V3AttributionState extends State<V3Attribution> {
  final controller = Get.find<ScriptureOnboardingV3Controller>();
  String? _selected;
  double _opacity = 1.0;

  static const _sources = [
    _Source('parish_pastor', 'My parish or pastor', '⛪'),
    _Source('podcast_media', 'A podcast or Catholic media', '🎙️'),
    _Source('friends_family', 'Friends or family', '👥'),
    _Source('appstore', 'App Store', '📱'),
    _Source('google', 'Google search', '🔍'),
    _Source('tiktok', 'TikTok', '🎵'),
    _Source('instagram', 'Instagram', '📸'),
    _Source('ai', 'AI (ChatGPT, Gemini…)', '🤖'),
    _Source('other', 'Other', '💬'),
  ];

  Future<void> _onContinue() async {
    if (_selected == null) return;

    await controller.saveAttribution(_selected!);
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
                      'How did you hear about FaithLock?',
                      style: OnboardingTheme.title2,
                    ),
                    const SizedBox(height: OnboardingTheme.space32),
                    ..._sources.asMap().entries.map((entry) {
                      final index = entry.key;
                      final src = entry.value;
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 350 + (index * 60)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) => Transform.translate(
                          offset: Offset(0, 16 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SourceCard(
                            source: src,
                            isSelected: _selected == src.id,
                            onTap: () {
                              AnimationUtils.lightHaptic();
                              setState(() => _selected = src.id);
                            },
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
                  onTap: _selected != null ? _onContinue : null,
                  backgroundColor: OnboardingTheme.goldColor,
                  textColor: OnboardingTheme.backgroundColor,
                  style: FastButtonStyle.filled,
                  isDisabled: _selected == null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Source {
  final String id;
  final String label;
  final String icon;
  const _Source(this.id, this.label, this.icon);
}

class _SourceCard extends StatelessWidget {
  final _Source source;
  final bool isSelected;
  final VoidCallback onTap;

  const _SourceCard({
    required this.source,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            Text(source.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                source.label,
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
