import 'package:faithlock/app_routes.dart';
import 'package:faithlock/services/app_group_storage.dart';
import 'package:faithlock/services/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// This class manages local notifications in the app
class LocalNotificationService {
  // Single instance of LocalNotificationService (Singleton pattern)
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  // Factory constructor to return the single instance
  factory LocalNotificationService() => _instance;

  // Private constructor
  LocalNotificationService._internal();

  // Plugin to handle platform-specific notification services
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Set up notifications for Android and iOS
  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    // Combined settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  // Handle user tapping on a notification
  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse response) async {
    debugPrint('📲 Notification tapped - checking for prayer navigation request');

    // Check if the prayer flag is set in App Group
    // This flag is set by ShieldActionExtension when user taps "Start Prayer"
    final shouldNavigate = await AppGroupStorage.shouldNavigateToPrayer();

    if (shouldNavigate) {
      debugPrint('✅ Prayer navigation requested - navigating to prayer learning');

      // Clear the flag so we don't navigate again
      await AppGroupStorage.clearPrayerFlag();

      // Navigate to prayer learning screen
      // Use Get.offAllNamed to clear navigation stack and start fresh
      Get.offAllNamed(AppRoutes.prayerLearning);

      debugPrint('🙏 Navigated to prayer learning screen');
    } else {
      debugPrint('ℹ️ No prayer navigation requested');

      // Handle other notification types based on payload
      final String? payload = response.payload;
      if (payload != null) {
        debugPrint('Notification payload: $payload');
        // Handle other notification types here
      }
    }
  }

  // Handle iOS foreground notifications
  Future<void> _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    debugPrint('Received local notification: $title, $body, $payload');
    // TODO: Handle iOS foreground notification
  }

  // Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // Schedule a notification for a future time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      throw ArgumentError('Scheduled date must be in the future');
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Request notification permissions on iOS
  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Check if the app has notification permissions
  Future<bool> hasPermissions() async {
    final bool? granted = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions();
    return granted ?? true; // Android defaults to true
  }
}

class Services {
  LocalDatabaseService service = LocalDatabaseService();
}
