import 'package:flutter/material.dart';

class AppConfig {
  // App information
  static const String appName = 'Fast App';
  static const String appVersion = '1.0.0';

  // Localization
  static const Locale defaultLocale = Locale('en', 'US');
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('fr', 'FR'),
  ];

  static final AppFeatures appFeatures = AppFeatures();
}

class AppFeatures {
  // Authentication features
  final bool enableAnonAuth = false;

  // Profile management features
  final bool showProfile = false;
  final bool editProfile = false;
  final bool deleteAccount = true;

  // User preferences features
  final bool pushNotifications = false;
  final bool languageSelection = false;
  final bool analyticsEnabled = false;
  final bool darkMode = true;
  final bool privacySettings = true;
  final bool termsSettings = true;

  // Support features
  final bool showHelpCenter = false;
  final bool showAppVersion = false;
}
