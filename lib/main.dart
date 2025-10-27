import 'package:faithlock/app_routes.dart';
import 'package:faithlock/config/app_config.dart';
import 'package:faithlock/config/env.dart';
import 'package:faithlock/core/localization/app_translations.dart';
import 'package:faithlock/core/theme/export.dart';
import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/services/auto_navigation_service.dart';
import 'package:faithlock/services/deep_link_service.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:faithlock/services/subscription/revenuecat_service.dart';
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

void _initializeNonCriticalServices() {
  Future.microtask(() async {
    debugPrint('⏳ Loading non-critical services in background...');

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

    debugPrint('✅ All non-critical services loaded');
  });
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

  Future<bool> _shouldShowOnboarding() async {
    try {
      final storage = Get.find<StorageService>();
      final hasCompletedOnboarding =
          await storage.readBool('scripture_onboarding_complete') ?? false;
      return !hasCompletedOnboarding;
    } catch (e) {
      debugPrint('⚠️ Error checking onboarding status: $e');
      return true;
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
      initialRoute: AppRoutes.main,
      getPages: AppRoutes.getPages(),
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
