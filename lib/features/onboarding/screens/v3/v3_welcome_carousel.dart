import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:flutter/material.dart';

/// V3 Welcome Carousel - 3 slides, 3 value props.
///
/// Replaces the V2 single welcome screen. Punchy, scannable, fast.
class V3WelcomeCarousel extends StatefulWidget {
  final VoidCallback onComplete;

  const V3WelcomeCarousel({super.key, required this.onComplete});

  @override
  State<V3WelcomeCarousel> createState() => _V3WelcomeCarouselState();
}

class _V3WelcomeCarouselState extends State<V3WelcomeCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = <_CarouselSlide>[
    _CarouselSlide(
      mascotState: JudahState.sad,
      title: 'Your phone is stealing from God.',
      body:
          'The average person spends 7 hours a day on screens. Imagine if even one of those hours became prayer.',
      ctaIsFinal: false,
    ),
    _CarouselSlide(
      mascotState: JudahState.appProtection,
      title: 'Block distractions, keep your peace.',
      body:
          'Lock the apps that pull you away. Redirect every minute back to your faith.',
      ctaIsFinal: false,
    ),
    _CarouselSlide(
      mascotState: JudahState.praying,
      title: 'Turn scroll time into soul time.',
      body:
          'Every hour saved becomes an invitation to pray, serve, and belong.',
      ctaIsFinal: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    await AnimationUtils.lightHaptic();
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else {
      await AnimationUtils.heavyHaptic();
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 80,
          bottom: OnboardingTheme.verticalPadding,
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _slides.length,
                itemBuilder: (context, index) => _SlideView(slide: _slides[index]),
              ),
            ),
            const SizedBox(height: OnboardingTheme.space24),
            _PageIndicator(
              count: _slides.length,
              currentIndex: _currentPage,
            ),
            const SizedBox(height: OnboardingTheme.space32),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: OnboardingTheme.horizontalPadding,
              ),
              child: FastButton(
                text: _slides[_currentPage].ctaIsFinal
                    ? 'I\'m ready'
                    : 'Continue',
                onTap: _next,
                backgroundColor: OnboardingTheme.goldColor,
                textColor: OnboardingTheme.backgroundColor,
                style: FastButtonStyle.filled,
              ),
            ),
            const SizedBox(height: OnboardingTheme.space16),
          ],
        ),
      ),
    );
  }
}

class _CarouselSlide {
  final JudahState mascotState;
  final String title;
  final String body;
  final bool ctaIsFinal;

  const _CarouselSlide({
    required this.mascotState,
    required this.title,
    required this.body,
    required this.ctaIsFinal,
  });
}

class _SlideView extends StatelessWidget {
  final _CarouselSlide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OnboardingTheme.horizontalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          JudahMascot(
            state: slide.mascotState,
            size: JudahSize.xl,
            showMessage: false,
          ),
          const SizedBox(height: OnboardingTheme.space40),
          Text(
            slide.title,
            style: OnboardingTheme.title1.copyWith(
              color: OnboardingTheme.labelPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: OnboardingTheme.space20),
          Text(
            slide.body,
            style: OnboardingTheme.callout.copyWith(
              color: OnboardingTheme.labelSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  const _PageIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: active ? 24 : 6,
          decoration: BoxDecoration(
            color: active
                ? OnboardingTheme.goldColor
                : OnboardingTheme.labelTertiary,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
