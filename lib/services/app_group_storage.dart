import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service to access App Group shared storage (iOS only)
/// This allows communication between the main app and extensions (Shield, DeviceActivityMonitor)
class AppGroupStorage {
  static const String appGroupId = 'group.com.appbiz.faithlock';
  static const MethodChannel _channel = MethodChannel('faithlock/screentime');

  /// Check if user clicked "Start Prayer" from Shield
  /// Reads from App Group shared storage via platform channel
  static Future<bool> shouldNavigateToPrayer() async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _channel.invokeMethod<bool>('shouldNavigateToPrayer');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ Error reading prayer flag from App Group: $e');
      return false;
    }
  }

  /// Clear the prayer navigation flag
  /// Clears from App Group shared storage via platform channel
  static Future<void> clearPrayerFlag() async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('clearPrayerFlag');
      debugPrint('✅ Prayer flag cleared from App Group');
    } catch (e) {
      debugPrint('❌ Error clearing prayer flag from App Group: $e');
    }
  }

  /// Get the time when prayer was requested (deprecated - not used)
  @deprecated
  static Future<DateTime?> getPrayerRequestTime() async {
    return null;
  }
}
