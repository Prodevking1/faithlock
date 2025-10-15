import 'dart:async';

import 'package:faithlock/app_routes.dart';
import 'package:faithlock/core/constants/export.dart';
import 'package:faithlock/features/auth/controllers/reset_password_controller.dart';
import 'package:faithlock/shared/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class VerifyOtpScreen extends GetView<PasswordController> {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PasswordController());
    final args = Get.arguments as Map<String, dynamic>;
    final email = args['email'] as String;

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
                          _buildHeader(email),
                          FastSpacing.h32,
                          _buildOtpInput(),
                          FastSpacing.h24,
                          _buildResendSection(email, controller),
                          FastSpacing.h32,
                          _buildVerifyButton(controller, email),
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
              onTap: () => Get.back(),
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
                    'recoveryEmail'.tr,
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
                    Icons.mark_email_read_outlined,
                    size: 48,
                  ),
                ),
                FastSpacing.h24,
                Text(
                  'checkYourEmail'.tr,
                  style: Get.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                FastSpacing.h8,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'verificationCodeSentMessage'.tr,
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

  Widget _buildHeader(String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'enterVerificationCode'.tr,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: FastColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        FastSpacing.h8,
        RichText(
          text: TextSpan(
            style: Get.textTheme.bodyLarge?.copyWith(
              color: FastColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            children: [
              TextSpan(text: 'weSent6DigitCode'.tr + ' '),
              TextSpan(
                text: email,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: FastColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return _OtpInputWidget();
  }

  Widget _buildResendSection(String email, PasswordController controller) {
    return _ResendTimerWidget(
      email: email,
      controller: controller,
    );
  }

  Widget _buildVerifyButton(PasswordController controller, String email) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                FastColors.info,
                FastColors.info.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: FastColors.info.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FastButton(
            text: 'verifyCode'.tr,
            onTap: () async {
              _OtpInputController? otpController;
              try {
                otpController = Get.find<_OtpInputController>();
              } catch (e) {
                otpController = _OtpInputController.instance;
              }

              final otp = otpController?.getOtp() ?? '';

              if (otp.length == 6) {
                final success =
                    await controller.verifyCode(otp, email: email);
                if (success) {
                  Get.toNamed(AppRoutes.newPassword, arguments: {
                    'email': email,
                    'token': otp,
                  });
                }
              } else {
                Get.snackbar('error'.tr, 'enterValid6DigitCode'.tr);
              }
            },
            isLoading: controller.isLoading.value,
          ),
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
            Icons.help_outline,
            size: 20,
            color: FastColors.info,
          ),
          FastSpacing.w8,
          Expanded(
            child: Text(
              'didntReceiveCodeMessage'.tr,
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

// OTP Input Widget
class _OtpInputWidget extends StatefulWidget {
  @override
  State<_OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<_OtpInputWidget> {
  late _OtpInputController controller;

  @override
  void initState() {
    super.initState();
    // Use a unique tag to avoid conflicts
    final tag = 'otp_${DateTime.now().millisecondsSinceEpoch}';
    controller = Get.put(_OtpInputController(), tag: tag);
  }

  @override
  void dispose() {
    // Clean up the controller
    Get.delete<_OtpInputController>(
        tag: 'otp_${DateTime.now().millisecondsSinceEpoch}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return _buildOtpBox(index);
      }),
    );
  }

  Widget _buildOtpBox(int index) {
    return GestureDetector(
        onTap: () => controller.focusOnField(index),
        child: Container(
          width: 50,
          height: 60,
          child: Center(
            child: TextField(
              controller: controller.controllers[index],
              focusNode: controller.focusNodes[index],
              textAlign: TextAlign.center,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: FastColors.textPrimary,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) => controller.onFieldChanged(index, value),
            ),
          ),
        ));
  }
}

// OTP Input Controller
class _OtpInputController extends GetxController {
  static _OtpInputController? _instance;
  static _OtpInputController? get instance => _instance;

  final List<TextEditingController> controllers = [];
  final List<FocusNode> focusNodes = [];
  final RxInt currentFocus = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _instance = this;
    for (int i = 0; i < 6; i++) {
      controllers.add(TextEditingController());
      focusNodes.add(FocusNode());
    }

    // Add paste detection to first field
    controllers[0].addListener(_handlePaste);
  }

  void _handlePaste() {
    String text = controllers[0].text;
    if (text.length > 1) {
      // Clear all fields first
      for (int i = 0; i < 6; i++) {
        controllers[i].clear();
      }

      // Distribute digits across fields
      for (int i = 0; i < text.length && i < 6; i++) {
        if (RegExp(r'^\d$').hasMatch(text[i])) {
          controllers[i].text = text[i];
        }
      }
      // Focus on next empty field or last field
      int nextIndex = text.length < 6 ? text.length : 5;
      focusOnField(nextIndex);
    }
  }

  void onFieldChanged(int index, String value) {
    // Handle paste detection for any field
    if (value.length > 1) {
      // Extract only digits
      String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

      // Clear all fields first
      for (int i = 0; i < 6; i++) {
        controllers[i].clear();
      }

      // Distribute digits across fields starting from current index
      for (int i = 0; i < digits.length && (index + i) < 6; i++) {
        controllers[index + i].text = digits[i];
      }

      // Focus on next empty field or last field
      int nextIndex = index + digits.length;
      if (nextIndex >= 6) nextIndex = 5;
      focusOnField(nextIndex);
      return;
    }

    // Normal single character input
    if (value.isNotEmpty) {
      // Ensure only one character
      if (value.length > 1) {
        controllers[index].text = value[0];
        return;
      }

      // Move to next field
      if (index < 5) {
        focusOnField(index + 1);
      } else {
        // Last field, remove focus
        focusNodes[index].unfocus();
      }
    } else {
      // Field cleared, move to previous field
      if (index > 0) {
        focusOnField(index - 1);
      }
    }
  }

  void focusOnField(int index) {
    currentFocus.value = index;
    if (index >= 0 && index < 6) {
      focusNodes[index].requestFocus();
    }
  }

  String getOtp() {
    return controllers.map((controller) => controller.text).join('');
  }

  @override
  void onClose() {
    _instance = null;
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.onClose();
  }
}

// Resend Timer Widget
class _ResendTimerWidget extends StatefulWidget {
  final String email;
  final PasswordController controller;

  const _ResendTimerWidget({
    required this.email,
    required this.controller,
  });

  @override
  State<_ResendTimerWidget> createState() => _ResendTimerWidgetState();
}

class _ResendTimerWidgetState extends State<_ResendTimerWidget> {
  Timer? _timer;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _countdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'didntReceiveCode'.tr + ' ',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: FastColors.textSecondary,
          ),
        ),
        if (_canResend)
          GestureDetector(
            onTap: () async {
              await widget.controller.sendResetPasswordEmail(widget.email);
              _startTimer();
            },
            child: Text(
              'resend'.tr,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: FastColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: FastColors.primary,
              ),
            ),
          )
        else
          Text(
            'resendIn'.tr + ' ${_countdown}s',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: FastColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
