import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:faithlock/core/constants/core/fast_spacing.dart';
import 'package:faithlock/shared/widgets/cards/fast_info_card.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/layout/export.dart';
import 'package:faithlock/features/faithlock/controllers/stats_controller.dart';

/// Stats Dashboard Screen
/// Displays user statistics with FastInfoCard widgets
class StatsDashboardScreen extends StatelessWidget {
  const StatsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StatsController());

    return Scaffold(
      backgroundColor: FastColors.surface(context),
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: TextStyle(
            color: FastColors.primaryText(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: FastColors.surface(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: FastColors.primaryText(context),
            ),
            onPressed: controller.refreshStats,
          ),
        ],
      ),
      body: SafeArea(
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

          // Stats display
          return FastScrollableLayout(
            padding: FastSpacing.px16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Your Progress',
                  style: TextStyle(
                    color: FastColors.primaryText(context),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FastSpacing.h8,
                Text(
                  'Keep up the great work!',
                  style: TextStyle(
                    color: FastColors.secondaryText(context),
                    fontSize: 16,
                  ),
                ),
                FastSpacing.h24,

                // Current Streak Card
                _buildStatCard(
                  context,
                  icon: Icons.local_fire_department,
                  iconColor: FastColors.streakOrange,
                  backgroundColor: FastColors.streakOrangeLight,
                  title: 'Current Streak',
                  value: controller.getStreakText(),
                ),
                FastSpacing.h16,

                // Verses Read Card
                _buildStatCard(
                  context,
                  icon: Icons.menu_book,
                  iconColor: FastColors.versesBlue,
                  backgroundColor: FastColors.versesBlueLight,
                  title: 'Verses Read',
                  value: controller.getVersesReadText(),
                ),
                FastSpacing.h16,

                // Success Rate Card
                _buildStatCard(
                  context,
                  icon: Icons.check_circle,
                  iconColor: FastColors.successGreen,
                  backgroundColor: FastColors.successGreenLight,
                  title: 'Success Rate',
                  value: controller.getSuccessRateText(),
                ),
                FastSpacing.h16,

                // Screen Time Reduced Card
                _buildStatCard(
                  context,
                  icon: Icons.timer_off,
                  iconColor: FastColors.timePurple,
                  backgroundColor: FastColors.timePurpleLight,
                  title: 'Time Reduced',
                  value: controller.getScreenTimeText(),
                ),
                FastSpacing.h24,

                // Additional Stats Section
                if (controller.userStats.value != null) ...[
                  Text(
                    'Detailed Stats',
                    style: TextStyle(
                      color: FastColors.primaryText(context),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  FastSpacing.h16,

                  // Longest Streak
                  _buildStatRow(
                    context,
                    'Longest Streak',
                    '${controller.userStats.value!.longestStreak} days',
                  ),
                  FastSpacing.h16,

                  // Successful Unlocks
                  _buildStatRow(
                    context,
                    'Successful Unlocks',
                    '${controller.userStats.value!.successfulUnlocks}',
                  ),
                  FastSpacing.h16,

                  // Failed Attempts
                  _buildStatRow(
                    context,
                    'Failed Attempts',
                    '${controller.userStats.value!.failedAttempts}',
                  ),
                  FastSpacing.h24,
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Build a stat card widget (icon + title + value)
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Title and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: FastColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: FastColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a stat row (label + value)
  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FastColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: FastColors.secondaryText(context),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: FastColors.primaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
