import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';

/// V3 Social Proof - Lightweight testimonials before paywall.
class V3SocialProof extends StatefulWidget {
  final VoidCallback onComplete;
  const V3SocialProof({super.key, required this.onComplete});

  @override
  State<V3SocialProof> createState() => _V3SocialProofState();
}

class _V3SocialProofState extends State<V3SocialProof> {
  double _opacity = 1.0;

  static const _testimonials = <_Testimonial>[
    _Testimonial(
      quote:
          "I went from 5 hours of scrolling to 30 minutes of evening prayer. My family noticed first.",
      author: "Marc",
      detail: "Catholic, 34",
    ),
    _Testimonial(
      quote:
          "FaithLock didn't take anything from me. It gave me back the silence I'd been missing.",
      author: "Sarah",
      detail: "Protestant, 28",
    ),
    _Testimonial(
      quote:
          "I rebuilt the Rosary into my day. The lock isn't a punishment — it's a doorway.",
      author: "James",
      detail: "Orthodox, 41",
    ),
  ];

  Future<void> _onContinue() async {
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
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (_) => const Icon(
                            Icons.star_rounded,
                            color: OnboardingTheme.goldColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '4.9 · trusted by believers',
                          style: OnboardingTheme.footnote.copyWith(
                            color: OnboardingTheme.labelSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: OnboardingTheme.space16),
                    Text(
                      'You\'re not alone in this.',
                      style: OnboardingTheme.title2,
                    ),
                    const SizedBox(height: OnboardingTheme.space8),
                    Text(
                      'Real stories from people who reclaimed their time.',
                      style: OnboardingTheme.callout
                          .copyWith(color: OnboardingTheme.labelSecondary),
                    ),
                    const SizedBox(height: OnboardingTheme.space32),
                    ..._testimonials.map((t) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: OnboardingTheme.space16),
                          child: _TestimonialCard(testimonial: t),
                        )),
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
                  onTap: _onContinue,
                  backgroundColor: OnboardingTheme.goldColor,
                  textColor: OnboardingTheme.backgroundColor,
                  style: FastButtonStyle.filled,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Testimonial {
  final String quote;
  final String author;
  final String detail;
  const _Testimonial({
    required this.quote,
    required this.author,
    required this.detail,
  });
}

class _TestimonialCard extends StatelessWidget {
  final _Testimonial testimonial;
  const _TestimonialCard({required this.testimonial});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OnboardingTheme.space20),
      decoration: BoxDecoration(
        color: OnboardingTheme.cardBackground,
        borderRadius: BorderRadius.circular(OnboardingTheme.radiusLarge),
        border: Border.all(color: OnboardingTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${testimonial.quote}"',
            style: OnboardingTheme.body.copyWith(
              fontStyle: FontStyle.italic,
              color: OnboardingTheme.labelPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: OnboardingTheme.space12),
          Text(
            '— ${testimonial.author}, ${testimonial.detail}',
            style: OnboardingTheme.footnote
                .copyWith(color: OnboardingTheme.goldColor),
          ),
        ],
      ),
    );
  }
}
