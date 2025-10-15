import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import '../posthog_service.dart';

/// Module for session replay functionality
class SessionRecordingModule {
  final PostHogService _postHogService;
  bool _isInitialized = false;
  bool _recordingEnabled = false;
  String? _currentSessionId;
  DateTime? _sessionStartTime;
  int _eventCount = 0;

  SessionRecordingModule(this._postHogService);

  /// Initialize the session recording module
  Future<void> init({bool enableRecording = true}) async {
    try {
      _recordingEnabled = enableRecording;
      _currentSessionId = _generateSessionId();
      _sessionStartTime = DateTime.now();
      _eventCount = 0;
      _isInitialized = true;

      if (_recordingEnabled) {
        await _startSessionRecording();
      }

      debugPrint('SessionRecordingModule: Initialized successfully (recording: $_recordingEnabled)');
    } catch (e) {
      debugPrint('SessionRecordingModule: Failed to initialize - $e');
      rethrow;
    }
  }

  /// Shutdown the module
  Future<void> shutdown() async {
    try {
      if (_recordingEnabled && _currentSessionId != null) {
        await _endSessionRecording();
      }
      _isInitialized = false;
      debugPrint('SessionRecordingModule: Shutdown successfully');
    } catch (e) {
      debugPrint('SessionRecordingModule: Failed to shutdown - $e');
    }
  }

  /// Reset the module
  Future<void> reset() async {
    try {
      if (_recordingEnabled && _currentSessionId != null) {
        await _endSessionRecording();
      }

      _currentSessionId = _generateSessionId();
      _sessionStartTime = DateTime.now();
      _eventCount = 0;

      if (_recordingEnabled) {
        await _startSessionRecording();
      }

      debugPrint('SessionRecordingModule: Reset successfully');
    } catch (e) {
      debugPrint('SessionRecordingModule: Failed to reset - $e');
    }
  }

  /// Start session recording
  Future<void> startRecording() async {
    if (!_isInitialized) {
      debugPrint('SessionRecordingModule: Cannot start recording - module not initialized');
      return;
    }

    try {
      if (!_recordingEnabled) {
        _recordingEnabled = true;
        _currentSessionId = _generateSessionId();
        _sessionStartTime = DateTime.now();
        _eventCount = 0;
        await _startSessionRecording();
      }
      debugPrint('SessionRecordingModule: Recording started');
    } catch (e) {
      debugPrint('SessionRecordingModule: Failed to start recording - $e');
    }
  }

  /// Stop session recording
  Future<void> stopRecording() async {
    if (!_isInitialized) {
      debugPrint('SessionRecordingModule: Cannot stop recording - module not initialized');
      return;
    }

    try {
      if (_recordingEnabled && _currentSessionId != null) {
        await _endSessionRecording();
        _recordingEnabled = false;
      }
      debugPrint('SessionRecordingModule: Recording stopped');
    } catch (e) {
      debugPrint('SessionRecordingModule: Failed to stop recording - $e');
    }
  }

