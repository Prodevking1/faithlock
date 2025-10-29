import 'package:faithlock/app_routes.dart';
import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:faithlock/core/constants/core/fast_spacing.dart';
import 'package:faithlock/features/faithlock/controllers/stats_controller.dart';
import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/typography/export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Modern Spiritual Dashboard Screen
/// Displays user statistics with a spiritual, motivating design
class StatsDashboardScreen extends StatefulWidget {
  const StatsDashboardScreen({super.key});

  @override
  State<StatsDashboardScreen> createState() => _StatsDashboardScreenState();
}

class _StatsDashboardScreenState extends State<StatsDashboardScreen>
    with WidgetsBindingObserver {
  late final StatsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(StatsController());
    WidgetsBinding.instance.addObserver(this);

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.loadStats();
      await controller.loadLockedAppsCount();

      // Prompt to select apps if none selected
      _checkAndPromptAppSelection();
    });
  }

  /// Check if no apps are selected and prompt user
  Future<void> _checkAndPromptAppSelection() async {
    // Wait a bit for UI to settle
    await Future.delayed(const Duration(milliseconds: 500));

    if (controller.lockedAppsCount.value == 0) {
      final shouldSelect = await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('🔒 No Apps Locked'),
          content: const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'You haven\'t selected any apps to lock yet. Would you like to choose some apps now?',
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Later'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(true),
              isDefaultAction: true,
              child: const Text('Select Apps'),
            ),
          ],
        ),
      ) ?? false;

      if (shouldSelect) {
        await controller.openAppPicker();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh stats when app resumes (user returns from background)
    if (state == AppLifecycleState.resumed) {
      controller.loadStats();
      controller.loadLockedAppsCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Obx(() {
            // Loading state
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: FastColors.primary,
                ),
              );
            }

            // Error state
            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: FastColors.error,
                    ),
                    FastSpacing.h16,
                    Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        color: FastColors.secondaryText(context),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    FastSpacing.h24,
                    FastButton(
                      text: 'Retry',
                      onTap: controller.loadStats,
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personalized Greeting
                  _buildGreetingHeader(context, controller),
                  FastSpacing.h24,

                  // SECTION 1: Hero Streak Card (greeting + 7-day calendar)
                  _buildHeroStreakCard(context, controller),
                  FastSpacing.h24,

                  // SECTION 2: Quick Stats Grid (2x2)
                  _buildQuickStatsGrid(context, controller),
                  FastSpacing.h32,
                  FastSpacing.h4,

                  // SECTION 3: CTA Button
                  _buildCompactCTAButton(context),
                  FastSpacing.h24,
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Personalized Greeting Header
  Widget _buildGreetingHeader(
      BuildContext context, StatsController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            controller.getGreetingEmoji(),
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.getVariedGreeting(),
              style: TextStyle(
                fontFamily: OnboardingTheme.fontFamily,
                color: FastColors.primaryText(context),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// SECTION 1: Hero Streak Card (emotional & motivational design)
  Widget _buildHeroStreakCard(
      BuildContext context, StatsController controller) {
    final streak = controller.userStats.value?.currentStreak ?? 0;
    final longestStreak = controller.userStats.value?.longestStreak ?? 0;
    final progress = controller.getProgressToNextMilestone();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FastColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FastColors.border(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header: Motivational Message with Longest Streak Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Motivational Message
              Expanded(
                child: Text(
                  controller.getMotivationalMessage(),
                  style: TextStyle(
                    fontFamily: OnboardingTheme.fontFamily,
                    color: FastColors.primaryText(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              if (longestStreak > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🏆',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$longestStreak',
                        style: TextStyle(
                          fontFamily: OnboardingTheme.fontFamily,
                          color: const Color(0xFFDAA520),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Week Days Calendar with glow effect
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .asMap()
                .entries
                .map((entry) {
              final dayIndex = entry.key;
              final dayLabel = entry.value;
              final isCompleted = dayIndex < streak.clamp(0, 7);

              return Column(
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      fontFamily: OnboardingTheme.fontFamily,
                      color: FastColors.secondaryText(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? OnboardingTheme.goldColor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? FastColors.streakOrange
                            : FastColors.separator(context),
                        width: 2,
                      ),
                      boxShadow: isCompleted
                          ? [
                              BoxShadow(
                                color: FastColors.streakOrange
                                    .withValues(alpha: 0.25),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        isCompleted ? '✓' : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Progress Bar to next milestone
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      controller.getNextMilestoneText(),
                      style: TextStyle(
                        fontFamily: OnboardingTheme.fontFamily,
                        color: FastColors.secondaryText(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontFamily: OnboardingTheme.fontFamily,
                      color: FastColors.streakOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor:
                      FastColors.separator(context).withValues(alpha: 0.3),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(FastColors.streakOrange),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 16),

          // Inspirational Quote (spiritual element)
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          //   decoration: BoxDecoration(
          //     color: FastColors.surface(context),
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(
          //       color: FastColors.separator(context),
          //       width: 1,
          //     ),
          //   ),
          //   child: Text(
          //     controller.getInspirationalVerseQuote(),
          //     style: TextStyle(
          //       fontFamily: OnboardingTheme.fontFamily,
          //       color: FastColors.secondaryText(context),
          //       fontSize: 13,
          //       fontStyle: FontStyle.italic,
          //       height: 1.4,
          //     ),
          //     textAlign: TextAlign.center,
          //   ),
          // ),
        ],
      ),
    );
  }

  /// SECTION 2: Impact Stats - Priority order
  Widget _buildQuickStatsGrid(
    BuildContext context,
    StatsController controller,
  ) {
    return Column(
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: _buildSavedTimeSection(
                context,
                value:
                    '${controller.userStats.value?.screenTimeReducedFormatted ?? 0}',
              ),
            ),
            Expanded(
                child: Column(
              spacing: 12,
              children: [
                _buildCompactStatRow(
                  context,
                  icon: '📖',
                  value: '${controller.userStats.value?.totalVersesRead ?? 0}',
                  label: 'Verses Read',
                ),
                _buildLockedAppsRow(
                  context,
                  controller: controller,
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildSavedTimeSection(
    BuildContext context, {
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: FastColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FastColors.streakOrange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🏆',
            style: TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: OnboardingTheme.fontFamily,
              color: FastColors.primaryText(context),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Time Saved',
            style: TextStyle(
              fontFamily: OnboardingTheme.fontFamily,
              color: FastColors.secondaryText(context),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Compact Stat Row - For secondary metrics
  Widget _buildCompactStatRow(
    BuildContext context, {
    required String icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: FastColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FastColors.border(context),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: OnboardingTheme.fontFamily,
                    color: FastColors.primaryText(context),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: OnboardingTheme.fontFamily,
                    color: FastColors.primaryText(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Locked Apps Row - Clickable with arrow to open app picker
  Widget _buildLockedAppsRow(
    BuildContext context, {
    required StatsController controller,
  }) {
    return Obx(
      () => GestureDetector(
        onTap: () async {
          await controller.openAppPicker();
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: FastColors.surfaceVariant(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FastColors.border(context),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    '🔒',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.lockedAppsCount.value}',
                          style: TextStyle(
                            fontFamily: OnboardingTheme.fontFamily,
                            color: FastColors.primaryText(context),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Apps Locked',
                          style: TextStyle(
                            fontFamily: OnboardingTheme.fontFamily,
                            color: FastColors.primaryText(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FastSpacing.h4,
            FastText.caption2('Tap to manage apps')
          ],
        ),
      ),
    );
  }

  /// SECTION 3: Egg-shaped CTA Button with gold design
  Widget _buildCompactCTAButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        // Navigate to prayer and refresh stats when returning
        await Get.toNamed(AppRoutes.prayerLearning);
        // Refresh stats after prayer session
        controller.loadStats();
        controller.loadLockedAppsCount();
      },
      child: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.95, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutBack,
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 350,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFD700),
                      Color(0xFFDAA520),
                      Color(0xFFB8860B),
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 25,
                      spreadRadius: 2,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                      blurRadius: 15,
                      spreadRadius: -5,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🙏',
                      style: TextStyle(fontSize: 32),
                    ),
                    FastText.footnote(
                      'Start\nPraying',
                      textAlign: TextAlign.center,
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 8,
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
