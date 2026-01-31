// // ===============================================================
// // PushNotificationService
// // ===============================================================
// // This service handles push notifications using OneSignal.
// // It provides methods for initializing the service, sending tags,
// // and removing tags. The class follows the Singleton pattern to
// // ensure only one instance is used throughout the app.
// //
// // Key Features:
// // - OneSignal initialization and configuration
// // - Permission handling for notifications
// // - Listeners for notification events (click, display)
// // - Methods for adding and removing tags
// //
// // TODO: Replace 'YOUR_ONESIGNAL_APP_ID' with your actual OneSignal App ID
// // TODO: Implement proper error handling and logging
// // TODO: Consider adding methods for handling notification data
// // ===============================================================

// import 'package:onesignal_flutter/onesignal_flutter.dart';

// class PushNotificationService {
//   static final PushNotificationService _instance =
//       PushNotificationService._internal();

//   factory PushNotificationService() {
//     return _instance;
//   }

//   PushNotificationService._internal();

//   bool _isInitialized = false;

//   /// Initialize OneSignal WITHOUT requesting permission
//   /// This is called when user accepts notifications in onboarding
//   Future<void> _ensureInitialized() async {
//     if (_isInitialized) {
//       print('🔔 [OneSignal] Already initialized - skipping');
//       return;
//     }

//     print('🔔 [OneSignal] ================================');
//     print('🔔 [OneSignal] INITIALIZING OneSignal SDK');
//     print('🔔 [OneSignal] Stack trace:');
//     print(StackTrace.current);
//     print('🔔 [OneSignal] ================================');

//     // CRITICAL: Set consent required BEFORE initializing OneSignal
//     // This prevents OneSignal from auto-requesting notification permission
//     OneSignal.consentRequired(true);
//     print('🔔 [OneSignal] Consent required set to TRUE');

//     OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//     OneSignal.initialize("YOUR_ONESIGNAL_APP_ID");
//     print('🔔 [OneSignal] SDK initialized');

//     // Add observers and listeners
//     OneSignal.Notifications.addPermissionObserver((state) {
//       print('🔔 [OneSignal] Permission changed: $state');
//     });
//     OneSignal.Notifications.addClickListener((event) {
//       print('🔔 [OneSignal] Notification clicked');
//     });
//     OneSignal.Notifications.addForegroundWillDisplayListener((event) {
//       print('🔔 [OneSignal] Will display notification in foreground');
//     });

//     _isInitialized = true;
//     print('🔔 [OneSignal] Initialization complete');
//   }

//   /// DEPRECATED: Do not use - kept for backward compatibility
//   @deprecated
//   Future<void> init() async {
//     // Empty - initialization now happens in requestPermission()
//   }

//   /// Request push notification permission
//   /// This initializes OneSignal AND requests permission
//   /// Call this method when you want to ask the user for permission
//   /// (e.g., during onboarding or when user enables a feature)
//   Future<bool> requestPermission() async {
//     print('🔔 [OneSignal] ================================');
//     print('🔔 [OneSignal] requestPermission() CALLED');
//     print('🔔 [OneSignal] Stack trace:');
//     print(StackTrace.current);
//     print('🔔 [OneSignal] ================================');

//     // Initialize OneSignal first (if not already done)
//     await _ensureInitialized();

//     // Grant consent - this allows OneSignal to function
//     OneSignal.consentGiven(true);
//     print('🔔 [OneSignal] Consent GRANTED');

//     // Then request permission
//     print('🔔 [OneSignal] Calling OneSignal.Notifications.requestPermission(true)...');
//     final result = await OneSignal.Notifications.requestPermission(true);
//     print('🔔 [OneSignal] Permission result: $result');

//     return result;
//   }

//   Future<void> sendTag(String key, String value) async {
//     await _ensureInitialized();
//     await OneSignal.User.addTagWithKey(key, value);
//   }

//   Future<void> removeTag(String key) async {
//     await _ensureInitialized();
//     await OneSignal.User.removeTag(key);
//   }

//   //Implement methods for sending and removing multiple tags
//   Future<void> sendTags(Map<String, String> tags) async {
//     await _ensureInitialized();
//     await OneSignal.User.addTags(tags);
//   }

//   //Implement methods for sending and removing multiple tags
//   Future<void> removeTags(List<String> keys) async {
//     await _ensureInitialized();
//     await OneSignal.User.removeTags(keys);
//   }

//   //Implement methods for getting tags
//   Future<Map<String, dynamic>> getTags() async {
//     await _ensureInitialized();
//     return await OneSignal.User.getTags();
//   }

//   //Implement methods for setting external user ID
//   Future<void> setExternalUserId(String externalUserId) async {
//     await _ensureInitialized();
//     await OneSignal.login(externalUserId);
//   }

//   //Implement methods for removing external user ID
//   Future<void> removeExternalUserId() async {
//     await _ensureInitialized();
//     await OneSignal.logout();
//   }
// }
