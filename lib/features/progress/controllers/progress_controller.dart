import 'package:get/get.dart';

class ProgressController extends GetxController {
  static ProgressController get to => Get.find();

  // Observable variables
  final RxDouble _dailyProgress = 0.7.obs;
  final RxDouble _weeklyProgress = 0.5.obs;
  final RxDouble _monthlyProgress = 0.3.obs;
  
  final RxInt _tasksCompleted = 24.obs;
  final RxInt _pendingTasks = 12.obs;
  final RxDouble _successRate = 75.0.obs;
  final RxDouble _avgCompletionTime = 3.2.obs;

  // Getters
  double get dailyProgress => _dailyProgress.value;
  double get weeklyProgress => _weeklyProgress.value;
  double get monthlyProgress => _monthlyProgress.value;
  
  int get tasksCompleted => _tasksCompleted.value;
  int get pendingTasks => _pendingTasks.value;
  double get successRate => _successRate.value;
  double get avgCompletionTime => _avgCompletionTime.value;

  // Methods to update progress values
  void updateDailyProgress(double value) {
    _dailyProgress.value = value;
  }

  void updateWeeklyProgress(double value) {
    _weeklyProgress.value = value;
  }

  void updateMonthlyProgress(double value) {
    _monthlyProgress.value = value;
  }

  // Method to fetch progress data from API or local storage
  Future<void> fetchProgressData() async {
    // Simulate API call or data fetch
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, you would update values based on API response
    // For demo purposes, we're using mock values
    _dailyProgress.value = 0.7;
    _weeklyProgress.value = 0.5;
    _monthlyProgress.value = 0.3;
    
    _tasksCompleted.value = 24;
    _pendingTasks.value = 12;
    _successRate.value = 75.0;
    _avgCompletionTime.value = 3.2;
  }
}
