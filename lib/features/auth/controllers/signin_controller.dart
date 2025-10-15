// form/sign_in_form_state.dart
import 'package:faithlock/app_routes.dart';
import 'package:faithlock/core/helpers/export.dart';
import 'package:faithlock/core/mixins/export.dart';
import 'package:faithlock/services/export.dart';
import 'package:get/get.dart';

import '../../../core/constants/export.dart';
import '../states/sign_in_form_start.dart';

class SignInController extends GetxController with AsyncStateHandlerMixin {
  final SupabaseAuthService _supabaseService;
  final StorageService _storageService;
  final SignInFormState formState;

  SignInController({
    SupabaseAuthService? supabaseService,
    StorageService? storageService,
    SignInFormState? formState,
  })  : _supabaseService = supabaseService ?? SupabaseAuthService(),
        _storageService = storageService ?? StorageService(),
        formState = formState ?? SignInFormState();

  Future<bool> signInWithEmail() async {
    if (!formState.validate()) {
      return false;
    }

    try {
      isLoading.value = true;

      final authResponse = await _supabaseService.signInWithEmail(
        email: formState.emailController.text.trim(),
        password: formState.passwordController.text,
      );

      if (authResponse.user != null) {
        await _handleLoginSuccess();
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

  Future<void> signInWithOtp(String phone) async {
    try {
      await executeWithErrorHandling(() async {
        await _supabaseService.signInWithOtp(phone: phone);
        await _handleLoginSuccess();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    UIHelper.showInfoSnackBar("Google sign in is not implemented yet");
    // await executeWithErrorHandling(() async {
    //   await _supabaseService.signInWithGoogle();
    //   await _handleLoginSuccess();
    // });
  }

  Future<void> loginWithApple() async {
    UIHelper.showInfoSnackBar("Apple sign in is not implemented yet");
    // await executeWithErrorHandling(() async {
    //   await _supabaseService.signInWithApple();
    //   await _handleLoginSuccess();
    // });
  }

  Future<void> _handleLoginSuccess() async {
    await _storageService.writeBool(LocalStorageKeys.isLoggedIn, true);
    NavigationHelper.navigateTo(AppRoutes.main);
  }

  @override
  void onClose() {
    formState.dispose();
    super.onClose();
  }
}
