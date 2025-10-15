import 'package:faithlock/app_routes.dart';
import 'package:faithlock/config/app_config.dart';
import 'package:faithlock/config/env.dart';
import 'package:faithlock/core/errors/error_handler.dart';
import 'package:faithlock/core/localization/app_translations.dart';
import 'package:faithlock/core/network/network_checker.dart';
import 'package:faithlock/core/theme/export.dart';
import 'package:faithlock/features/onboarding/widgets/life_visualization.dart';
import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/services/sentry/sentry_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryConfig.initialize();
  ErrorHandler.initialize();
  final hasNetwork = await NetworkChecker.hasConnection();
  if (hasNetwork) {
    try {
      await Supabase.initialize(
        // url: Env.supabaseUrl,
        // anonKey: Env.supabaseAnonKey,
        url: "https://7c96a3856e05.ngrok-free.app",
        anonKey: Env.supabaseAnonKey,
      );
      debugPrint('✅ Supabase initialized successfully');
    } catch (e) {
      debugPrint('❌ Supabase initialization failed: $e');
    }
  } else {
    debugPrint('⚠️ No network connection - Supabase initialization skipped');
  }

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  final PostHogService postHog = PostHogService.instance;
  await postHog.init(
    customApiKey: Env.postHogApiKey,
    environment: kDebugMode ? 'development' : 'production',
    enableDebug: kDebugMode,
  );

  // Initialize PushNotificationService
  // final PushNotificationService pushNotificationService =
  //     PushNotificationService();
  // await pushNotificationService.init();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    final route = await AppRoutes.determineInitialRoute();
    setState(() {
      _initialRoute = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialRoute == null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      );
    }

    return GetMaterialApp(
      title: AppConfig.appName,
      theme: FastTheme.light,
      darkTheme: FastTheme.dark,
      themeMode:
          FastTheme.isDarkMode(context) ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      initialBinding: AppBindings(),
      // initialRoute: _initialRoute,
      getPages: AppRoutes.getPages(),
      translations: AppTranslations(),
      home: Scaffold(
        backgroundColor: Colors.blue,
        body: SafeArea(
          child: LifeVisualization(
            currentAge: 20,
            lifeExpectancy: 80,
            daysWasted: 5,
            showWasted: true,
          ),
        ),
      ),
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
