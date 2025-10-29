import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/features/paywall/screens/paywall_screen.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/notifications/fast_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionExpiredScreen extends StatefulWidget {
  final bool wasTrialUser;
  final DateTime? expirationDate;

  const SubscriptionExpiredScreen({
    super.key,
    this.wasTrialUser = false,
    this.expirationDate,
  });

  @override
  State<SubscriptionExpiredScreen> createState() =>
      _SubscriptionExpiredScreenState();
}

class _SubscriptionExpiredScreenState extends State<SubscriptionExpiredScreen>
    with SingleTickerProviderStateMixin {
  bool _showContent = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _showContent = true);
    await AnimationUtils.mediumHaptic();
  }

  String _getTitle() {
    if (widget.wasTrialUser) {
      return 'Your Free Trial Has Ended';
    }
    return 'Your Subscription Has Expired';
  }

  String _getMessage() {
    if (widget.wasTrialUser) {
      return 'We hope you enjoyed your trial period and experienced the power of FaithLock.\n\nYour spiritual journey doesn\'t have to end here.';
    }
    return 'Your subscription has expired, but your spiritual growth journey can continue.\n\nRenew now to keep building stronger faith habits.';
  }

  void _onRenewNow() async {
    await AnimationUtils.heavyHaptic();

    Get.off(() => PaywallScreen(
          placementId: 'subscription_expired',
          redirectToHomeOnClose: false,
        ));
  }

  Future<void> _onContactSupport() async {
    await AnimationUtils.lightHaptic();

    const String email = 'support@faithlock.app';
    const String subject = 'FaithLock Subscription Support';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': widget.wasTrialUser
            ? 'I have questions about continuing after my trial period.\n\n'
            : 'I have questions about renewing my subscription.\n\n',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        FastToast.error(
          'Could not open email client. Please email us at $email',
          title: 'Error',
        );
      }
    } catch (e) {
      FastToast.error(
        'Could not open email client. Please email us at $email',
        title: 'Error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: AnimatedOpacity(
        opacity: _showContent ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 800),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: OnboardingTheme.horizontalPadding,
              vertical: OnboardingTheme.verticalPadding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              OnboardingTheme.goldColor.withValues(alpha: 0.3),
                              OnboardingTheme.goldColor.withValues(alpha: 0.1),
                            ],
                          ),
                          border: Border.all(
                            color: OnboardingTheme.goldColor,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.schedule,
                          size: 60,
                          color: OnboardingTheme.goldColor,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: OnboardingTheme.space40),

                // Title
                Text(
                  _getTitle(),
                  style: OnboardingTheme.title2.copyWith(
                    color: OnboardingTheme.labelPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: OnboardingTheme.space24),

                // Message
                Text(
                  _getMessage(),
                  style: OnboardingTheme.body.copyWith(
                    color: OnboardingTheme.labelSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: OnboardingTheme.space40),

                // What you'll get back section
                Container(
                  padding: const EdgeInsets.all(OnboardingTheme.space24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        OnboardingTheme.goldColor.withValues(alpha: 0.1),
                        OnboardingTheme.goldColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(OnboardingTheme.radiusLarge),
                    border: Border.all(
                      color: OnboardingTheme.goldColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Continue Your Journey',
                        style: OnboardingTheme.callout.copyWith(
                          color: OnboardingTheme.labelPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: OnboardingTheme.space20),
                      _buildBenefit(
                        icon: Icons.shield,
                        text: 'App blocking with Scripture meditation',
                      ),
                      const SizedBox(height: OnboardingTheme.space16),
                      _buildBenefit(
                        icon: Icons.schedule,
                        text: 'Unlimited custom schedules',
                      ),
                      const SizedBox(height: OnboardingTheme.space16),
                      _buildBenefit(
                        icon: Icons.church,
                        text: 'Prayer reminders & accountability',
                      ),
                      const SizedBox(height: OnboardingTheme.space16),
                      _buildBenefit(
                        icon: Icons.trending_up,
                        text: 'Advanced stats & progress tracking',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: OnboardingTheme.space40),

                // Stats reminder
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OnboardingTheme.space16,
                    vertical: OnboardingTheme.space12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        OnboardingTheme.systemGreen.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(OnboardingTheme.radiusMedium),
                    border: Border.all(
                      color: OnboardingTheme.systemGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 20,
                        color: OnboardingTheme.systemGreen,
                      ),
                      const SizedBox(width: OnboardingTheme.space8),
                      Flexible(
                        child: Text(
                          '92% of users report stronger faith',
                          style: OnboardingTheme.footnote.copyWith(
                            color: OnboardingTheme.systemGreen,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: OnboardingTheme.space40),

                // Renew button
                FastButton(
                  text: 'Renew Subscription',
                  onTap: _onRenewNow,
                  backgroundColor: OnboardingTheme.goldColor,
                  textColor: OnboardingTheme.backgroundColor,
                  style: FastButtonStyle.filled,
                ),

                const SizedBox(height: OnboardingTheme.space16),

                // Optional: Contact support
                TextButton(
                  onPressed: _onContactSupport,
                  child: Text(
                    'Need help? Contact Support',
                    style: OnboardingTheme.footnote.copyWith(
                      color: OnboardingTheme.labelTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: OnboardingTheme.goldColor.withValues(alpha: 0.2),
          ),
          child: Icon(
            icon,
            size: 20,
            color: OnboardingTheme.goldColor,
          ),
        ),
        const SizedBox(width: OnboardingTheme.space12),
        Expanded(
          child: Text(
            text,
            style: OnboardingTheme.body.copyWith(
              color: OnboardingTheme.labelPrimary,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
