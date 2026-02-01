import 'package:faithlock/app_routes.dart';
import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:faithlock/core/constants/core/fast_spacing.dart';
import 'package:faithlock/features/faithlock/controllers/stats_controller.dart';
import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Compact Dashboard Screen - Single View (No Scroll)
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.loadStats();
      await controller.loadLockedAppsCount();
      _checkAndPromptAppSelection();
    });
  }

  Future<void> _checkAndPromptAppSelection() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (controller.lockedAppsCount.value == 0) {
      final name = controller.userName.value.isNotEmpty
          ? controller.userName.value
          : 'Friend';

      final shouldSelect = await showCupertinoDialog<bool>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Column(
                children: [
                  JudahMascot(
                    state: JudahState.pointing,
                    size: JudahSize.l,
                    showMessage: false,
                  ),
                  const SizedBox(height: 8),
                  const Text('No Apps Locked'),
                ],
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Pick the apps to block, $name.',
                  style: const TextStyle(fontSize: 14),
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
          ) ??
          false;

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
    if (state == AppLifecycleState.resumed) {
      controller.loadStats();
      controller.loadLockedAppsCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: OnboardingTheme.goldColor,
              ),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: FastColors.error),
                  FastSpacing.h16,
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildStreakCard(context),
                const SizedBox(height: 16),
                _buildStatsGrid(context),
                const SizedBox(height: 20),
                _buildReadingSection(context),
                const SizedBox(height: 20),
                _buildStartSessionButton(context),
                const SizedBox(height: 16),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Determine Judah's state and message based on context
  JudahState _getJudahState() {
    final streak = controller.userStats.value?.currentStreak ?? 0;
    final previousStreak = controller.userStats.value?.longestStreak ?? 0;

    // Streak lost: had streak before but now 0
    if (streak == 0 && previousStreak > 0) {
      return JudahState.sad;
    }

    // Streak 7+ days: proud
    if (streak >= 7) {
      return JudahState.proud;
    }

    // Evening: praying
    final hour = DateTime.now().hour;
    if (hour >= 20) {
      return JudahState.praying;
    }

    // Default: neutral
    return JudahState.neutral;
  }

  String _getJudahMessage() {
    final name = controller.userName.value.isNotEmpty
        ? controller.userName.value
        : 'Friend';
    final streak = controller.userStats.value?.currentStreak ?? 0;
    final previousStreak = controller.userStats.value?.longestStreak ?? 0;
    final hour = DateTime.now().hour;

    if (streak == 0 && previousStreak > 0) {
      return 'New day, $name.';
    }
    if (streak >= 7) {
      return '$streak days. Respect.';
    }
    if (hour < 12) {
      return 'Morning, $name.';
    }
    if (hour < 18) {
      return 'Keep going, $name.';
    }
    if (hour < 20) {
      return 'Almost there, $name.';
    }
    return 'Peaceful evening, $name.';
  }

  /// Compact header with Judah mascot (60px)
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Judah mascot replaces the initials avatar
        JudahMascot(
          state: _getJudahState(),
          size: JudahSize.m,
          showMessage: false,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _getJudahMessage(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  /// Ultra Compact Streak Card
  Widget _buildStreakCard(BuildContext context) {
    final streak = controller.userStats.value?.currentStreak ?? 0;
    final longestStreak = controller.userStats.value?.longestStreak ?? 0;
    final progress = controller.getProgressToNextMilestone();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Streak number + longest streak in one row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Streak number
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '🔥',
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streak',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: OnboardingTheme.goldColor,
                          height: 1.0,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        'DAYS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[500],
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Longest streak badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      'Longest: $longestStreak',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: OnboardingTheme.goldColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Week days - compact
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? OnboardingTheme.goldColor
                          : Colors.grey[400],
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? OnboardingTheme.goldColor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? OnboardingTheme.goldColor
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 13,
                          )
                        : null,
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 6),

          // Progress bar
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(OnboardingTheme.goldColor),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(progress * 100).toInt()}% to next goal',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Stats grid with proper spacing
  Widget _buildStatsGrid(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Large time card
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.only(
                  top: 18, left: 16, right: 16, bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: OnboardingTheme.goldColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: FittedBox(
                // <--- Scales content to fit the container
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text('⏱️', style: TextStyle(fontSize: 32)),
                    Text(
                      controller.userStats.value?.screenTimeReducedFormatted ??
                          '0h 0m',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1, // Prevent wrapping
                    ),
                    Text(
                      'TIME SAVED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Small cards column
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Verses read
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📖', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // 1. Tell the column to take up minimum space
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 2. Removed Spacer() - it was causing the "Infinite Height" error
                                Text(
                                  '${controller.userStats.value?.totalVersesRead ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'VERSES READ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[500],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Apps blocked
                Expanded(
                  child: Obx(() => GestureDetector(
                        onTap: () => controller.openAppPicker(),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🔒', style: TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${controller.lockedAppsCount.value}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'APPS BLOCKED',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[500],
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Compact reading section (140px)
  Widget _buildReadingSection(BuildContext context) {
    return Obx(() {
      final verse = controller.dailyVerse.value;
      final isFavorite = controller.isDailyVerseFavorite.value;

      if (verse == null) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'READING OF THE MOMENT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => controller.toggleDailyVerseFavorite(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verse.reference,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"${verse.text}"',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  /// Compact start button (56px)
  Widget _buildStartSessionButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        await Get.toNamed(AppRoutes.prayerLearning);
        controller.loadStats();
        controller.loadLockedAppsCount();
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('🙏', style: TextStyle(fontSize: 22)),
            SizedBox(width: 10),
            Text(
              'Let\'s Pray Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
