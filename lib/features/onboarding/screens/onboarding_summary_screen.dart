import 'dart:math' as math;

import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/paywall/screens/paywall_screen.dart';
import 'package:faithlock/services/analytics/posthog/config/event_templates.dart';
import 'package:faithlock/services/analytics/posthog/posthog_service.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Onboarding Summary Screen - Shows setup completion and navigates to paywall
class OnboardingSummaryScreen extends StatefulWidget {
  const OnboardingSummaryScreen({super.key});

  @override
  State<OnboardingSummaryScreen> createState() =>
      _OnboardingSummaryScreenState();
}

class _OnboardingSummaryScreenState extends State<OnboardingSummaryScreen>
    with TickerProviderStateMixin {
  final controller = Get.find<ScriptureOnboardingController>();
  final PostHogService _analytics = PostHogService.instance;

  bool _showLoading = true;
  bool _showSummary = false;
  final List<bool> _visibleItems = [false, false, false, false];
  bool _showGraph = false;
  bool _showButton = false;

  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _loadingAnimation = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    );

    _startAnimation();
    _trackSummaryView();
  }

  Future<void> _trackSummaryView() async {
    if (_analytics.isReady) {
      await _analytics.events.track(
        PostHogEventType.screenView,
        {
          'screen_name': 'onboarding_summary',
          'screen_class': 'OnboardingSummaryScreen',
          'initial_hours': controller.hoursPerDay.value,
          'projected_hours': controller.hoursPerDay.value * 0.3,
          'time_to_reclaim': controller.hoursPerDay.value * 0.7,
        },
      );
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 1: Loading (2 seconds)
    await Future.delayed(const Duration(milliseconds: 2000));

    // Phase 2: Show summary
    setState(() {
      _showLoading = false;
      _showSummary = true;
    });

    await AnimationUtils.mediumHaptic();

    // Animate items one by one
    for (int i = 0; i < _visibleItems.length; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _visibleItems[i] = true);
      await AnimationUtils.lightHaptic();
    }

    // Wait a bit
    await Future.delayed(const Duration(milliseconds: 800));

    // Show graph
    setState(() => _showGraph = true);
    await AnimationUtils.mediumHaptic();

    // Wait a bit to let user see the graph
    await Future.delayed(const Duration(milliseconds: 1200));

    // Show button
    setState(() => _showButton = true);
    await AnimationUtils.mediumHaptic();
  }

  Future<void> _onStartJourney() async {
    await AnimationUtils.heavyHaptic();

    if (_analytics.isReady) {
      await _analytics.events.track(
        PostHogEventType.navigationAction,
        {
          'action': 'summary_cta_clicked',
          'button_text': 'Unlock Your Full Potential',
          'destination': 'paywall',
          'initial_hours': controller.hoursPerDay.value,
          'time_to_reclaim': controller.hoursPerDay.value * 0.7,
        },
      );
    }

    await controller.completeSummary();

    Get.to(() => PaywallScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scrollable content
          Positioned.fill(
            bottom: _showButton ? 120 : 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: OnboardingTheme.horizontalPadding,
                right: OnboardingTheme.horizontalPadding,
                top: 60,
                bottom: OnboardingTheme.verticalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Loading phase
                  if (_showLoading) ...[
                    // Spinning shield icon
                    AnimatedBuilder(
                      animation: _loadingAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _loadingAnimation.value * 2 * 3.14159,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  OnboardingTheme.goldColor
                                      .withValues(alpha: 0.3),
                                  OnboardingTheme.goldColor
                                      .withValues(alpha: 0.1),
                                ],
                              ),
                              border: Border.all(
                                color: OnboardingTheme.goldColor,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.shield,
                              size: 50,
                              color: OnboardingTheme.goldColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: OnboardingTheme.space32),
                    Text(
                      'Activating your spiritual shield...',
                      style: OnboardingTheme.callout.copyWith(
                        color: OnboardingTheme.goldColor,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  // Summary phase
                  if (_showSummary) ...[
                    // Success icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OnboardingTheme.goldColor.withValues(alpha: 0.2),
                        border: Border.all(
                          color: OnboardingTheme.goldColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 60,
                        color: OnboardingTheme.goldColor,
                      ),
                    ),

                    const SizedBox(height: OnboardingTheme.space32),

                    Text(
                      'Your Spiritual Armor is Ready',
                      style: OnboardingTheme.title2,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: OnboardingTheme.space32),

                    // Configured items list
                    _buildSummaryItem(
                      index: 0,
                      icon: Icons.menu_book,
                      title: 'Scripture Shield Activated',
                      subtitle: 'Bible verses before every unlock',
                    ),
                    const SizedBox(height: OnboardingTheme.space16),
                    _buildSummaryItem(
                      index: 1,
                      icon: Icons.schedule,
                      title: 'Protection Schedules Set',
                      subtitle: '3 daily lock periods configured',
                    ),
                    const SizedBox(height: OnboardingTheme.space16),
                    _buildSummaryItem(
                      index: 2,
                      icon: Icons.notifications_active,
                      title: 'Prayer Reminders Ready',
                      subtitle: 'Stay accountable with gentle nudges',
                    ),
                    const SizedBox(height: OnboardingTheme.space16),
                    _buildSummaryItem(
                      index: 3,
                      icon: Icons.favorite,
                      title: 'Sacred Covenant Sealed',
                      subtitle: 'Your commitment is recorded',
                    ),

                    const SizedBox(height: OnboardingTheme.space32),

                    // Transformation promises section
                    Container(
                      padding: const EdgeInsets.all(OnboardingTheme.space20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            OnboardingTheme.goldColor.withValues(alpha: 0.1),
                            OnboardingTheme.goldColor.withValues(alpha: 0.02),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(OnboardingTheme.radiusLarge),
                        border: Border.all(
                          color:
                              OnboardingTheme.goldColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Your Transformation Begins',
                            style: OnboardingTheme.callout.copyWith(
                              color: OnboardingTheme.labelPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: OnboardingTheme.space20),
                          _buildPromiseItem(
                              'Reclaim 2-4 hours daily for prayer & family'),
                          const SizedBox(height: OnboardingTheme.space12),
                          _buildPromiseItem(
                              'Reduce screen time by 70% in just 2 weeks'),
                          const SizedBox(height: OnboardingTheme.space12),
                          _buildPromiseItem(
                              'Build a consistent daily prayer practice'),
                          const SizedBox(height: OnboardingTheme.space12),
                          _buildPromiseItem(
                              'Experience true digital freedom & peace'),
                        ],
                      ),
                    ),

                    const SizedBox(height: OnboardingTheme.space40),

                    // Graph section
                    if (_showGraph) ...[
                      AnimatedOpacity(
                        opacity: _showGraph ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 600),
                        child: Column(
                          children: [
                            Text(
                              'Time You\'ll Reclaim',
                              style: OnboardingTheme.callout.copyWith(
                                color: OnboardingTheme.labelPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: OnboardingTheme.space8),
                            Text(
                              'Every hour back for prayer & family',
                              style: OnboardingTheme.subhead,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: OnboardingTheme.space16),
                            _buildProjectionGraph(),
                            const SizedBox(height: OnboardingTheme.space16),
                            Text(
                              'Based on averages from 500+ users',
                              style: OnboardingTheme.caption,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: OnboardingTheme.space32),
                    ],

                    // Testimonial section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: OnboardingTheme.space20,
                        vertical: OnboardingTheme.space16,
                      ),
                      margin: const EdgeInsets.only(
                          bottom: OnboardingTheme.space32),
                      decoration: BoxDecoration(
                        color: OnboardingTheme.cardBackground,
                        borderRadius:
                            BorderRadius.circular(OnboardingTheme.radiusMedium),
                        border: Border.all(
                          color:
                              OnboardingTheme.goldColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => Icon(
                                Icons.star,
                                size: 16,
                                color: OnboardingTheme.goldColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: OnboardingTheme.space12),
                          Text(
                            '"I was enslaved to my phone for years. FaithLock gave me back 3+ hours daily - now spent in prayer, with my kids, and in God\'s Word. My life has completely changed."',
                            style: OnboardingTheme.subhead.copyWith(
                              color: OnboardingTheme.labelPrimary,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: OnboardingTheme.space12),
                          Text(
                            '— Sarah M., FaithLock User',
                            style: OnboardingTheme.caption.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Stats section
                    Container(
                      padding: const EdgeInsets.all(OnboardingTheme.space20),
                      decoration: BoxDecoration(
                        color:
                            OnboardingTheme.systemGreen.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(OnboardingTheme.radiusMedium),
                        border: Border.all(
                          color: OnboardingTheme.systemGreen
                              .withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 32,
                            color: OnboardingTheme.systemGreen,
                          ),
                          const SizedBox(height: OnboardingTheme.space12),
                          Text(
                            'Believers using FaithLock report:',
                            style: OnboardingTheme.footnote.copyWith(
                              color: OnboardingTheme.labelPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: OnboardingTheme.space16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMiniStat('70%', 'Less\nScreen Time'),
                              Container(
                                width: 1,
                                height: 40,
                                color: OnboardingTheme.labelTertiary
                                    .withValues(alpha: 0.3),
                              ),
                              _buildMiniStat('3.5h', 'Saved\nDaily'),
                              Container(
                                width: 1,
                                height: 40,
                                color: OnboardingTheme.labelTertiary
                                    .withValues(alpha: 0.3),
                              ),
                              _buildMiniStat('92%', 'Stronger\nFaith'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),

          // Fixed button at bottom
          if (_showButton)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      OnboardingTheme.backgroundColor.withValues(alpha: 0),
                      OnboardingTheme.backgroundColor,
                      OnboardingTheme.backgroundColor,
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
                padding: const EdgeInsets.only(
                  left: 40,
                  right: 40,
                  top: 30,
                  bottom: 50,
                ),
                child: AnimatedOpacity(
                  opacity: _showButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 16,
                      //     vertical: 8,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color:
                      //         OnboardingTheme.goldColor.withValues(alpha: 0.15),
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(
                      //         Icons.timer,
                      //         size: 14,
                      //         color: OnboardingTheme.goldColor,
                      //       ),
                      //       const SizedBox(width: 6),
                      //       Text(
                      //         'Your setup expires in 24 hours',
                      //         style: OnboardingTheme.caption.copyWith(
                      //           color: OnboardingTheme.goldColor,
                      //           fontWeight: FontWeight.w600,
                      //           fontSize: 11,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 16),
                      FastButton(
                        text: 'Unlock Your Full Potential',
                        onTap: _onStartJourney,
                        backgroundColor: OnboardingTheme.goldColor,
                        textColor: OnboardingTheme.backgroundColor,
                        style: FastButtonStyle.filled,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join believers transforming their lives today',
                        style: OnboardingTheme.caption.copyWith(
                          color: OnboardingTheme.labelSecondary,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProjectionGraph() {
    final initialHours = controller.hoursPerDay.value;
    final targetHours = initialHours * 0.3;
    final timeReclaimed = initialHours - targetHours;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OnboardingTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: OnboardingTheme.goldColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Graph
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: TransformationGraphPainter(
                startValue: 0,
                endValue: timeReclaimed,
                color: OnboardingTheme.goldColor,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'Screen Time\nToday',
                value: '${initialHours.toStringAsFixed(1)}h',
                color: OnboardingTheme.systemRed,
              ),
              Icon(
                Icons.arrow_forward,
                color: OnboardingTheme.goldColor,
                size: 20,
              ),
              _buildStatItem(
                label: 'Screen Time\nWeek 2',
                value: '${targetHours.toStringAsFixed(1)}h',
                color: OnboardingTheme.systemGreen,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  OnboardingTheme.goldColor.withValues(alpha: 0.2),
                  OnboardingTheme.goldColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: OnboardingTheme.goldColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '+${timeReclaimed.toStringAsFixed(1)}h daily for what matters',
                  style: OnboardingTheme.footnote.copyWith(
                    color: OnboardingTheme.goldColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: OnboardingTheme.title3.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: OnboardingTheme.caption.copyWith(
            color: OnboardingTheme.labelSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return AnimatedOpacity(
      opacity: _visibleItems[index] ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: AnimatedSlide(
        offset: _visibleItems[index] ? Offset.zero : const Offset(0, 0.3),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: OnboardingTheme.goldColor.withValues(alpha: 0.15),
                border: Border.all(
                  color: OnboardingTheme.goldColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 24,
                color: OnboardingTheme.goldColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: OnboardingTheme.callout.copyWith(
                      color: OnboardingTheme.labelPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: OnboardingTheme.caption.copyWith(
                      color: OnboardingTheme.labelSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromiseItem(String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: OnboardingTheme.goldColor.withValues(alpha: 0.2),
          ),
          child: Icon(
            Icons.check,
            size: 14,
            color: OnboardingTheme.goldColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: OnboardingTheme.body.copyWith(
              color: OnboardingTheme.labelPrimary,
              fontSize: 15,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: OnboardingTheme.title2.copyWith(
            color: OnboardingTheme.systemGreen,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: OnboardingTheme.caption.copyWith(
            color: OnboardingTheme.labelSecondary,
            fontSize: 11,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Custom painter for transformation graph
class TransformationGraphPainter extends CustomPainter {
  final double startValue;
  final double endValue;
  final Color color;

  TransformationGraphPainter({
    required this.startValue,
    required this.endValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Calculate 14 data points (2 weeks)
    final points = <Offset>[];
    final fillPath = Path();

    for (int i = 0; i <= 14; i++) {
      final x = (i / 14) * size.width;

      // Exponential growth curve
      final progress = i / 14;
      final value =
          startValue + (endValue - startValue) * (1 - math.exp(-3 * progress));

      // Normalize to graph height (growth: low to high)
      final maxValue = endValue > startValue ? endValue : startValue;
      final normalizedValue = value / maxValue;
      final y = (1 - normalizedValue) * (size.height - 40) + 20;

      points.add(Offset(x, y));
    }

    // Draw fill
    if (points.isNotEmpty) {
      fillPath.moveTo(points.first.dx, size.height);
      for (final point in points) {
        fillPath.lineTo(point.dx, point.dy);
      }
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw curve line
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);

      // Smooth curve using quadratic bezier
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlPoint = Offset(
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
        path.quadraticBezierTo(
          controlPoint.dx,
          controlPoint.dy,
          p1.dx,
          p1.dy,
        );
      }

      canvas.drawPath(path, paint);
    }

    // Draw data points (dots)
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = OnboardingTheme.backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw dots at start, middle, and end
    for (int i in [0, 7, 14]) {
      if (i < points.length) {
        canvas.drawCircle(points[i], 5, dotBorderPaint);
        canvas.drawCircle(points[i], 4, dotPaint);
      }
    }

    // Draw grid lines (subtle)
    final gridPaint = Paint()
      ..color = OnboardingTheme.labelTertiary.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(TransformationGraphPainter oldDelegate) {
    return oldDelegate.startValue != startValue ||
        oldDelegate.endValue != endValue ||
        oldDelegate.color != color;
  }
}
