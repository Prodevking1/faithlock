import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:faithlock/shared/widgets/typography/fast_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Dialog to select unlock duration after prayer
class UnlockDurationDialog {
  static Future<Duration?> show({
    required BuildContext context,
  }) async {
    return await showCupertinoModalPopup<Duration>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) => const _UnlockDurationSheet(),
    );
  }
}

class _UnlockDurationSheet extends StatelessWidget {
  const _UnlockDurationSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // Header with Judah proud
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: FastColors.separator(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const JudahMascot(
                      state: JudahState.proud,
                      size: JudahSize.m,
                      showMessage: false,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FastText.title1(
                            'Unlock apps',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'For how long?',
                            style: TextStyle(
                              fontSize: 14,
                              color: FastColors.secondaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: FastColors.secondaryText(context),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Duration options
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildDurationTile(
                      context: context,
                      icon: '⚡',
                      title: '1 minute',
                      subtitle: 'Quick task',
                      duration: const Duration(minutes: 1),
                    ),
                    _buildDurationTile(
                      context: context,
                      icon: '⏱️',
                      title: '5 minutes',
                      subtitle: 'Short break',
                      duration: const Duration(minutes: 5),
                    ),
                    _buildDurationTile(
                      context: context,
                      icon: '⏲️',
                      title: '10 minutes',
                      subtitle: 'Focused work',
                      duration: const Duration(minutes: 10),
                    ),
                    _buildDurationTile(
                      context: context,
                      icon: '⏰',
                      title: '30 minutes',
                      subtitle: 'Focus session',
                      duration: const Duration(minutes: 30),
                    ),
                    _buildDurationTile(
                      context: context,
                      icon: '🌙',
                      title: 'For the rest of the day',
                      subtitle: 'Until midnight',
                      duration: _getDurationUntilMidnight(),
                    ),
                    _buildCustomDurationTile(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationTile({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required Duration duration,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => Navigator.pop(context, duration),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: FastColors.separator(context),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: OnboardingTheme.goldColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: FastColors.primaryText(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: FastColors.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 20,
              color: FastColors.tertiaryText(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDurationTile(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showCustomDurationPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: FastColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.time,
                  size: 24,
                  color: FastColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom duration',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: FastColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Choose a specific duration',
                    style: TextStyle(
                      fontSize: 14,
                      color: FastColors.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 20,
              color: FastColors.tertiaryText(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDurationPicker(BuildContext context) {
    int selectedMinutes = 15;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 280,
        padding: const EdgeInsets.only(top: 6.0),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Custom Duration',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(
                          context, Duration(minutes: selectedMinutes));
                    },
                  ),
                ],
              ),
              // Picker
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    selectedMinutes = index + 1;
                  },
                  children: List.generate(
                    1440,
                    (index) => Center(
                      child: Text(
                        '${index + 1} minute${index + 1 > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Duration _getDurationUntilMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }
}
