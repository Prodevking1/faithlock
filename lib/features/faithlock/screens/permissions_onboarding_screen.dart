import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:faithlock/core/constants/core/fast_spacing.dart';
import 'package:faithlock/features/faithlock/services/screen_time_service.dart';
import 'package:faithlock/navigation/screens/main_screen.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/notifications/fast_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Permissions Onboarding Screen
/// Request Screen Time permission on first launch
class PermissionsOnboardingScreen extends StatefulWidget {
  const PermissionsOnboardingScreen({super.key});

  @override
  State<PermissionsOnboardingScreen> createState() =>
      _PermissionsOnboardingScreenState();
}

class _PermissionsOnboardingScreenState
    extends State<PermissionsOnboardingScreen> {
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  bool _isRequesting = false;

  Future<void> _requestPermission() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      await _screenTimeService.requestAuthorization();
      await Future.delayed(const Duration(milliseconds: 500));

      final isAuthorized = await _screenTimeService.isAuthorized();

      if (mounted) {
        setState(() {
          _isRequesting = false;
        });

        if (isAuthorized) {
          FastToast.showSuccess(
            context: context,
            message: "Screen Time access enabled successfully!",
          );
          await Future.delayed(const Duration(milliseconds: 500));
          Get.offAll(() => MainScreen());
        } else {
          FastToast.showError(
            context: context,
            message: "Permission denied. Enable it in Settings.",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
        FastToast.showError(
          context: context,
          message: "Failed to request permission",
        );
      }
    }
  }

  void _skipForNow() {
    Get.offAll(() => MainScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FastColors.surface(context),
      body: SafeArea(
        child: Padding(
          padding: FastSpacing.px24,
          child: Column(
            children: [
              const Spacer(),

              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: FastColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.lock_shield_fill,
                  size: 64,
                  color: FastColors.primary,
                ),
              ),

              FastSpacing.h32,

              // Title
              Text(
                'Enable Screen Time',
                style: TextStyle(
                  color: FastColors.primaryText(context),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              FastSpacing.h16,

              // Description
              Text(
                'FaithLock needs Screen Time access to help you stay focused on your spiritual growth by managing app usage during scheduled times.',
                style: TextStyle(
                  color: FastColors.secondaryText(context),
                  fontSize: 17,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              FastSpacing.h32,

              // Features list
              // _buildFeature(
              //   context,
              //   icon: CupertinoIcons.time,
              //   title: 'Schedule Lock Times',
              //   description: 'Set specific times to block distracting apps',
              // ),

              // FastSpacing.h16,

              // _buildFeature(
              //   context,
              //   icon: CupertinoIcons.book,
              //   title: 'Bible Verse Quizzes',
              //   description: 'Answer questions to unlock your device',
              // ),

              // FastSpacing.h16,

              // _buildFeature(
              //   context,
              //   icon: CupertinoIcons.chart_bar,
              //   title: 'Track Your Progress',
              //   description: 'Build streaks and monitor your spiritual growth',
              // ),

              // const Spacer(),

              // Grant Access button
              FastButton(
                text: _isRequesting
                    ? 'Requesting...'
                    : 'Grant Screen Time Access',
                onTap: _isRequesting ? null : _requestPermission,
                isLoading: _isRequesting,
              ),

              // FastSpacing.h16,

              // Skip button
              // CupertinoButton(
              //   onPressed: _isRequesting ? null : _skipForNow,
              //   child: Text(
              //     'Skip for Now',
              //     style: TextStyle(
              //       color: FastColors.tertiaryText(context),
              //       fontSize: 17,
              //     ),
              //   ),
              // ),

              FastSpacing.h24,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FastColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: FastColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: FastColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: FastColors.primaryText(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: FastColors.tertiaryText(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
