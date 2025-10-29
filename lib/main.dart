import 'package:faithlock/app_routes.dart';
import 'package:faithlock/config/app_config.dart';
import 'package:faithlock/config/env.dart';
import 'package:faithlock/core/localization/app_translations.dart';
import 'package:faithlock/core/theme/export.dart';
import 'package:faithlock/features/faithlock/services/faithlock_database_service.dart';
import 'package:faithlock/features/faithlock/services/unlock_timer_service.dart';
import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/services/app_launch_service.dart';
import 'package:faithlock/services/auto_navigation_service.dart';
import 'package:faithlock/services/deep_link_service.dart';
import 'package:faithlock/services/notifications/local_notification_service.dart';
import 'package:faithlock/services/storage/preferences_service.dart';
import 'package:faithlock/services/subscription/revenuecat_service.dart';
import 'package:faithlock/shared/widgets/dialogs/fast_alert_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 FaithLock: Starting app initialization...');

  await Future.wait([
    _initializeSupabase(),
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

Future<void> _initializeSupabase() async {
  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    debugPrint('✅ Supabase initialized');
  } catch (e) {
    debugPrint('❌ Supabase initialization failed: $e');
  }
}

Future<void> _initializeDatabase() async {
  try {
    final FaithLockDatabaseService db = FaithLockDatabaseService();
    await db.database;
    debugPrint('✅ Database initialized');
  } catch (e) {
    debugPrint('❌ Database initialization failed: $e');
    rethrow;
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

    try {
      final LocalNotificationService notificationService =
          LocalNotificationService();
      await notificationService.initialize();

      Future.delayed(const Duration(seconds: 2), () async {
        final context = Get.context;
        if (context != null) {
          final prefs = PreferencesService();
          final hasAsked =
              await prefs.readBool('notification_permission_asked') ?? false;

          print('asked notif ${hasAsked}');

          if (await _shouldShowOnboarding() == false && !hasAsked) {
            final permissionsGranted =
                await _requestNotificationPermissionsWithDialog(
              context,
              notificationService,
            );
            debugPrint(
                '✅ LocalNotificationService initialized (permissions: $permissionsGranted)');

            // Mark that we asked
            await prefs.writeBool('notification_permission_asked', true);

            if (!permissionsGranted) {
              debugPrint('⚠️ Notification permissions denied by user!');
              debugPrint(
                  '💡 User needs to enable notifications in iOS Settings');
            }

            // Wait before next prompt to avoid overwhelming user
            await Future.delayed(const Duration(seconds: 3));
          } else {
            debugPrint(
                'ℹ️ Notification permissions already requested in the past');
          }
        }
      });
    } catch (e) {
      debugPrint('⚠️ LocalNotificationService initialization failed: $e');
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

    try {
      // Deep Links
      final DeepLinkService deepLinkService = DeepLinkService();
      await deepLinkService.initialize();
      debugPrint('✅ DeepLinkService initialized');
    } catch (e) {
      debugPrint('⚠️ DeepLinkService initialization failed: $e');
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

Future<bool> _requestNotificationPermissionsWithDialog(
  BuildContext context,
  LocalNotificationService notificationService,
) async {
  // Show explanatory dialog first and wait for user to tap Continue
  await FastAlertDialog.show(
    context: context,
    title: '🔔 Enable Notifications',
    message: 'Notifications are essential for FaithLock to work properly.\n\n'
        'We\'ll remind you to re-lock your apps after the unlock timer expires, '
        'helping you stay focused on your spiritual journey.\n\n'
        'Tap "Continue" to enable notifications.',
    actions: [
      FastDialogAction(
        text: 'Continue',
        isDefault: true,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );

  // Wait a brief moment for dialog animation to complete
  await Future.delayed(const Duration(milliseconds: 300));

  // Now request permissions (iOS system prompt will appear)
  return await notificationService.requestPermissions();
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoNavigation();
    });
  }

  Future<void> _checkAutoNavigation() async {
    final shouldShowOnboarding = await _shouldShowOnboarding();

    if (shouldShowOnboarding) {
      debugPrint('📚 First launch - navigating to onboarding');
      Get.offAllNamed(AppRoutes.scriptureOnboarding);
      return;
    }

    final autoNavService = AutoNavigationService();
    await autoNavService.checkAndNavigate();
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
      initialRoute: AppRoutes.main,
      getPages: AppRoutes.getPages(),
      // home: InitialRouteScreen(),
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
