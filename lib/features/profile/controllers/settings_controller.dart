import 'package:faithlock/core/helpers/export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Controller for managing application settings
class SettingsController extends GetxController {
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyLanguage = 'app_language';
  static const String _keyBiometric = 'biometric_enabled';
  static const String _keyAnalytics = 'analytics_enabled';
  static const String _keyCrashReporting = 'crash_reporting_enabled';

  late final SharedPreferences _prefs;

  // Observable settings
  final RxBool isDarkMode = false.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxString appLanguage = 'en'.obs;
  final RxBool biometricEnabled = false.obs;
  final RxBool analyticsEnabled = true.obs;
  final RxBool crashReportingEnabled = true.obs;

  // App version info
  final RxString appVersion = '1.0.0'.obs;
  final RxString buildNumber = '1'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load settings from persistent storage
    isDarkMode.value = _prefs.getBool(_keyDarkMode) ?? false;
    notificationsEnabled.value = _prefs.getBool(_keyNotifications) ?? true;
    appLanguage.value = _prefs.getString(_keyLanguage) ?? 'en';
    biometricEnabled.value = _prefs.getBool(_keyBiometric) ?? false;
    analyticsEnabled.value = _prefs.getBool(_keyAnalytics) ?? true;
    crashReportingEnabled.value = _prefs.getBool(_keyCrashReporting) ?? true;

    // Apply settings
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // Analytics settings are handled in the analytics service
  }

  // Theme settings
  Future<void> toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    await _prefs.setBool(_keyDarkMode, value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);


  }

  // Notification settings
  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    await _prefs.setBool(_keyNotifications, value);


  }

  // Language settings
  Future<void> changeLanguage(String languageCode) async {
    appLanguage.value = languageCode;
    await _prefs.setString(_keyLanguage, languageCode);

    // Update app locale
    final locale = Locale(languageCode);
    Get.updateLocale(locale);


  }

  // Security settings
  Future<void> toggleBiometric(bool value) async {
    biometricEnabled.value = value;
    await _prefs.setBool(_keyBiometric, value);


  }

  // Privacy settings
  Future<void> toggleAnalytics(bool value) async {
    analyticsEnabled.value = value;
    await _prefs.setBool(_keyAnalytics, value);

    // Update analytics opt-out status
  }

  Future<void> toggleCrashReporting(bool value) async {
    crashReportingEnabled.value = value;
    await _prefs.setBool(_keyCrashReporting, value);


  }

  // Support actions
  Future<void> rateApp() async {
    // TODO: Implement in-app review when package is added
    UIHelper.showInfoSnackBar(
      'App rating will be available soon',
    );


  }

  Future<void> contactSupport() async {
    const String email = 'support@faithlock.com';
    const String subject = 'Fast App Support Request';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': 'App Version: ${appVersion.value} (${buildNumber.value})\n\n',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);


    } else {
      UIHelper.showErrorSnackBar(
        'Could not open email client',
      );
    }
  }

  Future<void> openPrivacyPolicy() async {
    const String privacyUrl = 'https://faithlock.com/privacy';
    final Uri uri = Uri.parse(privacyUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);


    }
  }

  Future<void> openTermsOfService() async {
    const String termsUrl = 'https://faithlock.com/terms';
    final Uri uri = Uri.parse(termsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);


    }
  }

  Future<void> shareApp() async {


    UIHelper.showSuccessSnackBar('Share feature coming soon!');
  }

  // Clear all app data
  Future<void> clearAppData() async {
    await _prefs.clear();
    // TODO: Clear secure storage when available



    // Reset to defaults
    await _loadSettings();
  }
}
