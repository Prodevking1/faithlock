import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import '../posthog_service.dart';

/// Module for in-app surveys and feedback
class SurveysModule {
  final PostHogService _postHogService;
  bool _isInitialized = false;
  final Map<String, Map<String, dynamic>> _activeSurveys = {};
  final Map<String, DateTime> _surveyStartTimes = {};
  final Map<String, List<Map<String, dynamic>>> _surveyResponses = {};

  SurveysModule(this._postHogService);

  /// Initialize the surveys module
  Future<void> init() async {
    try {
      _isInitialized = true;
      debugPrint('SurveysModule: Initialized successfully');
    } catch (e) {
      debugPrint('SurveysModule: Failed to initialize - $e');
      rethrow;
    }
  }

  /// Shutdown the module
  Future<void> shutdown() async {
    try {
      _isInitialized = false;
      _activeSurveys.clear();
      _surveyStartTimes.clear();
      _surveyResponses.clear();
      debugPrint('SurveysModule: Shutdown successfully');
    } catch (e) {
      debugPrint('SurveysModule: Failed to shutdown - $e');
    }
  }

  /// Reset the module
  Future<void> reset() async {
    try {
      _activeSurveys.clear();
      _surveyStartTimes.clear();
      _surveyResponses.clear();
      debugPrint('SurveysModule: Reset successfully');
    } catch (e) {
      debugPrint('SurveysModule: Failed to reset - $e');
    }
  }

