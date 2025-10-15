import 'package:faithlock/app_routes.dart';
import 'package:faithlock/core/constants/export.dart';
import 'package:faithlock/core/utils/export.dart';
import 'package:faithlock/features/auth/controllers/reset_password_controller.dart';
import 'package:faithlock/shared/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends GetView<PasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PasswordController());
    final emailController = TextEditingController();

    return Scaffold(
      backgroundColor: FastColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                // Hero section
                _buildHeroSection(context),

                // Form section
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FastSpacing.h16,
                          _buildHeader(),
                          FastSpacing.h32,
                          _buildEmailForm(emailController),
                          FastSpacing.h32,
                          _buildSendButton(emailController, controller),
                          const Spacer(),
                          _buildHelpSection(),
                          FastSpacing.h16,
                        ],
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
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FastSpacing.space16,
              vertical: FastSpacing.space8,
            ),
            child: GestureDetector(
              onTap: () => Get.offAllNamed(AppRoutes.signIn),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_back_ios_new_outlined,
                    size: 16,
                    color: FastColors.textSecondary,
                  ),
                  FastSpacing.w8,
                  Text(
                    'login'.tr,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: FastColors.primary.withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.lock_reset_outlined,
                    size: 48,
                  ),
                ),
                FastSpacing.h24,
                Text(
                  'forgotPassword'.tr,
                  style: Get.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                FastSpacing.h8,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'noWorriesResetMessage'.tr,
                    style: Get.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'resetPassword'.tr,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: FastColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        FastSpacing.h8,
        Text(
          'resetPasswordMessage'.tr,
          style: Get.textTheme.bodyLarge?.copyWith(
            color: FastColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm(TextEditingController emailController) {
    return Column(
      children: [
        FastEmailInput(
          controller: emailController,
          hintText: 'enterEmailAddress'.tr,
          validator: (String? value) => FormValidator.validateEmail(value),
        ),
      ],
    );
  }

  Widget _buildSendButton(
      TextEditingController emailController, PasswordController controller) {
    return Obx(() => FastButton(
          text: 'sendResetLink'.tr,
          onTap: () async {
            if (emailController.text.isNotEmpty) {
              final success =
                  await controller.sendResetPasswordEmail(emailController.text);
              if (success) {
                Get.toNamed('/auth/verify-otp', arguments: {
                  'email': emailController.text,
                  'type': 'password_reset'
                });
              }
            }
          },
          isLoading: controller.isLoading.value,
        ));
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FastColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FastColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: FastColors.info,
          ),
          FastSpacing.w8,
          Expanded(
            child: Text(
              'cantFindEmailMessage'.tr,
              style: Get.textTheme.bodySmall?.copyWith(
                color: FastColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
