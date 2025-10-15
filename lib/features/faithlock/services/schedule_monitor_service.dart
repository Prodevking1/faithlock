import 'dart:async';
import 'package:faithlock/features/faithlock/services/lock_service.dart';
import 'package:flutter/foundation.dart';

/// Background service that monitors and activates lock schedules
class ScheduleMonitorService {
  static final ScheduleMonitorService _instance =
      ScheduleMonitorService._internal();

  factory ScheduleMonitorService() => _instance;

  ScheduleMonitorService._internal();

  final LockService _lockService = LockService();
  Timer? _monitorTimer;
  bool _isMonitoring = false;

  // Check interval - every minute
  static const Duration _checkInterval = Duration(minutes: 1);

  /// Start monitoring schedules
  void startMonitoring() {
    if (_isMonitoring) {
      debugPrint('⚠️ Schedule monitoring already running');
      return;
    }

    _isMonitoring = true;
    debugPrint('✅ Started schedule monitoring');

    // Check immediately
    _checkSchedules();

    // Then check every minute
    _monitorTimer = Timer.periodic(_checkInterval, (_) {
      _checkSchedules();
    });
  }

  /// Stop monitoring schedules
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _monitorTimer?.cancel();
    _monitorTimer = null;
    _isMonitoring = false;
    debugPrint('⏸️ Stopped schedule monitoring');
  }

  /// Manually check and activate schedules
  Future<void> checkNow() async {
    await _checkSchedules();
  }

  /// Internal method to check and activate schedules
  Future<void> _checkSchedules() async {
    try {
      final wasActivated = await _lockService.checkAndActivateSchedules();

      if (wasActivated) {
        debugPrint('🔒 Schedule activated - Screen Time blocking started');
      }
    } catch (e) {
      debugPrint('❌ Error checking schedules: $e');
    }
  }

  /// Check if monitoring is active
  bool get isMonitoring => _isMonitoring;
}
