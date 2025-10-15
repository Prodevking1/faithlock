import 'package:faithlock/features/onboarding/models/interactive_action_model.dart';
import 'package:faithlock/services/notifications/push_notification_service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

/// Enhanced permission manager with specialized methods for each permission type
class PermissionManager {
  /// Request push notifications permission using OneSignal
  /// This shows OneSignal's native permission dialog
  static Future<PermissionResult> requestPushNotifications() async {
    try {
      // Initialize OneSignal if not already done
      final pushService = PushNotificationService();
      await pushService.init();

      // Request permission - this shows OneSignal's native popup
      final permission = await OneSignal.Notifications.requestPermission(true);

      return PermissionResult(
        type: PermissionType.pushNotifications,
        isGranted: permission,
        message: permission
          ? 'Push notifications enabled! You\'ll get updates about new beats and challenges.'
          : 'Push notifications disabled. You can enable them later in Settings.',
      );
    } catch (e) {
      return PermissionResult(
        type: PermissionType.pushNotifications,
        isGranted: false,
        message: 'Error requesting push notifications: $e',
        error: e.toString(),
      );
    }
  }

  /// Request microphone permission for audio recording
  static Future<PermissionResult> requestMicrophone() async {
    try {
      final status = await Permission.microphone.request();

      return PermissionResult(
        type: PermissionType.microphone,
        isGranted: status.isGranted,
        message: status.isGranted
          ? 'Microphone access granted! You can now record vocals and audio samples.'
          : _getPermissionDeniedMessage('microphone', status),
      );
    } catch (e) {
      return PermissionResult(
        type: PermissionType.microphone,
        isGranted: false,
        message: 'Error requesting microphone permission',
        error: e.toString(),
      );
    }
  }

  /// Request camera permission for photo/video capture
  static Future<PermissionResult> requestCamera() async {
    try {
      final status = await Permission.camera.request();

      return PermissionResult(
        type: PermissionType.camera,
        isGranted: status.isGranted,
        message: status.isGranted
          ? 'Camera access granted! You can now capture photos for your album artwork.'
          : _getPermissionDeniedMessage('camera', status),
      );
    } catch (e) {
      return PermissionResult(
        type: PermissionType.camera,
        isGranted: false,
        message: 'Error requesting camera permission',
        error: e.toString(),
      );
    }
  }

  /// Request photos/gallery permission
  static Future<PermissionResult> requestPhotos() async {
    try {
      final status = await Permission.photos.request();

      return PermissionResult(
        type: PermissionType.photos,
        isGranted: status.isGranted,
        message: status.isGranted
          ? 'Photos access granted! You can now import images for album covers.'
          : _getPermissionDeniedMessage('photos', status),
      );
    } catch (e) {
      return PermissionResult(
        type: PermissionType.photos,
        isGranted: false,
        message: 'Error requesting photos permission',
        error: e.toString(),
      );
    }
  }

  /// Request location permission
  static Future<PermissionResult> requestLocation() async {
    try {
      final status = await Permission.location.request();

      return PermissionResult(
        type: PermissionType.location,
        isGranted: status.isGranted,
        message: status.isGranted
          ? 'Location access granted! We can suggest local music events and venues.'
          : _getPermissionDeniedMessage('location', status),
      );
    } catch (e) {
      return PermissionResult(
        type: PermissionType.location,
        isGranted: false,
        message: 'Error requesting location permission',
        error: e.toString(),
      );
    }
  }

  /// Request contacts permission
  static Future<PermissionResult> requestContacts() async {
    try {
      final status = await Permission.contacts.request();

      return PermissionResult(
        type: PermissionType.contacts,
        isGranted: status.isGranted,
        message: status.isGranted
          ? 'Contacts access granted! You can now easily share your music with friends.'
          : _getPermissionDeniedMessage('contacts', status),
      );
    } catch (e) {
      return PermissionResult(
        type: PermissionType.contacts,
        isGranted: false,
        message: 'Error requesting contacts permission',
        error: e.toString(),
      );
    }
  }

  /// Request storage permission for file operations
  static Future<PermissionResult> requestStorage() async {
    try {
      final status = await Permission.storage.request();

      return PermissionResult(
        type: PermissionType.storage,
        isGranted: status.isGranted,
        message: status.isGranted
          ? 'Storage access granted! You can now save and import music files.'
          : _getPermissionDeniedMessage('storage', status),
      );
    } catch (e) {
      return PermissionResult(
        type: PermissionType.storage,
        isGranted: false,
        message: 'Error requesting storage permission',
        error: e.toString(),
      );
    }
  }

