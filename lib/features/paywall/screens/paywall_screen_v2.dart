import 'dart:async';

import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/paywall/controllers/paywall_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PaywallScreenV2 extends StatefulWidget {
  final String? placementId;
  final bool redirectToHomeOnClose;

  const PaywallScreenV2({
    super.key,
    this.placementId,
    this.redirectToHomeOnClose = false,
  });

  @override
  State<PaywallScreenV2> createState() => _PaywallScreenV2State();
}

class _PaywallScreenV2State extends State<PaywallScreenV2>
    with TickerProviderStateMixin {
  late PaywallController controller;

  bool _showClose = false;
  bool _animateIn = false;
  bool _showPlans = false;
  int _currentTestimonial = 0;
  Timer? _testimonialTimer;

  final List<Map<String, dynamic>> _testimonials = [
    {
      'text': 'I actually have time for morning prayer now. Game changer.',
      'name': 'Sarah',
      'location': 'TX',
      'stars': 5,
    },
    {
      'text': 'My screen time went from 5h to under 2h. Worth every penny.',
      'name': 'David',
      'location': 'GA',
      'stars': 5,
    },
    {
      'text': 'Finally an app that helps me stay focused on what matters.',
      'name': 'Grace',
      'location': 'CA',
      'stars': 5,
    },
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.put(PaywallController(
      placementId: widget.placementId,
      redirectToHomeOnClose: widget.redirectToHomeOnClose,
    ));

    // Animate in after 100ms
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _animateIn = true);
    });

    // Show close button and plans after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showClose = true;
          _showPlans = true;
        });
      }
    });

    // Start testimonial carousel
    _testimonialTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _currentTestimonial = (_currentTestimonial + 1) % _testimonials.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _testimonialTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      OnboardingTheme.goldColor.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Close button
          if (_showClose)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: GestureDetector(
                onTap: controller.closePaywall,
                child: AnimatedOpacity(
                  opacity: _showClose ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Color(0x4DFFFFFF),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Main scrollable content
          SafeArea(
            bottom: false,
            child: AnimatedOpacity(
              opacity: _animateIn ? 1 : 0,
              duration: const Duration(milliseconds: 800),
              child: AnimatedSlide(
                offset: _animateIn ? Offset.zero : const Offset(0, 0.05),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 160 + bottomPadding),
                  child: Column(
                    children: [
                      // Headline
                      _buildHeadline(),
                      const SizedBox(height: 22),

                      // Social proof counter
                      _buildSocialProof(),
                      const SizedBox(height: 18),

                      // Benefits
                      _buildBenefits(),
                      const SizedBox(height: 20),

                      // Testimonial carousel
                      _buildTestimonialCarousel(),
                      const SizedBox(height: 22),

                      // Footer links
                      _buildFooterLinks(),

                      // Space for floating plans
                      const SizedBox(height: 180),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Fixed bottom section: Plans + CTA button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: _showPlans ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: AnimatedSlide(
                offset: _showPlans ? Offset.zero : const Offset(0, 0.3),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                child: Container(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0A0A0A).withOpacity(0),
                        const Color(0xFF0A0A0A).withOpacity(0.95),
                        const Color(0xFF0A0A0A),
                      ],
                      stops: const [0, 0.15, 0.4],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Plans as floating buttons
                      Obx(() => _buildPlans()),
                      const SizedBox(height: 12),
                      // Price anchor - show for yearly
                      Obx(() => _buildPriceAnchor()),
                      // CTA Button
                      _buildCTAButton(),
                      const SizedBox(height: 8),
                      // Reassurance - only show for free trial
                      Obx(() => controller.hasFreeTrial
                          ? _buildReassurance()
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'faithlock',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w300,
            color: OnboardingTheme.goldColor,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                OnboardingTheme.goldColor,
                const Color(0xFFD4B96E),
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'PRO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A0A0A),
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.3,
              letterSpacing: -0.5,
              fontFamily: 'Georgia',
            ),
            children: [
              TextSpan(text: 'paywall_headline1'.tr),
              TextSpan(
                text: 'paywall_headline2'.tr,
                style: TextStyle(color: OnboardingTheme.goldColor),
              ),
              TextSpan(text: 'paywall_headline3'.tr),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'paywall_subheadline'.tr,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w300,
            color: Colors.white.withOpacity(0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSocialProof() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: OnboardingTheme.goldColor.withOpacity(0.08),
        border: Border.all(
          color: OnboardingTheme.goldColor.withOpacity(0.15),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Text(
            'paywall_socialProof'.trParams({'count': '1,000+'}),
            style: TextStyle(
              color: OnboardingTheme.goldColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    final benefits = [
      {'icon': '🚫', 'text': 'paywall_benefit1'.tr},
      {'icon': '📖', 'text': 'paywall_benefit2'.tr},
      {'icon': '⏱️', 'text': 'paywall_benefit3'.tr},
      {'icon': '📊', 'text': 'paywall_benefit4'.tr},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: Column(
        children: benefits.asMap().entries.map((entry) {
          final i = entry.key;
          final b = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: i < benefits.length - 1 ? 12 : 0),
            child: AnimatedOpacity(
              opacity: _animateIn ? 1 : 0,
              duration: Duration(milliseconds: 600 + i * 100),
              child: AnimatedSlide(
                offset: _animateIn ? Offset.zero : const Offset(-0.05, 0),
                duration: Duration(milliseconds: 600 + i * 100),
                curve: Curves.easeOutCubic,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b['icon'] as String,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        b['text'] as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13.5,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTestimonialCarousel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: OnboardingTheme.goldColor.withOpacity(0.06),
        border: Border.all(
          color: OnboardingTheme.goldColor.withOpacity(0.12),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Testimonial content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey(_currentTestimonial),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stars
                Row(
                  children: List.generate(
                    _testimonials[_currentTestimonial]['stars'] as int,
                    (_) => Text(
                      '★',
                      style: TextStyle(
                        color: OnboardingTheme.goldColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Quote
                Text(
                  '"${_testimonials[_currentTestimonial]['text']}"',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    fontFamily: 'Georgia',
                  ),
                ),
                const SizedBox(height: 8),
                // Author
                Text(
                  '— ${_testimonials[_currentTestimonial]['name']}, ${_testimonials[_currentTestimonial]['location']}',
                  style: TextStyle(
                    color: OnboardingTheme.goldColor.withOpacity(0.7),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _testimonials.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: i == _currentTestimonial ? 16 : 5,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i == _currentTestimonial
                      ? OnboardingTheme.goldColor
                      : Colors.white.withOpacity(0.15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlans() {
    if (controller.packages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: controller.packages.asMap().entries.map((entry) {
        final index = entry.key;
        final package = entry.value;
        final isSelected = controller.selectedPlanIndex.value == index;
        final isYearly = package.packageType.name.toLowerCase().contains('annual');
        final isMonthly = package.packageType.name.toLowerCase().contains('month');
        final savingsText = controller.getSavingsText(package);

        // Calculate daily price
        final price = package.storeProduct.price;
        final currencySymbol = package.storeProduct.currencyCode == 'EUR' ? '€' : '\$';
        double dailyPrice;
        if (isYearly) {
          dailyPrice = price / 365;
        } else if (isMonthly) {
          dailyPrice = price / 30;
        } else {
          // Weekly
          dailyPrice = price / 7;
        }
        final dailyPriceText = '$currencySymbol${dailyPrice.toStringAsFixed(2)}/${'paywall_day'.tr}';

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < controller.packages.length - 1 ? 8 : 0,
            top: isYearly ? 12 : 0,
          ),
          child: GestureDetector(
            onTap: () => controller.selectPlan(index),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              OnboardingTheme.goldColor.withOpacity(0.12),
                              OnboardingTheme.goldColor.withOpacity(0.06),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.02),
                    border: Border.all(
                      color: isSelected
                          ? OnboardingTheme.goldColor.withOpacity(0.5)
                          : Colors.white.withOpacity(0.08),
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Radio
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? OnboardingTheme.goldColor
                                : Colors.white.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: OnboardingTheme.goldColor,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      // Plan info (title + price)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.getPlanTitle(package),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              controller.getPriceText(package),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right side: Savings + Daily price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (savingsText.isNotEmpty) ...[
                            Text(
                              savingsText,
                              style: TextStyle(
                                color: OnboardingTheme.goldColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            dailyPriceText,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Best value tag
                if (isYearly)
                  Positioned(
                    top: -10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              OnboardingTheme.goldColor,
                              const Color(0xFFD4B96E),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'paywall_bestValue'.tr,
                          style: const TextStyle(
                            color: Color(0xFF0A0A0A),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCTAButton() {
    return Obx(() {
      final hasFreeTrial = controller.hasFreeTrial;
      final buttonText = hasFreeTrial
          ? 'paywall_ctaFreeTrial'.tr
          : 'paywall_ctaNoTrial'.tr;

      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isPurchasing.value
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  controller.startSubscription();
                },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return OnboardingTheme.goldColor.withOpacity(0.6);
              }
              return null;
            }),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  OnboardingTheme.goldColor,
                  const Color(0xFFD4B96E),
                  OnboardingTheme.goldColor,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Container(
              alignment: Alignment.center,
              child: controller.isPurchasing.value
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF0A0A0A)),
                      ),
                    )
                  : Text(
                      buttonText,
                      style: const TextStyle(
                        color: Color(0xFF0A0A0A),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPriceAnchor() {
    // Only show for yearly plan with free trial
    if (controller.packages.isEmpty) return const SizedBox.shrink();

    final selectedIndex = controller.selectedPlanIndex.value;
    if (selectedIndex >= controller.packages.length) return const SizedBox.shrink();

    final package = controller.packages[selectedIndex];
    final isYearly = package.packageType.name.toLowerCase().contains('annual');

    if (!isYearly) return const SizedBox.shrink();

    // Calculate daily price
    final price = package.storeProduct.price;
    final currencySymbol = package.storeProduct.currencyCode == 'EUR' ? '€' : '\$';
    final dailyPrice = price / 365;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        'paywall_priceAnchorPrefix'.tr + '$currencySymbol${dailyPrice.toStringAsFixed(2)}/${'paywall_day'.tr} — ${'paywall_priceAnchorSuffix'.tr} 🙏',
        style: TextStyle(
          color: OnboardingTheme.goldColor.withOpacity(0.8),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildReassurance() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'paywall_reassurance'.tr,
        style: TextStyle(
          color: Colors.white.withOpacity(0.35),
          fontSize: 11.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFooterLink('paywall_restore'.tr, controller.restorePurchases),
          const SizedBox(width: 24),
          _buildFooterLink('paywall_privacy'.tr, controller.openPrivacyPolicy),
          const SizedBox(width: 24),
          _buildFooterLink('paywall_terms'.tr, controller.openTermsOfService),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.2),
          fontSize: 11,
        ),
      ),
    );
  }
}
