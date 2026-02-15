import 'package:faithlock/features/faithlock/models/badge_model.dart';
import 'package:faithlock/features/faithlock/models/badge_definitions.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// Shows mascot-powered gamification dialogs
class GamificationDialogService {
  GamificationDialogService._();

  /// Show dialog when streak freeze saves the streak
  static Future<void> showStreakFreezeSaved({
    required BuildContext context,
    required int currentStreak,
    required int freezesRemaining,
  }) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Column(
          children: [
            const JudahMascot(
              state: JudahState.happy,
              size: JudahSize.l,
              showMessage: false,
            ),
            const SizedBox(height: 8),
            Text('gamification_streakSaved'.tr),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'gamification_streakSavedMsg'.trParams({
              'count': '$currentStreak',
              'remaining': '$freezesRemaining',
              'suffix': freezesRemaining == 1 ? '' : 's',
            }),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: Text('gamification_awesome'.tr),
          ),
        ],
      ),
    );
  }

  /// Show dialog when streak is lost (no freeze available)
  static Future<void> showStreakLost({
    required BuildContext context,
    required int lostStreak,
  }) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Column(
          children: [
            const JudahMascot(
              state: JudahState.sad,
              size: JudahSize.l,
              showMessage: false,
            ),
            const SizedBox(height: 8),
            Text('gamification_streakReset'.tr),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            lostStreak > 1
                ? 'gamification_streakLostMsg'.trParams({
                    'count': '$lostStreak',
                  })
                : 'gamification_streakLostNewMsg'.tr,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: Text('gamification_letsGo'.tr),
          ),
        ],
      ),
    );
  }

  /// Show dialog when a badge is earned
  static Future<void> showBadgeEarned({
    required BuildContext context,
    required Badge badge,
  }) async {
    final mascotState = badge.category == BadgeCategory.streak ||
            badge.category == BadgeCategory.verses
        ? JudahState.proud
        : JudahState.happy;

    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Column(
          children: [
            JudahMascot(
              state: mascotState,
              size: JudahSize.l,
              showMessage: false,
            ),
            const SizedBox(height: 8),
            Text('${badge.emoji} ${badge.translatedName}'),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'gamification_achievementUnlocked'.trParams({
              'description': badge.translatedDescription,
            }),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: Text('gamification_awesome'.tr),
          ),
        ],
      ),
    );
  }

  /// Show multiple badge dialogs sequentially
  static Future<void> showBadgesEarned({
    required BuildContext context,
    required List<Badge> badges,
  }) async {
    for (final badge in badges) {
      if (!context.mounted) return;
      await showBadgeEarned(context: context, badge: badge);
    }
  }
}
