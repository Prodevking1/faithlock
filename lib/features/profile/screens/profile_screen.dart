import 'package:faithlock/config/app_config.dart';
import 'package:faithlock/features/faithlock/controllers/faithlock_settings_controller.dart';
import 'package:faithlock/features/paywall/screens/paywall_screen.dart';
import 'package:faithlock/features/profile/controllers/settings_controller.dart';
import 'package:faithlock/services/subscription/revenuecat_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final SettingsController settingsController = Get.put(SettingsController());

  // Use lazy initialization to avoid blocking UI
  FaithLockSettingsController get faithLockController =>
      Get.put(FaithLockSettingsController());

  @override
  Widget build(BuildContext context) {
    final bool isIOS = GetPlatform.isIOS;

    if (isIOS) {
      return _buildIOSProfileScreen(context);
    } else {
      return _buildAndroidProfileScreen(context);
    }
  }

  // iOS Native Style
  Widget _buildIOSProfileScreen(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor:
          CupertinoColors.systemGroupedBackground.resolveFrom(context),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildIOSSettingsList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSSettingsList(BuildContext context) {
    final appFeatures = AppConfig.appFeatures;

    return Column(
      children: [
        // App Settings Section
        _buildIOSSection([
          // _buildIOSListTile(
          //   context,
          //   leading: CupertinoIcons.lock_shield_fill,
          //   title: 'FaithLock Settings',
          //   subtitle: 'Manage permissions & app blocking',
          //   iconColor: CupertinoColors.systemPurple,
          //   onTap: () => Get.to(() => const SettingsScreen()),
          // ),
          // Blocked Apps - Direct access
          Obx(() {
            String subtitle;
            if (!faithLockController.isScreenTimeAuthorized.value) {
              subtitle = 'Screen Time permission required';
            } else if (faithLockController.selectedAppsCount.value > 0) {
              subtitle = 'Apps configured - tap to modify';
            } else {
              subtitle = 'No apps selected yet';
            }

            return _buildIOSListTile(
              context,
              leading: CupertinoIcons.square_grid_2x2,
              title: 'Blocked Apps',
              subtitle: subtitle,
              iconColor: CupertinoColors.systemRed,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (faithLockController.selectedAppsCount.value > 0)
                    Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: CupertinoColors.systemGreen,
                      size: 20,
                    ),
                  if (faithLockController.selectedAppsCount.value > 0)
                    const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.chevron_forward,
                    color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                    size: 16,
                  ),
                ],
              ),
              onTap: faithLockController.isScreenTimeAuthorized.value
                  ? () => faithLockController.selectAppsToBlock()
                  : null,
            );
          }),
          if (appFeatures.darkMode)
            _buildIOSListTile(
              context,
              leading: CupertinoIcons.moon_fill,
              title: 'darkMode'.tr,
              trailing: Obx(() => Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: settingsController.isDarkMode.value,
                      onChanged: settingsController.toggleDarkMode,
                    ),
                  )),
            ),

          _buildIOSListTile(
            context,
            leading: CupertinoIcons.bell,
            title: 'Notifications',
            subtitle: 'Get reminders for scheduled locks',
            onTap: () => Get.put(FaithLockSettingsController())
                .requestNotificationsPermission(),
            trailing: Obx(() {
              final isGranted = settingsController.notificationsEnabled.value;
              return Icon(
                isGranted
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.exclamationmark_circle,
                color: isGranted
                    ? CupertinoColors.systemGreen
                    : CupertinoColors.systemRed,
                size: 20,
              );
            }),
          ),
          if (appFeatures.languageSelection)
            _buildIOSListTile(
              context,
              leading: CupertinoIcons.globe,
              title: 'language'.tr,
              subtitle:
                  '${'current'.tr} ${settingsController.appLanguage.value.toUpperCase()}',
              onTap: () => _showLanguagePicker(context),
            ),
          if (appFeatures.analyticsEnabled)
            _buildIOSListTile(
              context,
              leading: CupertinoIcons.chart_bar_fill,
              title: 'analytics'.tr,
              subtitle: 'helpImproveApp'.tr,
              trailing: Obx(() => Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: settingsController.analyticsEnabled.value,
                      onChanged: settingsController.toggleAnalytics,
                    ),
                  )),
            ),
        ], title: 'settings'.tr),

        // Support Section
        _buildIOSSection([
          _buildIOSListTile(
            context,
            leading: CupertinoIcons.star_fill,
            title: 'rateApp'.tr,
            iconColor: CupertinoColors.systemOrange,
            onTap: settingsController.rateApp,
          ),
          _buildIOSListTile(
            context,
            leading: CupertinoIcons.mail_solid,
            title: 'contactSupport'.tr,
            iconColor: CupertinoColors.systemGreen,
            onTap: settingsController.contactSupport,
          ),
          if (appFeatures.privacySettings)
            _buildIOSListTile(
              context,
              leading: CupertinoIcons.doc_text_fill,
              title: 'privacyPolicy'.tr,
              iconColor: CupertinoColors.systemIndigo,
              onTap: settingsController.openPrivacyPolicy,
            ),
          if (appFeatures.termsSettings)
            _buildIOSListTile(
              context,
              leading: CupertinoIcons.doc_text_fill,
              title: 'Terms and conditions',
              iconColor: CupertinoColors.systemIndigo,
              onTap: settingsController.openTerms,
            ),
        ], title: 'support'.tr),

        // Subscription Section
        Obx(() {
          final hasSubscription =
              RevenueCatService.instance.isSubscriptionActive.value;

          return _buildIOSSection([
            if (hasSubscription)
              _buildIOSListTile(
                context,
                leading: CupertinoIcons.creditcard_fill,
                title: 'Manage Subscription',
                subtitle: 'View and manage your subscription',
                iconColor: CupertinoColors.systemPurple,
                onTap: settingsController.manageSubscription,
              )
            else
              _buildIOSListTile(
                context,
                leading: CupertinoIcons.star_fill,
                title: 'Get FaithLock Pro',
                subtitle: 'Unlock all features with premium',
                iconColor: CupertinoColors.systemYellow,
                onTap: () => Get.to(() => const PaywallScreen()),
              ),
          ], title: 'subscription'.tr);
        }),
      ],
    );
  }

  Widget _buildIOSSection(List<Widget> children, {String? title}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      CupertinoColors.secondaryLabel.resolveFrom(Get.context!),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(Get.context!),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey
                      .resolveFrom(Get.context!)
                      .withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: children.asMap().entries.map((entry) {
                final index = entry.key;
                final child = entry.value;
                return Column(
                  children: [
                    child,
                    if (index < children.length - 1)
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 56,
                        color:
                            CupertinoColors.separator.resolveFrom(Get.context!),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSListTile(
    BuildContext context, {
    required IconData leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDestructive
                    ? CupertinoColors.systemRed.withValues(alpha: 0.1)
                    : (iconColor ?? CupertinoColors.systemBlue)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                leading,
                color: iconColor ??
                    (isDestructive
                        ? CupertinoColors.systemRed
                        : CupertinoColors.systemBlue),
                size: 18,
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
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: titleColor ??
                          (isDestructive
                              ? CupertinoColors.systemRed
                              : CupertinoColors.label.resolveFrom(context)),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing widget
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing,
            ] else if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.chevron_forward,
                color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Android Material Style
  Widget _buildAndroidProfileScreen(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Settings List
            _buildAndroidSettingsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidSettingsList(BuildContext context) {
    final appFeatures = AppConfig.appFeatures;

    return Column(
      children: [
        // App Settings
        _buildAndroidSection(
          context,
          'settings'.tr,
          [
            if (appFeatures.darkMode)
              _buildAndroidListTile(
                context,
                leading: Icons.dark_mode,
                title: 'darkMode'.tr,
                trailing: Obx(() => Switch(
                      value: settingsController.isDarkMode.value,
                      onChanged: settingsController.toggleDarkMode,
                    )),
              ),
            if (appFeatures.languageSelection)
              _buildAndroidListTile(
                context,
                leading: Icons.language,
                title: 'language'.tr,
                subtitle: settingsController.appLanguage.value.toUpperCase(),
                onTap: () => _showLanguagePicker(context),
              ),
          ],
        ),

        // Support
        _buildAndroidSection(
          context,
          'support'.tr,
          [
            if (appFeatures.showAppVersion)
              _buildAndroidListTile(
                context,
                leading: Icons.info,
                title: 'appInformation'.tr,
                onTap: settingsController.rateApp,
              ),
            _buildAndroidListTile(
              context,
              leading: Icons.mail,
              title: 'contactSupport'.tr,
              onTap: settingsController.contactSupport,
            ),
            _buildAndroidListTile(
              context,
              leading: Icons.privacy_tip,
              title: 'privacyPolicy'.tr,
              onTap: settingsController.openPrivacyPolicy,
            ),
          ],
        ),

        // Subscription Section
        Obx(() {
          final hasSubscription =
              RevenueCatService.instance.isSubscriptionActive.value;

          return _buildAndroidSection(
            context,
            'subscription'.tr,
            [
              if (hasSubscription)
                _buildAndroidListTile(
                  context,
                  leading: Icons.credit_card,
                  title: 'Manage Subscription',
                  subtitle: 'View and manage your subscription',
                  iconColor: Colors.purple,
                  onTap: settingsController.manageSubscription,
                )
              else
                _buildAndroidListTile(
                  context,
                  leading: Icons.star,
                  title: 'Become Premium',
                  subtitle: 'Unlock all features with premium',
                  iconColor: Colors.amber,
                  onTap: () => Get.to(() => const PaywallScreen()),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildAndroidSection(
    BuildContext context,
    String? title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ),
        ],
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildAndroidListTile(
    BuildContext context, {
    required IconData leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        leading,
        color: iconColor ?? Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  // Language Picker
  void _showLanguagePicker(BuildContext context) {
    if (GetPlatform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => Container(
          height: 280,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey3.resolveFrom(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Get.back(),
                        child: Text(
                          'cancel'.tr,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        'selectLanguage'.tr,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Get.back(),
                        child: Text(
                          'done'.tr,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Picker
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 44.0,
                    scrollController: FixedExtentScrollController(
                      initialItem:
                          settingsController.appLanguage.value == 'en' ? 0 : 1,
                    ),
                    onSelectedItemChanged: (int index) {
                      settingsController
                          .changeLanguage(index == 0 ? 'en' : 'fr');
                    },
                    children: [
                      _buildLanguagePickerItem('🇺🇸', 'english'.tr),
                      _buildLanguagePickerItem('🇫🇷', 'french'.tr),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'selectLanguage'.tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Obx(() => RadioListTile<String>(
                    title: Text('english'.tr),
                    value: 'en',
                    groupValue: settingsController.appLanguage.value,
                    onChanged: (value) {
                      if (value != null) {
                        settingsController.changeLanguage(value);
                        Get.back();
                      }
                    },
                  )),
              Obx(() => RadioListTile<String>(
                    title: Text('french'.tr),
                    value: 'fr',
                    groupValue: settingsController.appLanguage.value,
                    onChanged: (value) {
                      if (value != null) {
                        settingsController.changeLanguage(value);
                        Get.back();
                      }
                    },
                  )),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildLanguagePickerItem(String flag, String language) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            flag,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Text(
            language,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
