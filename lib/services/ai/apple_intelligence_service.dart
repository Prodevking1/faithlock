import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Validation result from Apple Intelligence
class ValidationResult {
  final bool isValid;
  final String feedback;
  final double score;

  ValidationResult({
    required this.isValid,
    required this.feedback,
    required this.score,
  });

  factory ValidationResult.fromMap(Map<dynamic, dynamic> map) {
    return ValidationResult(
      isValid: map['isValid'] as bool,
      feedback: map['feedback'] as String,
      score: (map['score'] as num).toDouble(),
    );
  }
}

/// Flutter service to communicate with Apple Intelligence
class AppleIntelligenceService {
  static const MethodChannel _channel =
      MethodChannel('com.faithlock/apple_intelligence');

  /// Check if Apple Intelligence is available on this device
  /// NOTE: Foundation Models framework not yet available - always returns false
  static Future<bool> isAvailable() async {
    // Foundation Models framework requires iOS 26.0+ which doesn't exist yet
    // Will be enabled when Apple releases it publicly
    return false;

    /* Uncomment when Foundation Models is available:
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ Error checking Apple Intelligence availability: $e');
      return false;
    }
    */
  }

  /// Validate meditation response with Apple Intelligence
  Future<ValidationResult> validateMeditationResponse({
    required String verseText,
    required String verseReference,
    required String userResponse,
    String? userGoals,
    String? userStruggles,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'validateMeditation',
        {
          'verseText': verseText,
          'verseReference': verseReference,
          'userResponse': userResponse,
          if (userGoals != null) 'userGoals': userGoals,
          if (userStruggles != null) 'userStruggles': userStruggles,
        },
      );

      if (result == null) {
        throw Exception('No result from Apple Intelligence');
      }

      return ValidationResult.fromMap(result);
    } catch (e) {
      debugPrint('❌ Apple Intelligence validation error: $e');
      rethrow;
    }
  }
}
