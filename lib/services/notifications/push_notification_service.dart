// ===============================================================
// PushNotificationService
// ===============================================================
// This service handles push notifications using OneSignal.
// It provides methods for initializing the service, sending tags,
// and removing tags. The class follows the Singleton pattern to
// ensure only one instance is used throughout the app.
//
// Key Features:
// - OneSignal initialization and configuration
// - Permission handling for notifications
// - Listeners for notification events (click, display)
// - Methods for adding and removing tags
//
// TODO: Replace 'YOUR_ONESIGNAL_APP_ID' with your actual OneSignal App ID
// TODO: Implement proper error handling and logging
// TODO: Consider adding methods for handling notification data
// ===============================================================

import 'package:onesignal_flutter/onesignal_flutter.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();

  factory PushNotificationService() {
    return _instance;
  }

  PushNotificationService._internal();

  Future<void> init() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize("YOUR_ONESIGNAL_APP_ID");

    OneSignal.Notifications.requestPermission(true);

    // Add an observer for permission changes
    OneSignal.Notifications.addPermissionObserver((state) {});

    // Add a listener for notification clicks
    OneSignal.Notifications.addClickListener((event) {});

    // Add a listener for foreground notifications
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {});
  }

  Future<void> sendTag(String key, String value) async {
    await OneSignal.User.addTagWithKey(key, value);
  }

  Future<void> removeTag(String key) async {
    await OneSignal.User.removeTag(key);
  }

  //Implement methods for sending and removing multiple tags
  Future<void> sendTags(Map<String, String> tags) async {
    await OneSignal.User.addTags(tags);
  }

  //Implement methods for sending and removing multiple tags
  Future<void> removeTags(List<String> keys) async {
    await OneSignal.User.removeTags(keys);
  }

  //Implement methods for getting tags
  Future<Map<String, dynamic>> getTags() async {
    return await OneSignal.User.getTags();
  }

  //Implement methods for setting external user ID
  Future<void> setExternalUserId(String externalUserId) async {
    await OneSignal.login(externalUserId);
  }

  //Implement methods for removing external user ID
  Future<void> removeExternalUserId() async {
    await OneSignal.logout();
  }
}
