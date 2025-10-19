import 'package:faithlock/config/app_config.dart';
import 'package:faithlock/core/helpers/ui_helper.dart';
import 'package:faithlock/features/auth/controllers/signout_controller.dart';
import 'package:faithlock/features/faithlock/controllers/faithlock_settings_controller.dart';
import 'package:faithlock/features/profile/controllers/profile_controller.dart';
import 'package:faithlock/features/profile/controllers/settings_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController profileController = Get.put(ProfileController());
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
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'profile'.tr,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        border: null,
      ),
      backgroundColor:
          CupertinoColors.systemGroupedBackground.resolveFrom(context),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // User Info Section with enhanced design
            SliverToBoxAdapter(
              child: _buildIOSUserInfoSection(context),
            ),

            // Profile & Settings Sections with better spacing
            SliverToBoxAdapter(
              child: _buildIOSSettingsList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSUserInfoSection(BuildContext context) {
    if (!AppConfig.appFeatures.showProfile) {
      return const SizedBox.shrink();
    }
    return Obx(() => Container(
          margin: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey
                    .resolveFrom(context)
                    .withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Avatar with status indicator
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CupertinoColors.systemGrey5.resolveFrom(context),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          CupertinoColors.systemGrey5.resolveFrom(context),
                      backgroundImage:
                          NetworkImage(profileController.user.value.avatarUrl),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CupertinoColors.systemBackground
                              .resolveFrom(context),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Name with better typography
              Text(
                profileController.user.value.fullName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.label.resolveFrom(context),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // Email with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.mail_solid,
                    size: 14,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    profileController.user.value.email,
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Member since with better styling
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 12,
                      color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${'memberSince'.tr} ${profileController.user.value.joinDate}',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            CupertinoColors.tertiaryLabel.resolveFrom(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildIOSSettingsList(BuildContext context) {
    final appFeatures = AppConfig.appFeatures;

    return Column(
      children: [
        // Profile Actions Section
        _buildIOSSection([
          if (appFeatures.editProfile)
            _buildIOSListTile(
              context,
              leading: CupertinoIcons.person_circle_fill,
              title: 'editProfile'.tr,
              subtitle: 'updatePersonalInfo'.tr,
              onTap: profileController.navigateToEditProfile,
            ),
          if (appFeatures.pushNotifications)
            _buildIOSListTile(
              context,
              leading: CupertinoIcons.bell_fill,
              title: 'notifications'.tr,
              subtitle: 'pushNotifications'.tr,
              trailing: Obx(() => Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: profileController.pushNotifications.value,
                      onChanged: profileController.togglePushNotifications,
                    ),
                  )),
            ),
        ], title: 'profile'.tr),

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
        ], title: 'support'.tr),

        // Sign Out Section
        if (appFeatures.deleteAccount)
          _buildIOSSection([
            _buildIOSListTile(
              context,
              leading: CupertinoIcons.square_arrow_right_fill,
              title: 'signOut'.tr,
              isDestructive: true,
              onTap: () => _showIOSSignOutDialog(context),
            ),
          ]),

        const SizedBox(height: 32),

        // App Version with better styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6.resolveFrom(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.info_circle_fill,
                size: 16,
                color: CupertinoColors.tertiaryLabel.resolveFrom(context),
              ),
              const SizedBox(width: 8),
              Text(
                '${'version'.tr} ${settingsController.appVersion.value} (${settingsController.buildNumber.value})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
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
                      .withOpacity(0.08),
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
            // Leading icon with background
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDestructive
                    ? CupertinoColors.systemRed.withOpacity(0.1)
                    : (iconColor ?? CupertinoColors.systemBlue)
                        .withOpacity(0.1),
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
                      fontWeight: FontWeight.w500,
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
      appBar: AppBar(
        title: Text('profile'.tr),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Info Section
            _buildAndroidUserInfoSection(context),

            const SizedBox(height: 24),

            // Settings List
            _buildAndroidSettingsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidUserInfoSection(BuildContext context) {
    return Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage(profileController.user.value.avatarUrl),
              ),
              const SizedBox(height: 16),
              Text(
                profileController.user.value.fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                profileController.user.value.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '${'memberSince'.tr} ${profileController.user.value.joinDate}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ),
        ));
  }

  Widget _buildAndroidSettingsList(BuildContext context) {
    final appFeatures = AppConfig.appFeatures;

    return Column(
      children: [
        // Profile Actions
        _buildAndroidSection(
          context,
          'profile'.tr,
          [
            if (appFeatures.editProfile)
              _buildAndroidListTile(
                context,
                leading: Icons.edit,
                title: 'editProfile'.tr,
                subtitle: 'updatePersonalInfo'.tr,
                onTap: profileController.navigateToEditProfile,
              ),
            if (appFeatures.pushNotifications)
              _buildAndroidListTile(
                context,
                leading: Icons.notifications,
                title: 'pushNotifications'.tr,
                trailing: Obx(() => Switch(
                      value: profileController.pushNotifications.value,
                      onChanged: profileController.togglePushNotifications,
                    )),
              ),
          ],
        ),

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

        // Sign Out
        _buildAndroidSection(
          context,
          '',
          [
            if (appFeatures.deleteAccount)
              _buildAndroidListTile(
                context,
                leading: Icons.logout,
                title: 'signOut'.tr,
                titleColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _showAndroidSignOutDialog(context),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // App Version
        if (appFeatures.showAppVersion)
          Text(
            '${'version'.tr} ${settingsController.appVersion.value} (${settingsController.buildNumber.value})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),

        const SizedBox(height: 32),
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

  // Sign Out Dialogs
  void _showIOSSignOutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'signOut'.tr,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'signOutConfirmation'.tr,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Get.back();
              // Show loading indicator
              showCupertinoDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const CupertinoAlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoActivityIndicator(),
                      SizedBox(height: 16),
                      Text('Signing out...'),
                    ],
                  ),
                ),
              );

              await SignOutController().signOut();
              Get.back(); // Close loading dialog
              UIHelper.showSuccessSnackBar('signedOutSuccess'.tr);
            },
            child: Text(
              'signOut'.tr,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAndroidSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('signOut'.tr),
        content: Text('signOutConfirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              await SignOutController().signOut();
              Get.back();
              UIHelper.showSuccessSnackBar('signedOutSuccess'.tr);
            },
            child: Text(
              'signOut'.tr,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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
