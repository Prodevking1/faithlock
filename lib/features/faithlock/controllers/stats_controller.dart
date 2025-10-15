import 'package:get/get.dart';
import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/faithlock/services/export.dart';

/// Controller for Stats Dashboard Screen
/// Manages loading and refreshing user statistics
class StatsController extends GetxController {
  final StatsService _statsService = StatsService();

  // Observable state
  final Rx<UserStats?> userStats = Rx<UserStats?>(null);
  final RxBool isLoading = RxBool(true);
  final RxString errorMessage = RxString('');

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  /// Load user statistics from service
  Future<void> loadStats() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final stats = await _statsService.getUserStats();
      userStats.value = stats;
    } catch (e) {
      errorMessage.value = 'Failed to load statistics: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh statistics (pull-to-refresh)
  Future<void> refreshStats() async {
    await loadStats();
  }

  /// Get formatted streak text
  String getStreakText() {
    if (userStats.value == null) return '0 days';
    final streak = userStats.value!.currentStreak;
    return '$streak ${streak == 1 ? 'day' : 'days'}';
  }

  /// Get formatted verses read text
  String getVersesReadText() {
    if (userStats.value == null) return '0 verses';
    final verses = userStats.value!.totalVersesRead;
    return '$verses ${verses == 1 ? 'verse' : 'verses'}';
  }

  /// Get formatted success rate text
  String getSuccessRateText() {
    if (userStats.value == null) return '0%';
    final rate = userStats.value!.averageQuizScore;
    return '${(rate * 100).toStringAsFixed(0)}%';
  }

  /// Get formatted screen time text
  String getScreenTimeText() {
    if (userStats.value == null) return '0 min';
    final minutes = userStats.value!.screenTimeReducedMinutes;

    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'}';
      }
      return '$hours${remainingMinutes}min';
    }
  }
}
