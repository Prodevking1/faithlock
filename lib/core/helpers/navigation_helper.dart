/// NavigationHelper: A utility class for managing navigation within the app.
///
/// This class provides static methods for common navigation operations,
/// including determining the initial route based on login status and
/// navigating between different screens.
///
/// Key features:
/// - Retrieves the initial route based on user login status
/// - Provides methods for various navigation patterns (push, replace, remove until)
/// - Utilizes GetX for navigation management
/// - Integrates with SecureStorageService for persistent login state
library;

import 'package:faithlock/core/constants/core/local_storage_keys.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:get/get.dart';

class NavigationHelper {
  static final StorageService _secureStorage = StorageService();

  static Future<String> getInitialRoute() async {
    final bool? isLoggedIn =
        await _secureStorage.readBool(LocalStorageKeys.isLoggedIn);
    return isLoggedIn == true ? '/home' : '/login';
  }

  static void navigateTo(String routeName, {arguments}) {
    Get.toNamed(routeName, arguments: arguments);
  }

  static void navigateAndReplace(String routeName, {arguments}) {
    Get.offAndToNamed(routeName, arguments: arguments);
  }

  static void navigateAndRemoveUntil(String routeName, {arguments}) {
    Get.offAllNamed(routeName, arguments: arguments);
  }
}
