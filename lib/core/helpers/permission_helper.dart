/// A helper class for managing and requesting various device permissions.
///
/// This class provides static methods to request and check the status of
/// different permissions such as camera, location, storage, microphone,
/// and notifications. It also includes a method to open the app settings.
///
/// Usage:
/// - Call the respective request methods to ask for specific permissions.
/// - Use [checkPermissionStatus] to verify if a permission is granted.
/// - Use [openAppSettings] to direct users to the app's permission settings.
library;

import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  static Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  static Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }
    return status.isGranted;
  }

  static Future<bool> checkPermissionStatus(Permission permission) async {
    return await permission.status.isGranted;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
