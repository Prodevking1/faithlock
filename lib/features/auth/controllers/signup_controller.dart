import 'package:faithlock/app_routes.dart';
import 'package:faithlock/core/constants/export.dart';
import 'package:faithlock/core/helpers/export.dart';
import 'package:faithlock/core/mixins/export.dart';
import 'package:faithlock/services/export.dart';
import 'package:get/get.dart';

import '../states/sign_up_form_state.dart';

class SignUpController extends GetxController with AsyncStateHandlerMixin {
  final SupabaseAuthService _supabaseService;
  final StorageService _storageService;
  final SignUpFormState formState;

  SignUpController({
    SupabaseAuthService? supabaseService,
    StorageService? storageService,
    SignUpFormState? formState,
  })  : _supabaseService = supabaseService ?? SupabaseAuthService(),
        _storageService = storageService ?? StorageService(),
        formState = formState ?? SignUpFormState();

  bool enablePasswordConfirm = false;

  Future<bool> signUpWithEmail() async {
    if (!formState.validate()) {
      return false;
    }

    try {
      isLoading.value = true;

      final authResponse = await _supabaseService.signUpWithEmail(
        email: formState.emailController.text.trim(),
        password: formState.passwordController.text,
        data: {
          'full_name': formState.fullNameController.text.trim(),
        },
      );

      // If we got a valid auth response, handle success
      if (authResponse.user != null) {
        await _handleSignUpSuccess();
        return true;
      }

      return false;
    } catch (e) {
      handleResponseError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithOtp(String phone) async {
    await executeWithErrorHandling(() async {
      await _supabaseService.signInWithOtp(phone: phone);
      await _handleSignUpSuccess();
    });
  }

  Future<void> signUpWithGoogle() async {
    await executeWithErrorHandling(() async {
      // await _supabaseService.signUpWithGoogle();
      await _handleSignUpSuccess();
    });
  }

  Future<void> signUpWithApple() async {
    await executeWithErrorHandling(() async {
      // await _supabaseService.signUpWithApple();
      await _handleSignUpSuccess();
    });
  }

  Future<void> _handleSignUpSuccess() async {
    await _storageService.writeBool(LocalStorageKeys.isLoggedIn, true);
    // After signup, navigate to main screen or onboarding
    NavigationHelper.navigateTo(AppRoutes.main);
  }

  @override
  void onClose() {
    formState.dispose();
    super.onClose();
  }
}
