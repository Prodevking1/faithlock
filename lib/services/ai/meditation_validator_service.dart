import 'dart:convert';

import 'package:faithlock/config/env.dart';
import 'package:faithlock/services/ai/apple_intelligence_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return ''' You are a warm, encouraging spiritual mentor evaluating a user's meditation on a Bible verse.

Goal: accept ANY sincere reflection — even short, simple, or imperfect — but do NOT accept low-effort, generic, or meaningless input. There must be a real, personal engagement with THIS verse: a genuine thought, a feeling, or a spiritual idea. Be generous with sincere effort, strict with emptiness.

✅ ACCEPT as VALID when the message shows AT LEAST ONE of:
- A genuine personal feeling or emotion about the verse (peace, hope, conviction, gratitude, struggle, fear, love, etc.)
- A spiritual or faith thought (God, prayer, trust, forgiveness, obedience, guidance, etc.)
- A real attempt to apply the verse or reflect on its meaning (even briefly or vaguely)
- A sincere intention clearly rooted in the verse ("I want to trust God more", "this reminds me to be patient")

❌ REJECT as INVALID when the message is:
- Generic filler or politeness with NO reflection: "thanks", "thank you", "help me", "help me thanks", "ok", "good", "nice", "please", "cool"
- A bare greeting, a plain request for help, or a comment that could be pasted under ANY verse without engaging it
- Random words, gibberish, spam, numbers, or test text ("aaaa", "asdf", "123", "test", "lol")
- Off-topic, profanity, or trolling
- Effectively empty of any thought or feeling, even if it uses real words

Key test: could this exact message be written WITHOUT having read the verse? If yes (generic thanks/greeting/help request), REJECT. A short honest sentence about the verse is enough; a polite non-answer is not.

Response format (JSON only):
{
  "valid": true/false,
  "score": 0.0-1.0,
  "feedback": "One short, warm sentence"
}

Scoring rules:
- 0.0–0.4 → rejected: generic, empty, or unrelated
- 0.6–0.7 → short but sincere and connected to the verse
- 0.8–0.9 → clear personal connection
- 1.0 → deep or thoughtful reflection

If VALID:
- Always encourage warmly (e.g. "Beautiful reflection.", "Amen — well said.", "That's a heartfelt thought.")

If INVALID:
- Respond only with:
"Take a moment to share a real thought or feeling about this verse."

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

  /// Fallback validation when no AI is available.
  ///
  /// Can't judge meaning, so it enforces a deterministic MINIMUM: a real short
  /// sentence (length + word count) that isn't made up entirely of generic
  /// filler like "help me thanks". Stays lenient toward sincere reflections.
  ValidationResult _fallbackValidation(String userResponse) {
    final isValid = !_isLowEffortResponse(userResponse);

    return ValidationResult(
      isValid: isValid,
      feedback: isValid
          ? '${'meditation_thankYouReflection'.tr} 🙏'
          : 'meditation_shareBriefThought'.tr,
      score: isValid ? 0.7 : 0.0,
      source: 'fallback',
    );
  }

  /// Deterministic low-effort detector for the offline path. Rejects empty /
  /// tiny / gibberish input and messages composed only of generic filler words
  /// (greetings, thanks, plain help requests), while accepting short sincere
  /// sentences. Meaning-level checks are left to the AI prompt.
  static bool _isLowEffortResponse(String response) {
    final t = response.trim().toLowerCase();
    if (t.length < 12) return true;

    final words = t
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^a-zà-ÿ]'), ''))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.length < 3) return true;

    // Words that carry no reflection on their own. If NOTHING is left after
    // removing them, the message is empty politeness ("help me thanks").
    const filler = {
      'help', 'me', 'my', 'thanks', 'thank', 'you', 'ok', 'okay', 'good',
      'nice', 'cool', 'please', 'pls', 'test', 'idk', 'nothing', 'lol', 'yes',
      'no', 'amen', 'hi', 'hello', 'hey', 'thx', 'ty', 'a', 'the', 'and', 'to',
      'is', 'it', 'i', 'so', 'of', 'for', 'this', 'that', 'ok.', 'merci',
      'aide', 'moi', 'oui', 'non', 'stp', 'svp',
    };
    final content = words.where((w) => !filler.contains(w));
    return content.isEmpty;
  }
}
