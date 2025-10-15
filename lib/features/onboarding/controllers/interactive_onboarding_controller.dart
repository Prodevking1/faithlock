import 'package:faithlock/config/app_config.dart';
import 'package:faithlock/features/onboarding/models/interactive_action_model.dart';
import 'package:faithlock/features/onboarding/models/interactive_onboarding_content.dart';
import 'package:faithlock/features/onboarding/models/onboarding_step_model.dart';
import 'package:faithlock/services/analytics/analytics_service.dart';
import 'package:faithlock/services/api/supabase/supabase_auth_service.dart';
import 'package:faithlock/services/permissions/permission_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastInteractiveOnboardingController extends GetxController {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyActionResults = 'onboarding_action_results';

  final AnalyticsService _analyticsService = AnalyticsService();
  final SupabaseAuthService _authService = Get.find<SupabaseAuthService>();
  late final PageController pageController;

  final RxInt currentStepIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, ActionResult> actionResults =
      <String, ActionResult>{}.obs;
  final RxBool canContinue = true.obs;
  final RxBool isShowingActions = false.obs;
  final steps = InteractiveOnboardingContent.steps;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _loadPreviousResults();
    _trackOnboardingStart();
    _updateCanContinueStatus();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> _loadPreviousResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults = prefs.getString(_keyActionResults);
    if (savedResults != null) {
    }
  }

  Future<void> _saveActionResults() async {
    final prefs = await SharedPreferences.getInstance();
    final results =
        actionResults.values.map((result) => result.toJson()).toList();
    await prefs.setString(_keyActionResults, results.toString());
  }

  void _trackOnboardingStart() {
    _analyticsService.logEvent(
      'interactive_onboarding_started',
      eventProperties: {
        'total_steps': steps.length,
        'interactive_steps': steps.where((step) => step.hasActions).length,
        'platform': GetPlatform.isIOS ? 'ios' : 'android',
      },
    );
  }

  void onActionCompleted(ActionResult result) async {
    actionResults[result.actionId] = result;
    _updateCanContinueStatus();
    _saveActionResults();

    await _processActionResult(result);

    _analyticsService.logEvent(
      'onboarding_action_completed',
      eventProperties: {
        'action_id': result.actionId,
        'step_index': currentStepIndex.value,
        'step_title': currentStep.title,
        'action_type': _getActionType(result.actionId),
      },
    );

    HapticFeedback.lightImpact();
  }

  String _getActionType(String actionId) {
    final currentStep = steps[currentStepIndex.value];
    final action = currentStep.actions?.firstWhereOrNull(
      (action) => action.id == actionId,
    );
    return action?.type.toString() ?? 'unknown';
  }

  void _updateCanContinueStatus() {
    canContinue.value = true;
  }

  Future<void> nextStep() async {
    await _proceedToNextStep();
  }

  bool shouldShowActionsModal() {
    return currentStep.requiresActions;
  }
  Map<String, dynamic> getActionModalConfig() {
    if (!currentStep.hasActions) return {};

    return {
      'step': currentStep,
      'isDismissible': currentStep.canSkip && !currentStep.requiresActions,
      'enableDrag': currentStep.canSkip && !currentStep.requiresActions,
      'canSkip': currentStep.canSkip && !currentStep.requiresActions,
    };
  }

  void onActionsModalOpened() {
    isShowingActions.value = true;
    _analyticsService.logEvent(
      'onboarding_actions_modal_opened',
      eventProperties: {
        'step_index': currentStepIndex.value,
        'step_title': currentStep.title,
        'actions_count': currentStep.actions?.length ?? 0,
      },
    );
  }

  void onActionsModalClosed() {
    isShowingActions.value = false;
  }

  void onModalActionsCompleted(List<ActionResult> results) async {
    for (final result in results) {
      actionResults[result.actionId] = result;

      await _processActionResult(result);
    }

    _updateCanContinueStatus();
    _saveActionResults();

    _analyticsService.logEvent(
      'onboarding_actions_modal_completed',
      eventProperties: {
        'step_index': currentStepIndex.value,
        'actions_completed': results.length,
        'completion_rate': stepCompletionPercentage,
      },
    );

    HapticFeedback.mediumImpact();
    await _proceedToNextStep();
  }

  Future<void> _proceedToNextStep() async {
    if (currentStepIndex.value >= steps.length - 1) {
      await completeOnboarding();
      return;
    }

    HapticFeedback.lightImpact();
    await pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _updateCanContinueStatus();

    _analyticsService.logEvent(
      'onboarding_step_viewed',
      eventProperties: {
        'step_index': currentStepIndex.value,
        'step_title': steps[currentStepIndex.value].title,
        'has_actions': steps[currentStepIndex.value].hasActions,
        'requires_actions': steps[currentStepIndex.value].requiresActions,
      },
    );
  }

  Future<void> previousStep() async {
    if (currentStepIndex.value <= 0) return;

    HapticFeedback.selectionClick();

    final targetIndex = currentStepIndex.value - 1;
    if (targetIndex < 0) return;

    await pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _updateCanContinueStatus();
  }

  Future<void> skipStep() async {
    final currentStep = steps[currentStepIndex.value];

    if (!currentStep.canSkip) {
      return;
    }

    _analyticsService.logEvent(
      'onboarding_step_skipped',
      eventProperties: {
        'step_index': currentStepIndex.value,
        'step_title': currentStep.title,
        'had_actions': currentStep.hasActions,
      },
    );

    await nextStep();
  }

  Future<void> completeOnboarding() async {
    isLoading.value = true;

    _analyticsService.logEvent(
      'interactive_onboarding_completed',
      eventProperties: {
        'steps_completed': steps.length,
        'actions_completed': actionResults.length,
        'completion_rate': _calculateCompletionRate(),
      },
    );

    HapticFeedback.mediumImpact();

    await _markOnboardingCompleted();

    isLoading.value = false;
    _navigateToNextScreen();
  }

  double _calculateCompletionRate() {
    final totalActions = steps.expand((step) => step.actions ?? []).length;

    if (totalActions == 0) return 1.0;

    return actionResults.length / totalActions;
  }

  Future<void> _markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  void _navigateToNextScreen() async {
    if (AppConfig.appFeatures.enableAnonAuth) {
      await _performAnonymousAuth();
    } else {
      Get.offAllNamed('/auth/signup');
    }
  }

  Future<void> _performAnonymousAuth() async {
    try {
      isLoading.value = true;

      _analyticsService.logEvent(
        'anonymous_auth_started',
        eventProperties: {
          'source': 'interactive_onboarding_completion',
        },
      );

      final response = await _authService.signInAnonymously();

      if (response.user != null) {
        _analyticsService.logEvent(
          'anonymous_auth_success',
          eventProperties: {
            'user_id': response.user!.id,
            'source': 'interactive_onboarding_completion',
          },
        );

        await _processActionResults();

        Get.offAllNamed('/home');
      } else {
        throw Exception('Anonymous authentication failed');
      }
    } catch (e) {
      _analyticsService.logEvent(
        'anonymous_auth_failed',
        eventProperties: {
          'error': e.toString(),
          'source': 'interactive_onboarding_completion',
        },
      );

      Get.offAllNamed('/auth/signup');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _processActionResults() async {
    for (final result in actionResults.values) {
      await _processActionResult(result);
    }
  }

  Future<void> _processActionResult(ActionResult result) async {
    try {
      switch (result.actionId) {
        case 'username':
          _analyticsService.logEvent('user_profile_updated', eventProperties: {
            'field': 'username',
            'value': result.value,
          });
          break;
        case 'preferences':
          _analyticsService
              .logEvent('user_preferences_saved', eventProperties: {
            'preferences': result.value,
          });
          break;
        case 'notifications':
          _analyticsService.logEvent('permission_granted', eventProperties: {
            'permission_type': 'notifications',
            'granted': result.value,
          });
          break;
        default:
          _analyticsService
              .logEvent('action_result_processed', eventProperties: {
            'action_id': result.actionId,
            'value': result.value,
          });
      }
    } catch (e) {
      _analyticsService.logEvent('action_processing_failed', eventProperties: {
        'action_id': result.actionId,
        'error': e.toString(),
      });
    }
  }

  OnboardingStep get currentStep {
    final index = currentStepIndex.value;
    if (index < 0 || index >= steps.length) {
      return steps[0]; // Return first step as fallback
    }
    return steps[index];
  }

  bool get isLastStep => currentStepIndex.value >= steps.length - 1;

  bool get isFirstStep => currentStepIndex.value <= 0;

  String get buttonText {
    if (isLastStep) {
      return 'begin'.tr;
    }

    return currentStep.continueLabel ?? 'continue'.tr;
  }

  String get skipButtonText => currentStep.skipLabel ?? 'skip'.tr;

  bool get showSkipButton =>
      currentStep.canSkip && !currentStep.requiresActions;

  List<InteractiveAction> get currentStepActions => currentStep.actions ?? [];

  bool get hasCompletedRequiredActions {
    final requiredActions = currentStep.requiredActions;
    if (requiredActions.isEmpty) return true;

    return requiredActions.every((action) {
      final result = actionResults[action.id];
      return result != null && result.isCompleted;
    });
  }

  double get stepCompletionPercentage {
    final totalActions = currentStepActions.length;
    if (totalActions == 0) return 1.0;

    final completedActions = currentStepActions.where((action) {
      final result = actionResults[action.id];
      return result != null && result.isCompleted;
    }).length;

    return completedActions / totalActions;
  }

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingCompleted);
    await prefs.remove(_keyActionResults);
  }

  InteractiveAction? _findActionById(String actionId) {
    final currentStepAction = currentStep.actions
        ?.firstWhereOrNull((action) => action.id == actionId);
    if (currentStepAction != null) return currentStepAction;

    for (final step in steps) {
      final action = step.actions?.firstWhereOrNull((a) => a.id == actionId);
      if (action != null) return action;
    }
    return null;
  }

  Future<void> _handlePermissionAction(
      InteractiveAction action, ActionResult result) async {
    final permissionTypes = action.permissionTypes ??
        (action.requiredPermissions
                ?.map(_getPermissionTypeFromString)
                .whereType<PermissionType>()
                .toList() ??
            []);

    if (permissionTypes.isEmpty) {
      return;
    }

    try {
      final Map<String, bool> permissionResults = {};
      final Map<String, String> permissionMessages = {};

      for (final permissionType in permissionTypes) {
        final PermissionResult permissionResult;
        switch (permissionType) {
          case PermissionType.pushNotifications:
            permissionResult =
                await PermissionManager.requestPushNotifications();
            break;
          case PermissionType.microphone:
            permissionResult = await PermissionManager.requestMicrophone();
            break;
          case PermissionType.camera:
            permissionResult = await PermissionManager.requestCamera();
            break;
          case PermissionType.photos:
            permissionResult = await PermissionManager.requestPhotos();
            break;
          case PermissionType.location:
            permissionResult = await PermissionManager.requestLocation();
            break;
          case PermissionType.contacts:
            permissionResult = await PermissionManager.requestContacts();
            break;
          case PermissionType.storage:
            permissionResult = await PermissionManager.requestStorage();
            break;
          case PermissionType.calendar:
            permissionResult = await PermissionManager.requestCalendar();
            break;
        }

        final permissionName = permissionType.name;
        permissionResults[permissionName] = permissionResult.isGranted;
        permissionMessages[permissionName] = permissionResult.message;
        _showPermissionFeedback(permissionResult);
      }

      final updatedResult = ActionResult(
        actionId: result.actionId,
        value: {
          'permissions': permissionResults,
          'messages': permissionMessages,
          'requested_at': DateTime.now().toIso8601String(),
        },
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      actionResults[result.actionId] = updatedResult;
      _analyticsService.logEvent(
        'onboarding_permission_result',
        eventProperties: {
          'action_id': result.actionId,
          'permissions': permissionResults,
          'all_granted': permissionResults.values.every((granted) => granted),
          'permission_count': permissionResults.length,
        },
      );
    } catch (e) {
      print('Error handling permission action: $e');
      Get.snackbar(
        'Permission Error',
        'There was an error requesting permissions. Please try again.',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 3),
      );
    }
  }

  String? _getStringValueFromResult(dynamic value) {
    if (value is String) {
      return value;
    }
    if (value is List<String> && value.isNotEmpty) {
      return value.first;
    }
    return null;
  }

  String? _getFirstValueFromResult(dynamic value) {
    if (value is List<String> && value.isNotEmpty) {
      return value.first;
    }
    if (value is String) {
      return value;
    }
    return null;
  }

  PermissionType? _getPermissionTypeFromString(String permissionName) {
    switch (permissionName.toLowerCase()) {
      case 'push_notifications':
      case 'notifications':
        return PermissionType.pushNotifications;
      case 'microphone':
        return PermissionType.microphone;
      case 'camera':
        return PermissionType.camera;
      case 'photos':
      case 'gallery':
        return PermissionType.photos;
      case 'location':
        return PermissionType.location;
      case 'contacts':
        return PermissionType.contacts;
      case 'storage':
        return PermissionType.storage;
      case 'calendar':
        return PermissionType.calendar;
      default:
        print('Unknown permission type: $permissionName');
        return null;
    }
  }

  void _showPermissionFeedback(PermissionResult result) {
    if (result.isGranted) {
      Get.snackbar(
        'Permission Granted',
        result.message,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green[800],
        icon: const Icon(Icons.check_circle, color: Colors.green),
        duration: const Duration(seconds: 2),
      );
    } else if (result.error == null) {
      Get.snackbar(
        'Permission Needed',
        '${result.message}\\nYou can enable this later in Settings.',
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
        colorText: Colors.orange[800],
        icon: const Icon(Icons.info, color: Colors.orange),
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () async {
            await PermissionManager.openDeviceSettings();
          },
          child: const Text('Settings'),
        ),
      );
    }
  }
}
