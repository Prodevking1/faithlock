/// Represents the current state of a user's streak freeze protection
class StreakFreezeState {
  final int freezesRemaining;
  final int maxFreezes;
  final DateTime weekStartDate;
  final bool usedConsecutiveFreeze;
  final DateTime? lastFreezeUsedDate;

  const StreakFreezeState({
    required this.freezesRemaining,
    required this.maxFreezes,
    required this.weekStartDate,
    this.usedConsecutiveFreeze = false,
    this.lastFreezeUsedDate,
  });

  /// Initial state for a new user
  factory StreakFreezeState.initial({required bool isPremium}) {
    final maxFreezes = isPremium ? 3 : 1;
    return StreakFreezeState(
      freezesRemaining: maxFreezes,
      maxFreezes: maxFreezes,
      weekStartDate: _getMondayOfWeek(DateTime.now()),
      usedConsecutiveFreeze: false,
    );
  }

  /// Whether a freeze can be consumed right now
  bool get canUseFreeze => freezesRemaining > 0 && !usedConsecutiveFreeze;

  StreakFreezeState copyWith({
    int? freezesRemaining,
    int? maxFreezes,
    DateTime? weekStartDate,
    bool? usedConsecutiveFreeze,
    DateTime? lastFreezeUsedDate,
  }) {
    return StreakFreezeState(
      freezesRemaining: freezesRemaining ?? this.freezesRemaining,
      maxFreezes: maxFreezes ?? this.maxFreezes,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      usedConsecutiveFreeze:
          usedConsecutiveFreeze ?? this.usedConsecutiveFreeze,
      lastFreezeUsedDate: lastFreezeUsedDate ?? this.lastFreezeUsedDate,
    );
  }

  /// Get Monday 00:00 of the week containing [date]
  static DateTime _getMondayOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - DateTime.monday;
    final monday = date.subtract(Duration(days: daysFromMonday));
    return DateTime(monday.year, monday.month, monday.day);
  }
}
