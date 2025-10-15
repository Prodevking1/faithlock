import 'package:faithlock/app_routes.dart';
import 'package:faithlock/core/constants/export.dart';
import 'package:faithlock/core/utils/export.dart';
import 'package:faithlock/features/auth/controllers/reset_password_controller.dart';
import 'package:faithlock/shared/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewPasswordScreen extends GetView<PasswordController> {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PasswordController());
    final args = Get.arguments as Map<String, dynamic>;
    final email = args['email'] as String;
    final token = args['token'] as String;

    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FastSpacing.h16,
                            _buildHeader(),
                            FastSpacing.h32,
                            _buildPasswordForm(
                                passwordController, confirmPasswordController),
                            FastSpacing.h32,
                            _buildSaveButton(
                                controller,
                                formKey,
                                passwordController,
                                confirmPasswordController,
                                email,
                                token),
                            FastSpacing.h24,
                            const Spacer(),
                            _buildSecurityTips(),
                            FastSpacing.h16,
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

  // Widget _buildHeroSection(BuildContext context) {
  //   return Container(
  //     height: MediaQuery.of(context).size.height * 0.3,
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topRight,
  //         end: Alignment.bottomLeft,
  //         colors: [
  //           FastColors.success,
  //           FastColors.success.withValues(alpha: 0.8),
  //           FastColors.accent.withValues(alpha: 0.6),
  //         ],
  //       ),
  //     ),
  //     child: Stack(
  //       children: [
  //         // Back button
  //         Positioned(
  //           top: 20,
  //           left: 20,
  //           child: GestureDetector(
  //             onTap: () => Get.back(),
  //             child: Container(
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: FastColors.white.withValues(alpha: 0.2),
  //                 borderRadius: BorderRadius.circular(16),
  //                 border: Border.all(
  //                   color: FastColors.white.withValues(alpha: 0.3),
  //                   width: 1,
  //                 ),
  //               ),
  //               child: const Icon(
  //                 Icons.arrow_back_ios,
  //                 size: 20,
  //                 color: FastColors.white,
  //               ),
  //             ),
  //           ),
  //         ),

  //         // Decorative elements
  //         Positioned(
  //           top: -50,
  //           left: -50,
  //           child: Container(
  //             width: 140,
  //             height: 140,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               color: FastColors.white.withValues(alpha: 0.1),
  //             ),
  //           ),
  //         ),
  //         Positioned(
  //           bottom: -30,
  //           right: -30,
  //           child: Container(
  //             width: 100,
  //             height: 100,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               color: FastColors.white.withValues(alpha: 0.08),
  //             ),
  //           ),
  //         ),

  //         // Main content
  //         Center(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(24),
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   color: FastColors.white.withValues(alpha: 0.15),
  //                   border: Border.all(
  //                     color: FastColors.white.withValues(alpha: 0.3),
  //                     width: 2,
  //                   ),
  //                 ),
  //                 child: const Icon(
  //                   Icons.lock_outline,
  //                   size: 48,
  //                   color: FastColors.white,
  //                 ),
  //               ),
  //               FastSpacing.h24,
  //               Text(
  //                 'Create New Password',
  //                 style: Get.textTheme.headlineLarge?.copyWith(
  //                   color: FastColors.white,
  //                   fontWeight: FontWeight.bold,
  //                   letterSpacing: 0.5,
  //                 ),
  //               ),
  //               FastSpacing.h8,
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 40),
  //                 child: Text(
  //                   'Your new password must be different from previous passwords',
  //                   style: Get.textTheme.bodyLarge?.copyWith(
  //                     color: FastColors.white.withValues(alpha: 0.9),
  //                     fontWeight: FontWeight.w400,
  //                   ),
  //                   textAlign: TextAlign.center,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
                  'createNewPassword'.tr,
                  style: Get.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                FastSpacing.h8,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'newPasswordDifferentMessage'.tr,
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
          'setNewPassword'.tr,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: FastColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        FastSpacing.h8,
        Text(
          'createStrongPasswordMessage'.tr,
          style: Get.textTheme.bodyLarge?.copyWith(
            color: FastColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm(TextEditingController passwordController,
      TextEditingController confirmPasswordController) {
    return Column(
      children: [
        FastPasswordInput(
          controller: passwordController,
          hintText: 'newPassword'.tr,
          validator: (String? value) => FormValidator.validatePassword(value),
        ),
        FastSpacing.h16,
        FastPasswordInput(
          controller: confirmPasswordController,
          hintText: 'confirmNewPassword'.tr,
          validator: (String? value) {
            if (value != passwordController.text) {
              return 'passwordsDoNotMatch'.tr;
            }
            return FormValidator.validatePassword(value);
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(
      PasswordController controller,
      GlobalKey<FormState> formKey,
      TextEditingController passwordController,
      TextEditingController confirmPasswordController,
      String email,
      String token) {
    return Obx(
      () => FastButton(
        text: 'updatePassword'.tr,
        onTap: () async {
          if (formKey.currentState?.validate() ?? false) {
            final success = await controller.resetPassword(
              passwordController.text,
              email: email,
            );
            if (success) {
              _showSuccessDialog();
            }
          }
        },
        isLoading: controller.isLoading.value,
      ),
    );
  }

  Widget _buildSecurityTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FastColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FastColors.success.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                size: 20,
                color: FastColors.success,
              ),
              FastSpacing.w8,
              Text(
                'passwordRequirements'.tr,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: FastColors.textPrimary,
                ),
              ),
            ],
          ),
          FastSpacing.h8,
          _buildRequirement('atLeast8Chars'.tr),
          _buildRequirement('oneUppercase'.tr),
          _buildRequirement('oneLowercase'.tr),
          _buildRequirement('oneNumber'.tr),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          FastSpacing.w24,
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: FastColors.success,
          ),
          FastSpacing.w8,
          Text(
            text,
            style: Get.textTheme.bodySmall?.copyWith(
              color: FastColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: FastColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: FastColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: FastColors.success,
                ),
              ),
              FastSpacing.h24,
              Text(
                'passwordUpdated'.tr,
                style: Get.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: FastColors.textPrimary,
                ),
              ),
              FastSpacing.h8,
              Text(
                'passwordUpdatedMessage'.tr,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: FastColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              FastSpacing.h24,
              SizedBox(
                width: double.infinity,
                child: FastButton(
                  text: 'continueToSignIn'.tr,
                  onTap: () {
                    Get.offAllNamed(AppRoutes.signIn);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