  /// Start a survey session
  Future<void> startSurvey({
    required String surveyId,
    required String surveyName,
    String? surveyType,
    Map<String, dynamic>? surveyMetadata,
  }) async {
    if (!_isInitialized) {
      debugPrint('SurveysModule: Cannot start survey - module not initialized');
      return;
    }

    try {
      _activeSurveys[surveyId] = {
        'survey_id': surveyId,
        'survey_name': surveyName,
        'survey_type': surveyType ?? 'general',
        'metadata': surveyMetadata ?? {},
      };
      _surveyStartTimes[surveyId] = DateTime.now();
      _surveyResponses[surveyId] = [];

      await Posthog().capture(
        eventName: 'survey_started',
        properties: {
          'survey_id': surveyId,
          'survey_name': surveyName,
          'survey_type': surveyType ?? 'general',
          'metadata': surveyMetadata ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('SurveysModule: Survey started - $surveyName');
    } catch (e) {
      debugPrint('SurveysModule: Failed to start survey - $e');
    }
  }

  /// Record survey question response
  Future<void> recordResponse({
    required String surveyId,
    required String questionId,
    required String questionText,
    required dynamic response,
    String? questionType,
    Map<String, dynamic>? responseMetadata,
  }) async {
    if (!_isInitialized) {
      debugPrint('SurveysModule: Cannot record response - module not initialized');
      return;
    }

    if (!_activeSurveys.containsKey(surveyId)) {
      debugPrint('SurveysModule: Survey $surveyId not active');
      return;
    }

    try {
      final responseData = {
        'question_id': questionId,
        'question_text': questionText,
        'question_type': questionType ?? 'text',
        'response': response,
        'response_metadata': responseMetadata ?? {},
        'response_time': DateTime.now().toIso8601String(),
      };

      _surveyResponses[surveyId]!.add(responseData);

      await Posthog().capture(
        eventName: 'survey_response_recorded',
        properties: {
          'survey_id': surveyId,
          'survey_data': _activeSurveys[surveyId] ?? {},
          ...responseData,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('SurveysModule: Response recorded - $questionId');
    } catch (e) {
      debugPrint('SurveysModule: Failed to record response - $e');
    }
  }

  /// Complete survey
  Future<void> completeSurvey({
    required String surveyId,
    Map<String, dynamic>? completionMetadata,
  }) async {
    if (!_isInitialized) {
      debugPrint('SurveysModule: Cannot complete survey - module not initialized');
      return;
    }

    if (!_activeSurveys.containsKey(surveyId)) {
      debugPrint('SurveysModule: Survey $surveyId not active');
      return;
    }

    try {
      final startTime = _surveyStartTimes[surveyId];
      final responses = _surveyResponses[surveyId] ?? [];

      await Posthog().capture(
        eventName: 'survey_completed',
        properties: {
          'survey_id': surveyId,
          'survey_data': _activeSurveys[surveyId] ?? {},
          'total_responses': responses.length,
          if (startTime != null)
            'completion_time': DateTime.now().difference(startTime).inSeconds,
          'responses': responses,
          'completion_metadata': completionMetadata ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Clean up survey tracking
      _activeSurveys.remove(surveyId);
      _surveyStartTimes.remove(surveyId);
      _surveyResponses.remove(surveyId);

      debugPrint('SurveysModule: Survey completed - $surveyId');
    } catch (e) {
      debugPrint('SurveysModule: Failed to complete survey - $e');
    }
  }

  /// Abandon survey
  Future<void> abandonSurvey({
    required String surveyId,
    String? abandonmentReason,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('SurveysModule: Cannot abandon survey - module not initialized');
      return;
    }

    if (!_activeSurveys.containsKey(surveyId)) {
      debugPrint('SurveysModule: Survey $surveyId not active');
      return;
    }

    try {
      final startTime = _surveyStartTimes[surveyId];
      final responses = _surveyResponses[surveyId] ?? [];

      await Posthog().capture(
        eventName: 'survey_abandoned',
        properties: {
          'survey_id': surveyId,
          'survey_data': _activeSurveys[surveyId] ?? {},
          'abandonment_reason': abandonmentReason ?? '',
          'partial_responses': responses.length,
          if (startTime != null)
            'time_in_survey': DateTime.now().difference(startTime).inSeconds,
          'partial_response_data': responses,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      // Clean up survey tracking
      _activeSurveys.remove(surveyId);
      _surveyStartTimes.remove(surveyId);
      _surveyResponses.remove(surveyId);

      debugPrint('SurveysModule: Survey abandoned - $surveyId');
    } catch (e) {
      debugPrint('SurveysModule: Failed to abandon survey - $e');
    }
  }

  /// Track survey impression (shown to user)
  Future<void> trackSurveyImpression({
    required String surveyId,
    required String surveyName,
    String? displayLocation,
    String? displayTrigger,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('SurveysModule: Cannot track impression - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'survey_impression',
        properties: {
          'survey_id': surveyId,
          'survey_name': surveyName,
          'display_location': displayLocation ?? 'Unknown',
          'display_trigger': displayTrigger ?? 'Unknown',
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('SurveysModule: Survey impression tracked - $surveyName');
    } catch (e) {
      debugPrint('SurveysModule: Failed to track survey impression - $e');
    }
  }

  /// Track survey dismissal (user closed without starting)
  Future<void> trackSurveyDismissal({
    required String surveyId,
    required String surveyName,
    String? dismissalReason,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('SurveysModule: Cannot track dismissal - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'survey_dismissed',
        properties: {
          'survey_id': surveyId,
          'survey_name': surveyName,
          'dismissal_reason': dismissalReason ?? 'Unknown',
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('SurveysModule: Survey dismissal tracked - $surveyId');
    } catch (e) {
      debugPrint('SurveysModule: Failed to track survey dismissal - $e');
    }
  }

  /// Track NPS (Net Promoter Score) response
  Future<void> trackNPSResponse({
    required String surveyId,
    required int score, // 0-10
    String? feedback,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('SurveysModule: Cannot track NPS - module not initialized');
      return;
    }

    if (score < 0 || score > 10) {
      debugPrint('SurveysModule: Invalid NPS score - must be 0-10');
      return;
    }

    try {
      String category;
      if (score <= 6) {
        category = 'detractor';
      } else if (score <= 8) {
        category = 'passive';
      } else {
        category = 'promoter';
      }

      await Posthog().capture(
        eventName: 'nps_response',
        properties: {
          'survey_id': surveyId,
          'nps_score': score,
          'nps_category': category,
          'feedback': feedback ?? '',
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('SurveysModule: NPS response tracked - Score: $score ($category)');
    } catch (e) {
      debugPrint('SurveysModule: Failed to track NPS response - $e');
    }
  }

  /// Track CSAT (Customer Satisfaction) response
  Future<void> trackCSATResponse({
    required String surveyId,
    required int rating, // 1-5 typically
    String? feedback,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('SurveysModule: Cannot track CSAT - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'csat_response',
        properties: {
          'survey_id': surveyId,
          'csat_rating': rating,
          'feedback': feedback ?? '',
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('SurveysModule: CSAT response tracked - Rating: $rating');
    } catch (e) {
      debugPrint('SurveysModule: Failed to track CSAT response - $e');
    }
  }

  /// Track feedback submission
  Future<void> trackFeedback({
    required String feedbackType,
    required String feedback,
    String? category,
    int? rating,
    String? contactInfo,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('SurveysModule: Cannot track feedback - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'feedback_submitted',
        properties: {
          'feedback_type': feedbackType,
          'feedback_text': feedback,
          'feedback_category': category ?? 'Unknown',
          'rating': rating ?? 0,
          'contact_info': contactInfo ?? '',
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('SurveysModule: Feedback tracked - $feedbackType');
    } catch (e) {
      debugPrint('SurveysModule: Failed to track feedback - $e');
    }
  }

  /// Get active surveys
  Map<String, Map<String, dynamic>> get activeSurveys => Map.unmodifiable(_activeSurveys);

  /// Check if survey is active
  bool isSurveyActive(String surveyId) => _activeSurveys.containsKey(surveyId);

  /// Get survey responses for a specific survey
  List<Map<String, dynamic>>? getSurveyResponses(String surveyId) {
    return _surveyResponses[surveyId] != null
        ? List.unmodifiable(_surveyResponses[surveyId]!)
        : null;
  }

  /// Get survey duration for active survey
  Duration? getSurveyDuration(String surveyId) {
    final startTime = _surveyStartTimes[surveyId];
    return startTime != null ? DateTime.now().difference(startTime) : null;
  }
}