  /// Request calendar permission
  static Future<PermissionResult> requestCalendar() async {
    try {
      final status = await Permission.calendarFullAccess.request();

      return PermissionResult(
        type: PermissionType.calendar,
        isGranted: status.isGranted,
        message: status.isGranted
          ? 'Calendar access granted! We can help you schedule creative sessions.'
          : _getPermissionDeniedMessage('calendar', status),
      );
    } catch (e) {
      return PermissionResult(
        type: PermissionType.calendar,
        isGranted: false,
        message: 'Error requesting calendar permission',
        error: e.toString(),
      );
    }
  }

  /// Request multiple permissions at once
  static Future<Map<PermissionType, PermissionResult>> requestMultiple(
    List<PermissionType> permissions,
  ) async {
    final results = <PermissionType, PermissionResult>{};

    for (final permission in permissions) {
      switch (permission) {
        case PermissionType.pushNotifications:
          results[permission] = await requestPushNotifications();
          break;
        case PermissionType.microphone:
          results[permission] = await requestMicrophone();
          break;
        case PermissionType.camera:
          results[permission] = await requestCamera();
          break;
        case PermissionType.photos:
          results[permission] = await requestPhotos();
          break;
        case PermissionType.location:
          results[permission] = await requestLocation();
          break;
        case PermissionType.contacts:
          results[permission] = await requestContacts();
          break;
        case PermissionType.storage:
          results[permission] = await requestStorage();
          break;
        case PermissionType.calendar:
          results[permission] = await requestCalendar();
          break;
      }

      // Small delay between permission requests for better UX
      await Future.delayed(const Duration(milliseconds: 300));
    }

    return results;
  }

  /// Check current status without requesting
  static Future<PermissionResult> checkPermissionStatus(PermissionType type) async {
    switch (type) {
      case PermissionType.pushNotifications:
        final permission = await OneSignal.Notifications.permission;
        return PermissionResult(
          type: type,
          isGranted: permission,
          message: 'Push notifications: ${permission ? 'Enabled' : 'Disabled'}',
        );

      case PermissionType.microphone:
        final status = await Permission.microphone.status;
        return PermissionResult(
          type: type,
          isGranted: status.isGranted,
          message: 'Microphone: ${status.name}',
        );

      case PermissionType.camera:
        final status = await Permission.camera.status;
        return PermissionResult(
          type: type,
          isGranted: status.isGranted,
          message: 'Camera: ${status.name}',
        );

      case PermissionType.photos:
        final status = await Permission.photos.status;
        return PermissionResult(
          type: type,
          isGranted: status.isGranted,
          message: 'Photos: ${status.name}',
        );

      case PermissionType.location:
        final status = await Permission.location.status;
        return PermissionResult(
          type: type,
          isGranted: status.isGranted,
          message: 'Location: ${status.name}',
        );

      case PermissionType.contacts:
        final status = await Permission.contacts.status;
        return PermissionResult(
          type: type,
          isGranted: status.isGranted,
          message: 'Contacts: ${status.name}',
        );

      case PermissionType.storage:
        final status = await Permission.storage.status;
        return PermissionResult(
          type: type,
          isGranted: status.isGranted,
          message: 'Storage: ${status.name}',
        );

      case PermissionType.calendar:
        final status = await Permission.calendarFullAccess.status;
        return PermissionResult(
          type: type,
          isGranted: status.isGranted,
          message: 'Calendar: ${status.name}',
        );
    }
  }

  /// Helper method to generate user-friendly messages for denied permissions
  static String _getPermissionDeniedMessage(String permissionName, PermissionStatus status) {
    switch (status) {
      case PermissionStatus.denied:
        return '$permissionName permission was denied. You can enable it later in Settings.';
      case PermissionStatus.permanentlyDenied:
        return '$permissionName permission is permanently denied. Please enable it in your device Settings.';
      case PermissionStatus.restricted:
        return '$permissionName permission is restricted on this device.';
      default:
        return '$permissionName permission is not available.';
    }
  }

  /// Open device settings for manually enabling permissions
  static Future<bool> openDeviceSettings() async {
    return await openAppSettings();
  }
}


/// Result class for permission requests
class PermissionResult {
  final PermissionType type;
  final bool isGranted;
  final String message;
  final String? error;
  final DateTime requestedAt;

  PermissionResult({
    required this.type,
    required this.isGranted,
    required this.message,
    this.error,
  }) : requestedAt = DateTime.now();

  @override
  String toString() {
    return 'PermissionResult(type: $type, granted: $isGranted, message: $message)';
  }
}
