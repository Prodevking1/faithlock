import 'package:flutter/material.dart';

class LockSchedule {
  final String id;
  final String name;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> daysOfWeek; // 1-7 (Monday-Sunday)
  final bool isEnabled;
  final ScheduleType type;
  final DateTime createdAt;

  const LockSchedule({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    required this.isEnabled,
    required this.type,
    required this.createdAt,
  });

  factory LockSchedule.fromJson(Map<String, dynamic> json) {
    final startParts = (json['start_time'] as String).split(':');
    final endParts = (json['end_time'] as String).split(':');

    return LockSchedule(
      id: json['id'] as String,
      name: json['name'] as String,
      startTime: TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      ),
      daysOfWeek: (json['days'] as String)
          .split(',')
          .map((e) => int.parse(e))
          .toList(),
      isEnabled: json['is_enabled'] == 1,
      type: ScheduleTypeExtension.fromString(json['type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'days': daysOfWeek.join(','),
      'is_enabled': isEnabled ? 1 : 0,
      'type': type.value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LockSchedule copyWith({
    String? id,
    String? name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<int>? daysOfWeek,
    bool? isEnabled,
    ScheduleType? type,
    DateTime? createdAt,
  }) {
    return LockSchedule(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isEnabled: isEnabled ?? this.isEnabled,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedStartTime => '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  String get formattedEndTime => '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

  String get daysDisplay {
    if (daysOfWeek.length == 7) return 'Every day';
    if (daysOfWeek.length == 5 && !daysOfWeek.contains(6) && !daysOfWeek.contains(7)) {
      return 'Weekdays';
    }
    if (daysOfWeek.length == 2 && daysOfWeek.contains(6) && daysOfWeek.contains(7)) {
      return 'Weekends';
    }

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return daysOfWeek.map((d) => dayNames[d - 1]).join(', ');
  }

  bool isActiveNow() {
    final now = DateTime.now();
    final currentDay = now.weekday; // 1-7 (Monday-Sunday)
    final currentTime = TimeOfDay.now();

    if (!isEnabled || !daysOfWeek.contains(currentDay)) {
      return false;
    }

    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    // Handle overnight schedules (e.g., 22:00 - 07:00)
    if (startMinutes > endMinutes) {
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }

    return currentMinutes >= startMinutes && currentMinutes < endMinutes;
  }

  @override
  String toString() => '$name: $formattedStartTime - $formattedEndTime ($daysDisplay)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LockSchedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum ScheduleType {
  daily,
  custom,
  bedtime,
  workHours,
  mealTime,
}

extension ScheduleTypeExtension on ScheduleType {
  String get value {
    switch (this) {
      case ScheduleType.daily:
        return 'daily';
      case ScheduleType.custom:
        return 'custom';
      case ScheduleType.bedtime:
        return 'bedtime';
      case ScheduleType.workHours:
        return 'work_hours';
      case ScheduleType.mealTime:
        return 'meal_time';
    }
  }

  String get displayName {
    switch (this) {
      case ScheduleType.daily:
        return 'Daily';
      case ScheduleType.custom:
        return 'Custom';
      case ScheduleType.bedtime:
        return 'Bedtime';
      case ScheduleType.workHours:
        return 'Work Hours';
      case ScheduleType.mealTime:
        return 'Meal Time';
    }
  }

  static ScheduleType fromString(String value) {
    switch (value) {
      case 'daily':
        return ScheduleType.daily;
      case 'custom':
        return ScheduleType.custom;
      case 'bedtime':
        return ScheduleType.bedtime;
      case 'work_hours':
        return ScheduleType.workHours;
      case 'meal_time':
        return ScheduleType.mealTime;
      default:
        return ScheduleType.custom;
    }
  }
}

// Preset schedules
class LockSchedulePresets {
  static LockSchedule bedtime() => LockSchedule(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: 'Bedtime',
    startTime: const TimeOfDay(hour: 22, minute: 0),
    endTime: const TimeOfDay(hour: 7, minute: 0),
    daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Every day
    isEnabled: true,
    type: ScheduleType.bedtime,
    createdAt: DateTime.now(),
  );

  static LockSchedule workHours() => LockSchedule(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: 'Work Hours',
    startTime: const TimeOfDay(hour: 9, minute: 0),
    endTime: const TimeOfDay(hour: 17, minute: 0),
    daysOfWeek: [1, 2, 3, 4, 5], // Weekdays
    isEnabled: true,
    type: ScheduleType.workHours,
    createdAt: DateTime.now(),
  );

  static LockSchedule mealTime({required String name, required TimeOfDay startTime}) {
    return LockSchedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      startTime: startTime,
      endTime: TimeOfDay(hour: startTime.hour, minute: startTime.minute + 30),
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
      isEnabled: true,
      type: ScheduleType.mealTime,
      createdAt: DateTime.now(),
    );
  }
}
