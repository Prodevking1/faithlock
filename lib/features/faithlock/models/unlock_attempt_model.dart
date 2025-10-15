import 'package:faithlock/features/faithlock/models/bible_verse_model.dart';

class UnlockAttempt {
  final int? id;
  final String verseId;
  final DateTime timestamp;
  final bool wasSuccessful;
  final int attemptCount;
  final int? timeToUnlockSeconds;
  final BibleVerse? verse; // Optional, for joins

  const UnlockAttempt({
    this.id,
    required this.verseId,
    required this.timestamp,
    required this.wasSuccessful,
    required this.attemptCount,
    this.timeToUnlockSeconds,
    this.verse,
  });

  factory UnlockAttempt.fromJson(Map<String, dynamic> json) {
    return UnlockAttempt(
      id: json['id'] as int?,
      verseId: json['verse_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      wasSuccessful: json['was_successful'] == 1,
      attemptCount: json['attempt_count'] as int,
      timeToUnlockSeconds: json['time_to_unlock'] as int?,
      verse: json['verse'] != null
          ? BibleVerse.fromJson(json['verse'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'verse_id': verseId,
      'timestamp': timestamp.toIso8601String(),
      'was_successful': wasSuccessful ? 1 : 0,
      'attempt_count': attemptCount,
      if (timeToUnlockSeconds != null) 'time_to_unlock': timeToUnlockSeconds,
    };
  }

  UnlockAttempt copyWith({
    int? id,
    String? verseId,
    DateTime? timestamp,
    bool? wasSuccessful,
    int? attemptCount,
    int? timeToUnlockSeconds,
    BibleVerse? verse,
  }) {
    return UnlockAttempt(
      id: id ?? this.id,
      verseId: verseId ?? this.verseId,
      timestamp: timestamp ?? this.timestamp,
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
      attemptCount: attemptCount ?? this.attemptCount,
      timeToUnlockSeconds: timeToUnlockSeconds ?? this.timeToUnlockSeconds,
      verse: verse ?? this.verse,
    );
  }

  Duration? get timeToUnlock {
    if (timeToUnlockSeconds == null) return null;
    return Duration(seconds: timeToUnlockSeconds!);
  }

  String? get formattedTimeToUnlock {
    if (timeToUnlockSeconds == null) return null;
    if (timeToUnlockSeconds! < 60) {
      return '$timeToUnlockSeconds seconds';
    }
    final minutes = timeToUnlockSeconds! ~/ 60;
    final seconds = timeToUnlockSeconds! % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  String toString() {
    return 'UnlockAttempt(id: $id, success: $wasSuccessful, attempts: $attemptCount)';
  }
}