  /// Record a custom event in the session
  Future<void> recordEvent({
    required String eventType,
    required Map<String, dynamic> data,
  }) async {
    if (!_isInitialized || !_recordingEnabled) {
      debugPrint('SessionRecordingModule: Cannot record event - recording not active');
      return;
    }

    try {
      _eventCount++;

      await Posthog().capture(
        eventName: 'session_event_recorded',
        properties: {
          'session_id': _currentSessionId ?? '',
          'event_type': eventType,
          'event_data': data,
          'event_sequence': _eventCount,
          'session_duration': _getSessionDuration(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('SessionRecordingModule: Event recorded - $eventType');
    } catch (e) {
      debugPrint('SessionRecordingModule: Failed to record event - $e');
    }
  }

  /// Record user interaction
  Future<void> recordInteraction({
    required String interactionType,
    required String elementId,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized || !_recordingEnabled) {
      debugPrint('SessionRecordingModule: Cannot record interaction - recording not active');
      return;
    }

    try {
      await recordEvent(
        eventType: 'user_interaction',
        data: {
          'interaction_type': interactionType,
          'element_id': elementId,
          'metadata': metadata ?? {},
        },
      );

      debugPrint('SessionRecordingModule: Interaction recorded - $interactionType on $elementId');
    } catch (e) {
      debugPrint('SessionRecordingModule: Failed to record interaction - $e');
    }
  }

  /// Record screen state change
  Future<void> recordStateChange({
    required String stateType,
    required Map<String, dynamic> beforeState,
    required Map<String, dynamic> afterState,
  }) async {
    if (!_isInitialized || !_recordingEnabled) {
      debugPrint('SessionRecordingModule: Cannot record state change - recording not active');
      return;
    }

    try {
      await recordEvent(
        eventType: 'state_change',
        data: {
          'state_type': stateType,
          'before_state': beforeState,
          'after_state': afterState,
        },
      );

      debugPrint('SessionRecordingModule: State change recorded - $stateType');
    } catch (e) {
      debugPrint('SessionRecordingModule: Failed to record state change - $e');
    }
  }

  /// Record error occurrence in session
  Future<void> recordError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    if (!_isInitialized || !_recordingEnabled) {
      debugPrint('SessionRecordingModule: Cannot record error - recording not active');
      return;
    }

    try {
      await recordEvent(
        eventType: 'error_occurred',
        data: {
          'error_type': errorType,
          'error_message': errorMessage,
          'stack_trace': stackTrace,
          'context': context ?? {},
        },
      );

      debugPrint('SessionRecordingModule: Error recorded - $errorType');
    } catch (e) {
      debugPrint('SessionRecordingModule: Failed to record error - $e');
    }
  }

  /// Add session tags for categorization
  Future<void> addSessionTags(List<String> tags) async {
    if (!_isInitialized || !_recordingEnabled) {
      debugPrint('SessionRecordingModule: Cannot add tags - recording not active');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'session_tags_added',
        properties: {
          'session_id': _currentSessionId ?? '',
          'tags': tags,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('SessionRecordingModule: Tags added to session - ${tags.join(", ")}');
    } catch (e) {
      debugPrint('SessionRecordingModule: Failed to add session tags - $e');
    }
  }

  /// Get current session information
  Map<String, dynamic>? get currentSession {
    if (!_recordingEnabled || _currentSessionId == null) {
      return null;
    }

    return {
      'session_id': _currentSessionId,
      'start_time': _sessionStartTime?.toIso8601String(),
      'duration_seconds': _getSessionDuration(),
      'event_count': _eventCount,
      'recording_enabled': _recordingEnabled,
    };
  }

  /// Check if recording is currently active
  bool get isRecording => _recordingEnabled && _currentSessionId != null;

  /// Get current session ID
  String? get sessionId => _currentSessionId;

  /// Private method to start session recording
  Future<void> _startSessionRecording() async {
    try {
      await Posthog().capture(
        eventName: 'session_recording_started',
        properties: {
          'session_id': _currentSessionId ?? '',
          'start_time': _sessionStartTime?.toIso8601String() ?? 'Unknown',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('SessionRecordingModule: Failed to start session recording - $e');
    }
  }

  /// Private method to end session recording
  Future<void> _endSessionRecording() async {
    try {
      await Posthog().capture(
        eventName: 'session_recording_ended',
        properties: {
          'session_id': _currentSessionId ?? '',
          'start_time': _sessionStartTime?.toIso8601String() ?? 'Unknown',
          'end_time': DateTime.now().toIso8601String(),
          'duration_seconds': _getSessionDuration(),
          'event_count': _eventCount,
        },
      );
    } catch (e) {
      debugPrint('SessionRecordingModule: Failed to end session recording - $e');
    }
  }

  /// Generate unique session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }

  /// Generate random string
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[DateTime.now().microsecond % chars.length]).join();
  }

  /// Get session duration in seconds
  int _getSessionDuration() {
    if (_sessionStartTime == null) return 0;
    return DateTime.now().difference(_sessionStartTime!).inSeconds;
  }
}
