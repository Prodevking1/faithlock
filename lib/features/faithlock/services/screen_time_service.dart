import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:faithlock/features/faithlock/models/export.dart';

/// Screen Time Service
/// Manages iOS Screen Time API integration for app blocking
/// Uses Method Channel to communicate with native iOS code
class ScreenTimeService {
  static const MethodChannel _channel = MethodChannel('faithlock/screentime');

  // Singleton pattern
  static final ScreenTimeService _instance = ScreenTimeService._internal();
  factory ScreenTimeService() => _instance;
  ScreenTimeService._internal();

  /// Check if Family Controls authorization is granted
  Future<bool> isAuthorized() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAuthorized');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking authorization: $e');
      return false;
    }
  }

  /// Request Family Controls authorization
  /// User will see iOS system dialog
  Future<bool> requestAuthorization() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestAuthorization');
      return result ?? false;
    } catch (e) {
      debugPrint('Error requesting authorization: $e');
      return false;
    }
  }

  /// Present Family Activity Picker
  /// Allows user to select apps to block
  Future<void> presentAppPicker() async {
    try {
      await _channel.invokeMethod('presentAppPicker');
    } catch (e) {
      debugPrint('Error presenting app picker: $e');
      throw Exception('Failed to present app picker: $e');
    }
  }

  /// Check if user has selected apps to block
  Future<bool> hasSelectedApps() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasSelectedApps');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking selected apps: $e');
      return false;
    }
  }

  /// Get list of selected apps with details
  /// Returns a list of maps containing app bundle ID, name, and count
  Future<List<Map<String, dynamic>>> getSelectedApps() async {
    try {
      final result = await _channel.invokeMethod<List>('getSelectedApps');
      if (result == null) return [];

      return result.map((app) => Map<String, dynamic>.from(app as Map)).toList();
    } catch (e) {
      debugPrint('Error getting selected apps: $e');
      return [];
    }
  }

  /// Get count of selected apps
  Future<int> getSelectedAppsCount() async {
    try {
      final apps = await getSelectedApps();
      int totalCount = 0;

      for (var item in apps) {
        final count = item['count'] as int? ?? 0;
        totalCount += count;
      }

      return totalCount;
    } catch (e) {
      debugPrint('Error getting selected apps count: $e');
      return 0;
    }
  }

  /// Start blocking apps for a schedule
  Future<void> startBlocking({
    required LockSchedule schedule,
  }) async {
    try {
      final isAuth = await isAuthorized();
      if (!isAuth) {
        throw Exception('Screen Time authorization not granted');
      }

      // Calculate duration until end time
      final now = DateTime.now();
      final endDateTime = _calculateEndDateTime(schedule.endTime);
      final durationSeconds = endDateTime.difference(now).inSeconds;

      // Start monitoring with native code
      await _channel.invokeMethod('startBlocking', {
        'scheduleId': schedule.id,
        'scheduleName': schedule.name,
        'durationSeconds': durationSeconds,
      });
    } catch (e) {
      debugPrint('Error starting blocking: $e');
      throw Exception('Failed to start blocking: $e');
    }
  }

  /// Stop blocking apps immediately
  Future<void> stopBlocking() async {
    try {
      await _channel.invokeMethod('stopBlocking');
    } catch (e) {
      debugPrint('Error stopping blocking: $e');
      throw Exception('Failed to stop blocking: $e');
    }
  }

  /// Check if currently monitoring/blocking
  Future<bool> isMonitoring() async {
    try {
      final result = await _channel.invokeMethod<bool>('isMonitoring');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking monitoring status: $e');
      return false;
    }
  }

  /// Calculate end DateTime from TimeOfDay
  DateTime _calculateEndDateTime(TimeOfDay endTime) {
    final now = DateTime.now();
    var endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
    );

    // If end time is before current time, it means next day
    if (endDateTime.isBefore(now)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    return endDateTime;
  }

  /// Get authorization status as string for UI
  Future<String> getAuthorizationStatusText() async {
    try {
      final result = await _channel.invokeMethod<String>('getAuthorizationStatus');
      return result ?? 'Unknown';
    } catch (e) {
      debugPrint('Error getting authorization status: $e');
      return 'Error';
    }
  }

  /// Check if schedule should trigger blocking now
  bool shouldStartBlocking(LockSchedule schedule) {
    if (!schedule.isEnabled) return false;
    return schedule.isActiveNow();
  }

  /// Setup DeviceActivity schedules from onboarding data
  /// Schedules should be in format: [{name, startHour, startMinute, endHour, endMinute, enabled}]
  Future<void> setupSchedules(List<Map<String, dynamic>> schedules) async {
    try {
      final isAuth = await isAuthorized();
      if (!isAuth) {
        throw Exception('Screen Time authorization not granted');
      }

      await _channel.invokeMethod('setupSchedules', schedules);
      debugPrint('✅ Successfully setup ${schedules.length} schedules');
    } catch (e) {
      debugPrint('Error setting up schedules: $e');
      throw Exception('Failed to setup schedules: $e');
    }
  }

  /// Remove all DeviceActivity schedules
  Future<void> removeAllSchedules() async {
    try {
      await _channel.invokeMethod('removeAllSchedules');
      debugPrint('✅ Removed all schedules');
    } catch (e) {
      debugPrint('Error removing schedules: $e');
      throw Exception('Failed to remove schedules: $e');
    }
  }

  /// Apply blocking immediately (used when apps selected during active schedule)
  /// This is a workaround while waiting for DeviceActivityMonitor to activate
  Future<void> applyBlockingNow() async {
    try {
      await _channel.invokeMethod('applyBlockingNow');
      debugPrint('✅ Applied blocking immediately');
    } catch (e) {
      debugPrint('❌ Error applying blocking: $e');
      rethrow;
    }
  }

  /// Unlock apps after successful prayer completion
  /// Stops current schedules and restarts them for tomorrow
  Future<void> temporaryUnlock({int durationMinutes = 0}) async {
    try {
      await _channel.invokeMethod('temporaryUnlock', {
        'durationMinutes': durationMinutes,
      });
    } catch (e) {
      debugPrint('❌ Failed to unlock apps: $e');
      throw Exception('Failed to unlock apps: $e');
    }
  }

  /// Debug shield status - prints comprehensive debugging information
  /// Useful for troubleshooting shield configuration issues
  /// Check Xcode console for detailed output
  Future<void> debugShieldStatus() async {
    try {
      await _channel.invokeMethod('debugShieldStatus');
      debugPrint('✅ Shield status debug info printed to Xcode console');
    } catch (e) {
      debugPrint('❌ Error debugging shield status: $e');
      rethrow;
    }
  }

  /// Check if DeviceActivityMonitor is working
  /// Returns diagnostic info about monitor events
  Future<Map<String, dynamic>> checkMonitorStatus() async {
    try {
      final result = await _channel.invokeMethod<Map>('checkMonitorStatus');
      if (result == null) {
        return {
          'isWorking': false,
          'message': 'No monitor data available',
        };
      }

      // Add extension init check
      final extensionInit = result['extensionLastInit'] as String?;
      final extensionInitDate = result['extensionInitDate'] as String?;

      if (extensionInit != null) {
        debugPrint('✅ Extension initialized: $extensionInit at $extensionInitDate');
      } else {
        debugPrint('⚠️ Extension never initialized - may not be loaded by iOS');
      }

      return Map<String, dynamic>.from(result);
    } catch (e) {
      debugPrint('❌ Error checking monitor status: $e');
      return {
        'isWorking': false,
        'error': e.toString(),
      };
    }
  }

  /// Get monitor event history
  /// Returns list of recent monitor events for debugging
  Future<List<Map<String, dynamic>>> getMonitorEventHistory() async {
    try {
      final result = await _channel.invokeMethod<List>('getMonitorEventHistory');
      if (result == null) return [];
      return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting monitor history: $e');
      return [];
    }
  }

  /// Create a test schedule that starts in 3 minutes, lasts 15 minutes (iOS minimum)
  /// Useful for quickly testing if DeviceActivityMonitor is working
  Future<void> createTestSchedule() async {
    try {
      await _channel.invokeMethod('createTestSchedule');
      debugPrint('✅ Test schedule created - will start in 3 minutes, last 15 minutes');
    } catch (e) {
      debugPrint('❌ Error creating test schedule: $e');
      throw Exception('Failed to create test schedule: $e');
    }
  }

  /// Check if a schedule ended flag is set (from DeviceActivityMonitor)
  Future<String?> checkScheduleEnded() async {
    try {
      final result = await _channel.invokeMethod<String>('checkScheduleEnded');
      return result;
    } catch (e) {
      debugPrint('❌ Error checking schedule ended: $e');
      return null;
    }
  }

  /// Clear schedule ended flag
  Future<void> clearScheduleEndedFlag() async {
    try {
      await _channel.invokeMethod('clearScheduleEndedFlag');
    } catch (e) {
      debugPrint('❌ Error clearing schedule ended flag: $e');
    }
  }

  void dispose() {
    // Cleanup if needed
  }
}

