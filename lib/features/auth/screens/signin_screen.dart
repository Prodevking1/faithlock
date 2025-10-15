import 'package:faithlock/app_routes.dart';
import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:faithlock/core/constants/core/fast_spacing.dart';
import 'package:faithlock/core/helpers/navigation_helper.dart';
import 'package:faithlock/core/utils/validators/form_validator.dart';
import 'package:faithlock/features/auth/controllers/export.dart';
import 'package:faithlock/shared/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignInController());
    return Scaffold(
      backgroundColor: FastColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                _buildHeroSection(context),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: FastColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: FastColors.shadow,
                          blurRadius: 20,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(FastSpacing.space24),
                      child: Form(
                        key: controller.formState.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(),
                            FastSpacing.h24,
                            _buildForm(),
                            FastSpacing.h16,
                            _buildForgotPassword(),
                            FastSpacing.h16,
                            _buildLoginButton(),
                            FastSpacing.h24,
                            _buildDivider(),
                            FastSpacing.h24,
                            _buildSocialLogin(),
                            FastSpacing.h32,
                            _buildSignUpLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      child: Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: FastColors.primary.withValues(alpha: 0.15),
          border: Border.all(
            color: FastColors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.lock_open_outlined,
          size: Get.size.height * 0.1,
          color: FastColors.white,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'signin'.tr,
          style: Get.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: FastColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        FastSpacing.h4,
        Text(
          'enterCredentialsMessage'.tr,
          style: Get.textTheme.headlineSmall?.copyWith(
            color: FastColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        FastEmailInput(
          hintText: 'email'.tr,
          controller: controller.formState.emailController,
          validator: (String? value) => FormValidator.validateEmail(value),
        ),
        FastSpacing.h16,
        FastPasswordInput(
          controller: controller.formState.passwordController,
          hintText: 'password'.tr,
          validator: (String? value) => FormValidator.validatePassword(value),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.forgotPassword),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FastSpacing.space8,
            vertical: FastSpacing.space4,
          ),
          child: Text(
            'forgotPassword'.tr,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: FastColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => FastButton(
        text: 'signin'.tr,
        onTap: () async {
          await controller.signInWithEmail();
        },
        isLoading: controller.isLoading.value,
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  FastColors.divider.withValues(alpha: 0.5),
                  FastColors.divider,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: FastSpacing.space16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FastSpacing.space12,
              vertical: FastSpacing.space4,
            ),
            decoration: BoxDecoration(
              color: FastColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: FastColors.divider.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'or'.tr,
              style: Get.textTheme.bodySmall?.copyWith(
                color: FastColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FastColors.divider,
                  FastColors.divider.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: FontAwesomeIcons.apple,
            label: 'apple'.tr,
            onTap: controller.loginWithApple,
            backgroundColor: FastColors.black,
            iconColor: FastColors.white,
          ),
        ),
        FastSpacing.w16,
        Expanded(
          child: _buildSocialButton(
            icon: FontAwesomeIcons.google,
            label: 'google'.tr,
            onTap: controller.signInWithGoogle,
            backgroundColor: FastColors.white,
            iconColor: Colors.red,
            borderColor: FastColors.lightGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
    Color? borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor == FastColors.white
                ? FastColors.lightGrey.withValues(alpha: 0.3)
                : backgroundColor.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: FastSpacing.space16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border:
                  borderColor != null ? Border.all(color: borderColor) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
                FastSpacing.w8,
                Text(
                  label,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: backgroundColor == FastColors.white
                        ? FastColors.textPrimary
                        : FastColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'dontHaveAccount'.tr,
          style: Get.textTheme.bodyMedium?.copyWith(
            color: FastColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => NavigationHelper.navigateTo(AppRoutes.signUp),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FastSpacing.space8,
              vertical: FastSpacing.space4,
            ),
            child: Text(
              'signup'.tr,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: FastColors.primary,
                fontWeight: FontWeight.bold,
                decorationColor: FastColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
