import 'package:faithlock/features/auth/screens/forgot_password_screen.dart';
import 'package:faithlock/features/auth/screens/new_password_screen.dart';
import 'package:faithlock/features/auth/screens/signin_screen.dart';
import 'package:faithlock/features/auth/screens/signup_screen.dart';
import 'package:faithlock/features/auth/screens/verify_otp_screen.dart';
import 'package:faithlock/features/faithlock/screens/permissions_onboarding_screen.dart';
import 'package:faithlock/features/faithlock/services/schedule_monitor_service.dart';
import 'package:faithlock/features/faithlock/services/screen_time_service.dart';
import 'package:faithlock/features/onboarding/export.dart';
import 'package:faithlock/features/onboarding/screens/scripture_onboarding_screen.dart';
import 'package:faithlock/features/profile/screens/profile_screen.dart';
import 'package:faithlock/navigation/screens/main_screen.dart';
import 'package:faithlock/services/api/supabase/supabase_auth_service.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SupabaseAuthService());

    // Initialize and start schedule monitoring
    final scheduleMonitor = ScheduleMonitorService();
    scheduleMonitor.startMonitoring();
  }
}

class AppRoutes {
  static String getInitialRoute() {
    return root;
  }

  static Future<String> determineInitialRoute() async {
    // For testing: Launch Scripture Onboarding directly
    return scriptureOnboarding;

    // final bool hasCompletedOnboarding = needsInteractiveOnboarding
    //     ? await FastInteractiveOnboardingController.hasCompletedOnboarding()
    //     : await OnboardingController.hasCompletedOnboarding();

    // if (!hasCompletedOnboarding) {
    //   return onboarding;
    // }

    // final screenTimeService = ScreenTimeService();
    // try {
    //   final status = await screenTimeService.getAuthorizationStatusText();

    //   if (status == 'Not Requested') {
    //     return permissionsOnboarding;
    //   }
    // } catch (e) {
    //   print('⚠️ Error checking Screen Time status: $e');
    // }

    // if (Supabase.instance.client.auth.currentUser != null) {
    //   return main;
    // }

    // if (AppConfig.appFeatures.enableAnonAuth) {
    //   try {
    //     final authService = SupabaseAuthService();
    //     final response = await authService.signInAnonymously();

    //     if (response.user != null) {
    //       return main;
    //     }
    //   } catch (e) {
    //     print('❌ Anonymous auth failed: $e');
    //   }
    // }

    // // Standard auth flow - check local storage
    // final bool? isLoggedIn =
    //     await StorageService().readBool(LocalStorageKeys.isLoggedIn);
    // return isLoggedIn == true ? main : signUp;
    // final screenTimeService = ScreenTimeService();
    // try {
    //   final status = await screenTimeService.getAuthorizationStatusText();

    //   if (status == 'Not Requested') {
    //     return permissionsOnboarding;
    //   }
    // } catch (e) {
    //   print('⚠️ Error checking Screen Time status: $e');
    // }

    // return main;
  }

  static bool get needsInteractiveOnboarding => true;

  // Alternative: Use OnboardingHelper for dynamic selection
  // Instead of route-based, you can use:
  // OnboardingHelper.launch(needsUserInteraction: true/false)
  // OnboardingHelper.smartLaunch(needsPermissions: true, needsUserInput: false)

  static const String root = '/';
  static const String onboarding = '/onboarding';
  static const String scriptureOnboarding = '/scripture-onboarding';
  static const String permissionsOnboarding = '/permissions-onboarding';
  static const String signIn = '/auth/signin';
  static const String signUp = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String newPassword = '/auth/new-password';
  static const String shipping = '/shipping/create';
  static const String account = '/user/account';
  static const String store = '/store';
  static const String profile = '/profile';
  static const String main = '/main';
  static const String home = '/home';
  static const String eLearning = '/e-learning';

  static List<GetPage<dynamic>> getPages() {
    return <GetPage<dynamic>>[
      GetPage<dynamic>(
        name: onboarding,
        page: () => needsInteractiveOnboarding
            ? FastInteractiveOnboardingScreen()
            : FastOnboardingScreen(),
      ),
      GetPage<dynamic>(
        name: scriptureOnboarding,
        page: () => const ScriptureOnboardingScreen(),
      ),
      GetPage<dynamic>(
        name: permissionsOnboarding,
        page: () => const PermissionsOnboardingScreen(),
      ),
      GetPage<dynamic>(name: signIn, page: () => const SignInScreen()),
      GetPage<dynamic>(name: signUp, page: () => SignUpScreen()),
      GetPage<dynamic>(
          name: forgotPassword, page: () => ForgotPasswordScreen()),
      GetPage<dynamic>(name: verifyOtp, page: () => VerifyOtpScreen()),
      GetPage<dynamic>(name: newPassword, page: () => NewPasswordScreen()),
      GetPage<dynamic>(name: profile, page: () => ProfileScreen()),
      GetPage<dynamic>(name: main, page: () => MainScreen()),
      GetPage<dynamic>(name: home, page: () => MainScreen()),
    ];
  }
}
