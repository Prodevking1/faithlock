import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:faithlock/core/constants/core/fast_spacing.dart';
import 'package:faithlock/features/faithlock/controllers/faithlock_settings_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Premium iOS-style Settings Screen
/// Manage permissions and app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FaithLockSettingsController());

    return Scaffold(
      backgroundColor: FastColors.surface(context),
      body: CustomScrollView(
        slivers: [
          // Premium iOS-style App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: FastColors.surface(context),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'settings'.tr,
                style: TextStyle(
                  color: FastColors.primaryText(context),
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: FastSpacing.px16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FastSpacing.h24,

                  // Permissions Section
                  _buildSectionHeader('permissions'.tr, context),
                  FastSpacing.h8,
                  _buildPermissionsCard(context, controller),

                  FastSpacing.h32,

                  // App Behavior Section
                  _buildSectionHeader('appBehavior'.tr, context),
                  FastSpacing.h8,
                  _buildBehaviorCard(context, controller),

                  FastSpacing.h32,

                  // About Section
                  _buildSectionHeader('about'.tr, context),
                  FastSpacing.h8,
                  _buildAboutCard(context, controller),

                  FastSpacing.h32,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: FastColors.tertiaryText(context),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPermissionsCard(
      BuildContext context, FaithLockSettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: FastColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Screen Time Permission
          Obx(() => _buildPermissionTile(
                context: context,
                icon: CupertinoIcons.device_phone_portrait,
                title: 'screenTime'.tr,
                subtitle: 'screenTimeRequired'.tr,
                status: controller.screenTimeStatus.value,
                isAuthorized: controller.isScreenTimeAuthorized.value,
                onTap: () => controller.requestScreenTimePermission(),
              )),

          _buildDivider(context),

          // Notifications Permission
          Obx(() => _buildPermissionTile(
                context: context,
                icon: CupertinoIcons.bell,
                title: 'notifications'.tr,
                subtitle: 'notificationsSub'.tr,
                status: controller.notificationsStatus.value,
                isAuthorized: controller.isNotificationsAuthorized.value,
                onTap: () => controller.requestNotificationsPermission(),
              )),
        ],
      ),
    );
  }

  Widget _buildBehaviorCard(
      BuildContext context, FaithLockSettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: FastColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Master Lock Toggle
          Obx(() => _buildToggleTile(
                context: context,
                icon: CupertinoIcons.lock_shield,
                title: 'enableLockSystem'.tr,
                subtitle: 'masterSwitch'.tr,
                value: controller.isLockEnabled.value,
                onChanged: (value) => controller.toggleLockEnabled(value),
              )),

          _buildDivider(context),

          // Notifications Toggle
          Obx(() => _buildToggleTile(
                context: context,
                icon: CupertinoIcons.bell,
                title: 'enableNotifications'.tr,
                subtitle: controller.isNotificationsAuthorized.value
                    ? 'enableNotificationsSub'.tr
                    : 'tapToEnableNotifications'.tr,
                value: controller.isNotificationsAuthorized.value,
                onChanged: (value) async {
                  if (value) {
                    await controller.requestNotificationsPermission();
                  } else {
                    // If user wants to disable, open settings
                    await controller.requestNotificationsPermission();
                  }
                },
              )),

          _buildDivider(context),

          // Emergency Bypass
          _buildNavigationTile(
            context: context,
            icon: CupertinoIcons.exclamationmark_triangle,
            title: 'emergencyBypass'.tr,
            subtitle: 'emergencyBypassSub'.tr,
            trailing: const Icon(CupertinoIcons.chevron_right, size: 20),
            onTap: () => controller.showEmergencyBypassInfo(),
          ),

          _buildDivider(context),

          // Select Apps to Block
          Obx(() {
            String subtitle;
            if (!controller.isScreenTimeAuthorized.value) {
              subtitle = 'screenTimePermRequired'.tr;
            } else if (controller.selectedAppsCount.value > 0) {
              subtitle = 'appsConfigured'.tr;
            } else {
              subtitle = 'noAppsSelected'.tr;
            }

            return _buildNavigationTile(
              context: context,
              icon: CupertinoIcons.square_grid_2x2,
              title: 'blockedApps'.tr,
              subtitle: subtitle,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.selectedAppsCount.value > 0)
                    Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: FastColors.successGreen,
                      size: 20,
                    ),
                  if (controller.selectedAppsCount.value > 0)
                    const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: FastColors.tertiaryText(context),
                    size: 20,
                  ),
                ],
              ),
              onTap: controller.isScreenTimeAuthorized.value
                  ? () => controller.showBlockedApps()
                  : null,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAboutCard(
      BuildContext context, FaithLockSettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: FastColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildNavigationTile(
            context: context,
            icon: CupertinoIcons.info_circle,
            title: 'aboutFaithLock'.tr,
            subtitle: 'version'.trParams({'version': '1.0.0'}),
            trailing: const Icon(CupertinoIcons.chevron_right, size: 20),
            onTap: () => controller.showAboutInfo(),
          ),
          _buildDivider(context),
          _buildNavigationTile(
            context: context,
            icon: CupertinoIcons.doc_text,
            title: 'privacyPolicy'.tr,
            subtitle: 'privacyPolicySub'.tr,
            trailing: const Icon(CupertinoIcons.chevron_right, size: 20),
            onTap: () => controller.openPrivacyPolicy(),
          ),
          _buildDivider(context),
          _buildNavigationTile(
            context: context,
            icon: CupertinoIcons.heart,
            title: 'support'.tr,
            subtitle: 'supportSub'.tr,
            trailing: const Icon(CupertinoIcons.chevron_right, size: 20),
            onTap: () => controller.openSupport(),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required bool isAuthorized,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isAuthorized
                      ? FastColors.successGreen.withValues(alpha: 0.15)
                      : FastColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isAuthorized
                      ? FastColors.successGreen
                      : FastColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: FastColors.primaryText(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: FastColors.tertiaryText(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isAuthorized
                      ? FastColors.successGreen.withValues(alpha: 0.15)
                      : FastColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isAuthorized
                        ? FastColors.successGreen
                        : FastColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: FastColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: FastColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: FastColors.primaryText(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: FastColors.tertiaryText(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Toggle switch
          CupertinoSwitch(
            value: value,
            activeTrackColor: FastColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: FastColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: FastColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: FastColors.primaryText(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: FastColors.tertiaryText(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing icon
              Icon(
                CupertinoIcons.chevron_right,
                color: FastColors.tertiaryText(context),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: FastColors.separator(context),
      ),
    );
  }
}
