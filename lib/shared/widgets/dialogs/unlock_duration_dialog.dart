import 'package:faithlock/shared/widgets/cozy/cozy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

/// Cozy bottom sheet to select how long the apps stay unlocked after a prayer /
/// quiz. Chunky, warm styling to match the rest of the FaithLock cozy UI.
class UnlockDurationDialog {
  static Future<Duration?> show({
    required BuildContext context,
  }) async {
    return await showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: CozyColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(CozyTokens.radiusLg)),
      ),
      builder: (BuildContext context) => const _UnlockDurationSheet(),
    );
  }
}

class _UnlockDurationSheet extends StatelessWidget {
  const _UnlockDurationSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('unlock_unlockApps'.tr, style: CozyText.title),
                      const SizedBox(height: 4),
                      Text('unlock_forHowLong'.tr, style: CozyText.subtitle),
                    ],
                  ),
                ),
                CozyTappable(
                  onTap: () => Navigator.pop(context),
                  pressedScale: 0.96,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, top: 2),
                    child: Text(
                      'cancel'.tr,
                      style: CozyText.body.copyWith(color: CozyColors.inkMuted),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            _durationCard(
              context: context,
              icon: HugeIcons.strokeRoundedFlash,
              iconBg: CozyColors.gold.withValues(alpha: 0.3),
              title: 'unlock_1min'.tr,
              subtitle: 'unlock_quickTask'.tr,
              duration: const Duration(minutes: 1),
            ),
            const SizedBox(height: 12),
            _durationCard(
              context: context,
              icon: HugeIcons.strokeRoundedCoffee01,
              iconBg: CozyColors.peach,
              title: 'unlock_5min'.tr,
              subtitle: 'unlock_shortBreak'.tr,
              duration: const Duration(minutes: 5),
            ),
            const SizedBox(height: 12),
            _durationCard(
              context: context,
              icon: HugeIcons.strokeRoundedClock01,
              iconBg: CozyColors.sage,
              title: 'unlock_10min'.tr,
              subtitle: 'unlock_focusedWork'.tr,
              duration: const Duration(minutes: 10),
            ),
            const SizedBox(height: 12),
            _durationCard(
              context: context,
              icon: HugeIcons.strokeRoundedAlarmClock,
              iconBg: CozyColors.surfaceMuted,
              title: 'unlock_30min'.tr,
              subtitle: 'unlock_focusSession'.tr,
              duration: const Duration(minutes: 30),
            ),
            const SizedBox(height: 12),
            _durationCard(
              context: context,
              icon: HugeIcons.strokeRoundedMoon02,
              iconBg: CozyColors.primaryLight,
              title: 'unlock_restOfDay'.tr,
              subtitle: 'unlock_untilMidnight'.tr,
              duration: _getDurationUntilMidnight(),
            ),
            const SizedBox(height: 12),
            _durationCard(
              context: context,
              icon: HugeIcons.strokeRoundedTime04,
              iconBg: CozyColors.primary.withValues(alpha: 0.16),
              title: 'unlock_customDuration'.tr,
              subtitle: 'unlock_chooseSpecific'.tr,
              accent: true,
              onTap: () => _showCustomDurationPicker(context),
            ),
          ],
        ),
      ),
    );
  }

  /// A single chunky duration row. Provide either [duration] (pops the sheet
  /// with it) or a custom [onTap].
  Widget _durationCard({
    required BuildContext context,
    required List<List<dynamic>> icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    Duration? duration,
    VoidCallback? onTap,
    bool accent = false,
  }) {
    return CozyCard(
      onTap: onTap ?? () => Navigator.pop(context, duration),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CozyIconChip(
            icon: icon,
            iconColor: CozyColors.ink,
            background: iconBg,
            bordered: false,
            size: 44,
            iconSize: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CozyText.heading.copyWith(
                    fontSize: 17,
                    color: accent ? CozyColors.primary : CozyColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: CozyText.subtitle),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight01,
            color: CozyColors.inkMuted,
            size: 22,
          ),
        ],
      ),
    );
  }

  void _showCustomDurationPicker(BuildContext context) {
    int selectedMinutes = 15;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CozyColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(CozyTokens.radiusLg)),
      ),
      builder: (BuildContext context) => SafeArea(
        top: false,
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CozyTappable(
                      onTap: () => Navigator.pop(context),
                      pressedScale: 0.96,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'cancel'.tr,
                          style: CozyText.body
                              .copyWith(color: CozyColors.inkMuted),
                        ),
                      ),
                    ),
                    Text('unlock_customTitle'.tr, style: CozyText.heading),
                    CozyTappable(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(
                            context, Duration(minutes: selectedMinutes));
                      },
                      pressedScale: 0.96,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'ok'.tr,
                          style: CozyText.body.copyWith(
                            color: CozyColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController:
                      FixedExtentScrollController(initialItem: 14),
                  onSelectedItemChanged: (int index) {
                    selectedMinutes = index + 1;
                  },
                  children: List.generate(
                    1440,
                    (index) => Center(
                      child: Text(
                        '${index + 1} minute${(index + 1) > 1 ? 's' : ''}',
                        style: CozyText.body,
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
