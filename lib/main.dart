import 'package:faithlock/app_routes.dart';
import 'package:faithlock/config/app_config.dart';
import 'package:faithlock/config/env.dart';
import 'package:faithlock/core/localization/app_translations.dart';
import 'package:faithlock/core/theme/export.dart';
import 'package:faithlock/features/faithlock/services/faithlock_database_service.dart';
import 'package:faithlock/features/faithlock/services/unlock_timer_service.dart';
import 'package:faithlock/features/onboarding/screens/initial_route_screen.dart';
import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/services/app_launch_service.dart';
import 'package:faithlock/services/auto_navigation_service.dart';
import 'package:faithlock/services/notifications/local_notification_service.dart';
import 'package:faithlock/services/notifications/notification_navigation_service.dart';
import 'package:faithlock/services/notifications/winback_notification_service.dart';
import 'package:faithlock/services/storage/preferences_service.dart';
import 'package:faithlock/services/subscription/revenuecat_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 FaithLock: Starting app initialization...');

  await Future.wait([
    _initializeDatabase(),
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  ]);

  debugPrint('✅ Critical services initialized');

  _initializeNonCriticalServices();

  runApp(const App());
}

Future<void> _initializeDatabase() async {
  try {
    final FaithLockDatabaseService db = FaithLockDatabaseService();
    await db.database.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Database initialization timed out after 10 seconds');
      },
    );
    debugPrint('✅ Database initialized');
  } catch (e, stackTrace) {
    debugPrint('❌ Database initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    // Don't rethrow - allow app to continue without database
    // The app can handle missing data gracefully
  }
}

Future<bool> _shouldShowOnboarding() async {
  try {
    final prefs = PreferencesService();
    final hasCompletedOnboarding =
        await prefs.readBool('scripture_onboarding_complete') ?? false;
    return !hasCompletedOnboarding;
  } catch (e) {
    debugPrint('⚠️ Error checking onboarding status: $e');
    return true;
  }
}

void _initializeNonCriticalServices() {
  Future.microtask(() async {
    debugPrint('⏳ Loading non-critical services in background...');

    // Initialize LocalNotificationService for handling notification taps
    // This does NOT request permissions - only sets up the tap handler
    try {
      final LocalNotificationService notificationService =
          LocalNotificationService();
      await notificationService.initialize();
      debugPrint('✅ LocalNotificationService initialized');
    } catch (e) {
      debugPrint('⚠️ LocalNotificationService initialization failed: $e');
    }

    // Initialize NotificationNavigationService to handle iOS MethodChannel navigation
    try {
      final NotificationNavigationService navService =
          NotificationNavigationService();
      await navService.initialize();
      debugPrint('✅ NotificationNavigationService initialized');
    } catch (e) {
      debugPrint('⚠️ NotificationNavigationService initialization failed: $e');
    }

    try {
      final PostHogService postHog = PostHogService.instance;
      await postHog.init(
        customApiKey: Env.postHogApiKey,
        environment: kDebugMode ? 'development' : 'production',
        enableDebug: kDebugMode,
      );
      debugPrint('✅ PostHog initialized');
    } catch (e) {
      debugPrint('⚠️ PostHog initialization failed: $e');
    }

    try {
      // RevenueCat
      final RevenueCatService revenueCat = Get.put(RevenueCatService());
      await revenueCat.initialize(
        apiKey: Env.revenueCatApiKey,
        enableDebugLogs: kDebugMode,
      );
      debugPrint('✅ RevenueCat initialized');
    } catch (e) {
      debugPrint('⚠️ RevenueCat initialization failed: $e');
    }

    // try {
    //   // Deep Links
    //   final DeepLinkService deepLinkService = DeepLinkService();
    //   await deepLinkService.initialize();
    //   debugPrint('✅ DeepLinkService initialized');
    // } catch (e) {
    //   debugPrint('⚠️ DeepLinkService initialization failed: $e');
    // }

    // Win-back: check if sequence completed (after RevenueCat)
    try {
      await WinBackNotificationService().checkAndMarkCompleted();
      debugPrint('✅ WinBackNotificationService checked');
    } catch (e) {
      debugPrint('⚠️ WinBackNotificationService check failed: $e');
    }

    try {
      // Unlock Timer Service
      final UnlockTimerService unlockTimerService = UnlockTimerService();
      unlockTimerService.initialize();
      debugPrint('✅ UnlockTimerService initialized');
    } catch (e) {
      debugPrint('⚠️ UnlockTimerService initialization failed: $e');
    }

    try {
      // App Launch Service - set as natural launch by default
      final AppLaunchService launchService = AppLaunchService();
      await launchService.setLaunchSource(AppLaunchService.sourceNatural);
      debugPrint('✅ AppLaunchService initialized (natural launch)');
    } catch (e) {
      debugPrint('⚠️ AppLaunchService initialization failed: $e');
    }

    debugPrint('✅ All non-critical services loaded');
  });
}

// Function removed - notification permissions are now requested during onboarding
// See: lib/features/onboarding/ for permission flow

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    // Auto-navigation is now handled by InitialRouteScreen
    // This prevents double navigation logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPrayerNavigation();
    });
  }

  Future<void> _checkPrayerNavigation() async {
    // Only check for prayer navigation flag
    // Don't interfere with InitialRouteScreen's routing logic
    try {
      final autoNavService = AutoNavigationService();
      await autoNavService.checkAndNavigate();
    } catch (e) {
      debugPrint('⚠️ Error checking prayer navigation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      theme: FastTheme.light,
      darkTheme: FastTheme.dark,
      themeMode:
          FastTheme.isDarkMode(context) ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      getPages: AppRoutes.getPages(),
      home: InitialRouteScreen(),
      translations: AppTranslations(),
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppConfig.supportedLocales,
      locale: Get.deviceLocale ?? AppConfig.defaultLocale,
      fallbackLocale: AppConfig.defaultLocale,
    );
  }
}
