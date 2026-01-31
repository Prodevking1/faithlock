import 'dart:convert';

import 'package:faithlock/config/env.dart';
import 'package:faithlock/services/ai/apple_intelligence_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Validation result
class ValidationResult {
  final bool isValid;
  final String feedback;
  final double score; // 0.0 to 1.0
  final String source; // 'apple' or 'openai' or 'fallback'

  ValidationResult({
    required this.isValid,
    required this.feedback,
    required this.score,
    this.source = 'fallback',
  });
}

/// Hybrid AI service: OpenAI (primary) → Apple Intelligence (iOS 26+ fallback)
class MeditationValidatorService {
  static final MeditationValidatorService _instance =
      MeditationValidatorService._internal();
  factory MeditationValidatorService() => _instance;
  MeditationValidatorService._internal();

  final AppleIntelligenceService _appleAI = AppleIntelligenceService();
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// Validate meditation response with AI
  ///
  /// 2-tier validation strategy:
  /// 1. OpenAI (cloud, paid, reliable, all devices)
  /// 2. Apple Intelligence (on-device, free, iOS 26+ fallback when available)
  ///
  /// Takes into account:
  /// - The verse content and meaning
  /// - User's personal reflection
  /// - User's goals and struggles (optional)
  Future<ValidationResult> validateMeditationResponse({
    required String verseText,
    required String verseReference,
    required String userResponse,
    String? userGoals,
    String? userStruggles,
  }) async {
    // Try OpenAI first (cloud, reliable, always works)
    try {
      debugPrint('🤖 Using OpenAI for validation');
      return await _validateWithOpenAI(
        verseText: verseText,
        verseReference: verseReference,
        userResponse: userResponse,
        userGoals: userGoals,
        userStruggles: userStruggles,
      );
    } catch (e) {
      debugPrint('⚠️ OpenAI failed, trying Apple Intelligence: $e');
      // Continue to Apple Intelligence fallback
    }

    // Try Apple Intelligence as fallback (on-device, free, iOS 26+ only)
    if (await AppleIntelligenceService.isAvailable()) {
      try {
        debugPrint('🍎 Using Apple Intelligence for validation');
        final result = await _appleAI.validateMeditationResponse(
          verseText: verseText,
          verseReference: verseReference,
          userResponse: userResponse,
          userGoals: userGoals,
          userStruggles: userStruggles,
        );

        return ValidationResult(
          isValid: result.isValid,
          feedback: result.feedback,
          score: result.score,
          source: 'apple',
        );
      } catch (e) {
        debugPrint('⚠️ Apple Intelligence failed: $e');
        // Continue to basic fallback
      }
    }

    // Last resort: basic validation
    return _fallbackValidation(userResponse);
  }

  /// Validate with OpenAI (fallback)
  Future<ValidationResult> _validateWithOpenAI({
    required String verseText,
    required String verseReference,
    required String userResponse,
    String? userGoals,
    String? userStruggles,
  }) async {
    try {
      debugPrint('🤖 Using OpenAI for validation');

      // Build context-aware prompt
      final prompt = _buildValidationPrompt(
        verseText: verseText,
        verseReference: verseReference,
        userResponse: userResponse,
        userGoals: userGoals,
        userStruggles: userStruggles,
      );

      // Call OpenAI API
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Env.openAiApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': _getSystemPrompt()},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;

        final result = _parseAIResponse(aiResponse);
        return ValidationResult(
          isValid: result.isValid,
          feedback: result.feedback,
          score: result.score,
          source: 'openai',
        );
      } else {
        debugPrint(
            '❌ OpenAI validation failed: ${response.statusCode} - ${response.body}');
        return _fallbackValidation(userResponse);
      }
    } catch (e) {
      debugPrint('❌ OpenAI validation error: $e');
      return _fallbackValidation(userResponse);
    }
  }

  /// Build validation prompt with context
  String _buildValidationPrompt({
    required String verseText,
    required String verseReference,
    required String userResponse,
    String? userGoals,
    String? userStruggles,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('Verse: "$verseText" ($verseReference)');
    buffer.writeln();
    buffer.writeln('User\'s reflection: "$userResponse"');

    if (userGoals != null && userGoals.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('User\'s goals: $userGoals');
    }

    if (userStruggles != null && userStruggles.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('User\'s struggles: $userStruggles');
    }

    return buffer.toString();
  }

  /// System prompt for AI validator
  String _getSystemPrompt() {
    return ''' You are a kind and encouraging spiritual mentor validating meditation reflections.

Your task: Decide whether the user's message shows ANY sincere engagement with the verse, spirituality, faith, meaning, inner reflection, or personal growth.

Be VERY GENEROUS, but do NOT accept completely unrelated content.

✅ ALWAYS ACCEPT as VALID if the message includes AT LEAST ONE of the following:
- A personal feeling or emotion (peace, hope, struggle, gratitude, fear, love, etc.)
- A spiritual or faith-related idea (God, prayer, trust, patience, forgiveness, guidance, etc.)
- An attempt at self-reflection or personal growth (even vague)
- A short reaction showing meaning ("this speaks to me", "amen", "needed this", "beautiful")
- A simple intention ("I want to improve", "help me pray", "trust more")

❌ REJECT as INVALID ONLY if the message is:
- Completely unrelated to spirituality, reflection, meaning, or faith
- Random words, spam, numbers, or test text
- Clearly unserious or meaningless ("aaaa", "lol", "test", "123")
- Profanity or trolling

IMPORTANT:
- Short responses ARE OKAY
- Weak or vague reflections are STILL VALID if sincere
- Require at least minimal relevance (emotion, meaning, faith, or reflection)

Response format (JSON only):
{
  "valid": true/false,
  "score": 0.7-1.0,
  "feedback": "One short, warm, encouraging sentence"
}

Scoring rules:
- 0.7–0.8 → very short or simple but sincere
- 0.8–0.9 → clear personal connection
- 1.0 → deep or thoughtful reflection

If VALID:
- Always encourage (e.g. "Beautiful reflection.", "Amen.", "Well said.")

If INVALID:
- Respond only with:
"Please share a brief thought or feeling related to the verse."

''';
  }

  /// Parse AI response
  ValidationResult _parseAIResponse(String aiResponse) {
    try {
      // Extract JSON from response (AI might add extra text)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(aiResponse);
      if (jsonMatch == null) {
        return _fallbackValidation('');
      }

      final jsonStr = jsonMatch.group(0)!;
      final data = jsonDecode(jsonStr);

      return ValidationResult(
        isValid: data['valid'] == true,
        feedback: data['feedback'] as String? ?? '',
        score: (data['score'] as num?)?.toDouble() ?? 0.0,
        source: 'openai',
      );
    } catch (e) {
      debugPrint('❌ Error parsing AI response: $e');
      return _fallbackValidation('');
    }
  }

  /// Fallback validation (basic length check)
  ValidationResult _fallbackValidation(String userResponse) {
    final trimmed = userResponse.trim();
    final isValid = trimmed.length >= 3; // Very lenient - just needs something

    return ValidationResult(
      isValid: isValid,
      feedback: isValid
          ? 'Thank you for your reflection! 🙏'
          : 'Please share a brief thought about the verse.',
      score: isValid ? 0.75 : 0.0, // Generous score for fallback
      source: 'fallback',
    );
  }
}
