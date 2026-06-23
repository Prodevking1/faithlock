import 'package:faithlock/features/faithlock/controllers/stats_controller.dart';
import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/prayer_audio/screens/prayer_library_screen.dart';
import 'package:faithlock/services/storage/preferences_service.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:faithlock/shared/widgets/cozy/cozy.dart';

// ─── Gold chip icon widget (replaces all emoji icons) ────────────────────────

/// A gold-tinted rounded-square chip housing a single Cupertino icon.
/// 38×38, radius 12, ~14 % gold alpha background, 20 px gold icon.
class _GoldIconChip extends StatelessWidget {
  const _GoldIconChip({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: OnboardingTheme.goldColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          icon,
          color: OnboardingTheme.goldColor,
          size: 20,
        ),
      ),
    );
  }
}

// ─── Premium compact stat tile ────────────────────────────────────────────────

class _CompactStatTile extends StatefulWidget {
  const _CompactStatTile({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  State<_CompactStatTile> createState() => _CompactStatTileState();
}

class _CompactStatTileState extends State<_CompactStatTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 0.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardBase = CupertinoColors.tertiarySystemGroupedBackground
        .resolveFrom(context); // #2C2C2E

    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) => _press.reverse(),
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cardBase,
                Color.lerp(cardBase, Colors.black, 0.08)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _GoldIconChip(icon: widget.icon),
              const SizedBox(height: 14),
              Text(
                widget.value,
                style: TextStyle(
                  fontFamily: OnboardingTheme.fontFamily,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.label.resolveFrom(context),
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: OnboardingTheme.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: OnboardingTheme.goldColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Main Today/Home Screen ───────────────────────────────────────────────────

/// Premium "Today" home screen — greeting + mascot + daily verse + compact stats
/// + primary action. Native iOS Cupertino design with gold/black editorial feel.
class StatsDashboardScreen extends StatefulWidget {
  const StatsDashboardScreen({super.key});

  @override
  State<StatsDashboardScreen> createState() => _StatsDashboardScreenState();
}

class _StatsDashboardScreenState extends State<StatsDashboardScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final StatsController controller;

  // Entrance animation
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    controller = Get.put(StatsController());
    WidgetsBinding.instance.addObserver(this);

    // Entrance fade + slide
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.loadStats();
      await controller.loadLockedAppsCount();
      _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.loadStats();
      controller.loadLockedAppsCount();
      controller.loadFreezeState();
      controller.loadEarnedBadges();
    }
  }

  // ─── Judah state helpers (preserved) ─────────────────────────────────────

  JudahState _getJudahState() {
    final streak = controller.userStats.value?.currentStreak ?? 0;
    final previousStreak = controller.userStats.value?.longestStreak ?? 0;
    if (streak == 0 && previousStreak > 0) return JudahState.sad;
    if (streak >= 7) return JudahState.proud;
    final hour = DateTime.now().hour;
    if (hour >= 20) return JudahState.praying;
    return JudahState.neutral;
  }

  String _getGreetingLine() {
    final hour = DateTime.now().hour;
    final name = controller.userName.value.isNotEmpty
        ? controller.userName.value
        : 'friend'.tr;
    if (hour < 12) return 'Good morning, $name';
    if (hour < 17) return 'Good afternoon, $name';
    if (hour < 21) return 'Good evening, $name';
    return 'Good night, $name';
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: OnboardingTheme.goldColor,
      ),
      child: Builder(
        builder: (context) {
          return CupertinoPageScaffold(
            backgroundColor:
                CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
              context,
            ),
            child: SafeArea(
              bottom: false,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CupertinoActivityIndicator(
                      color: OnboardingTheme.goldColor,
                      radius: 14,
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_circle,
                          size: 52,
                          color: OnboardingTheme.goldColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value,
                          style: OnboardingTheme.subhead,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // ── Large-title nav bar (liquid glass / system blur) ──
                        CupertinoSliverNavigationBar(
                          largeTitle: Text(
                            'Today',
                            style: TextStyle(
                              fontFamily: OnboardingTheme.fontFamily,
                              color:
                                  CupertinoColors.label.resolveFrom(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OnboardingTheme.horizontalPadding,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // ── Ambient gold aurora ─────────────────────
                              _buildAuroraGreetingSection(context),
                              const SizedBox(height: 16),

                              // ── 2. Today's verse hero card ───────────────
                              _buildVerseCard(context),
                              const SizedBox(height: 20),

                              // ── 3. Premium stat pair ─────────────────────
                              _buildCompactStats(context),
                              const SizedBox(height: 24),

                              // ── 4. Primary action CTA ────────────────────
                              _buildPrimaryAction(),
                              // Extra bottom clearance so the CTA sits fully
                              // above the floating Liquid Glass tab bar.
                              // Tab bar ≈ 68 px + safe-area ≈ 34 px + margin.
                              const SizedBox(height: 110),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  // ─── 1. Aurora + greeting + mascot ───────────────────────────────────────

  Widget _buildAuroraGreetingSection(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Ambient radial gold aurora — IgnorePointer so it never intercepts taps
        Positioned(
          top: -30,
          left: -40,
          child: IgnorePointer(
            child: Container(
              width: 260,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x1FC9A962), // ~12 % gold at centre
                    Color(0x00C9A962), // fully transparent at edge
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Greeting row on top of aurora
        _buildGreetingRow(context),
      ],
    );
  }

  Widget _buildGreetingRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mascot with soft gold halo + 1 px gold ring
        Stack(
          alignment: Alignment.center,
          children: [
            // Faint radial gold halo behind mascot
            IgnorePointer(
              child: Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x22C9A962), // ~13 % gold
                      Color(0x00C9A962),
                    ],
                    stops: [0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Mascot with gold ring border + glow shadow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: OnboardingTheme.goldColor.withValues(alpha: 0.40),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: OnboardingTheme.goldColor.withValues(alpha: 0.18),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: JudahMascot(
                state: _getJudahState(),
                size: JudahSize.m,
                showMessage: false,
                circular: true,
              ),
            ),
          ],
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreetingLine(),
                style: TextStyle(
                  fontFamily: OnboardingTheme.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.label.resolveFrom(context),
                  height: 1.15,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.getJourneyText(),
                style: OnboardingTheme.callout.copyWith(
                  color:
                      CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── 2. Verse of the Day — hero card ─────────────────────────────────────

  Widget _buildVerseCard(BuildContext context) {
    final cardBase = CupertinoColors.tertiarySystemGroupedBackground
        .resolveFrom(context); // #2C2C2E

    return Obx(() {
      final verse = controller.dailyVerse.value;
      final isFavorite = controller.isDailyVerseFavorite.value;

      if (verse == null) {
        return Container(
          height: 170,
          decoration: BoxDecoration(
            color: cardBase,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Center(
            child: CupertinoActivityIndicator(
              color: OnboardingTheme.goldColor,
              radius: 10,
            ),
          ),
        );
      }

      // Use a plain Container (no AnimatedContainer) so it sizes to its content
      // immediately without animating from zero height — which was causing the
      // giant empty dark box on first render.
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardBase, // #2C2C2E
              Color.lerp(cardBase, const Color(0xFF1A1A1C), 0.55)!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(22),
          // 3 px gold left-accent bar
          border: const Border(
            left: BorderSide(
              color: OnboardingTheme.goldColor,
              width: 3,
            ),
            top: BorderSide(
              color: Color(0x40C9A962), // 25 % gold hairline
              width: 0.5,
            ),
            right: BorderSide(
              color: Color(0x10FFFFFF),
              width: 0.5,
            ),
            bottom: BorderSide(
              color: Color(0x10FFFFFF),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        // Stack: decorative quote mark sits BEHIND content via Positioned;
        // the Stack sizes to the non-positioned Padding child (content).
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Decorative oversized quotation mark — Positioned so it never
            // participates in layout and cannot push/clip the real content.
            Positioned(
              top: 6,
              left: 14,
              child: IgnorePointer(
                child: Text(
                  '“',
                  style: TextStyle(
                    fontFamily: OnboardingTheme.fontFamily,
                    fontSize: 90,
                    fontWeight: FontWeight.w900,
                    color: OnboardingTheme.goldColor.withValues(alpha: 0.10),
                    height: 1.0,
                  ),
                ),
              ),
            ),

            // Real card content — the Stack sizes to this widget.
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Section label + bookmark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'VERSE OF THE DAY',
                        style: TextStyle(
                          fontFamily: OnboardingTheme.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: OnboardingTheme.goldColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      // Refined bookmark button
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          controller.toggleDailyVerseFavorite();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            isFavorite
                                ? CupertinoIcons.bookmark_fill
                                : CupertinoIcons.bookmark,
                            color: isFavorite
                                ? OnboardingTheme.goldColor
                                : CupertinoColors.tertiaryLabel
                                    .resolveFrom(context),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Verse text — Satoshi italic, generous line height
                  Text(
                    '“${verse.text}”',
                    style: const TextStyle(
                      fontFamily: OnboardingTheme.fontFamily,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: OnboardingTheme.beigeColor,
                      height: 1.55,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Gold 24 px rule line
                  Container(
                    width: 24,
                    height: 1.5,
                    decoration: const BoxDecoration(
                      color: OnboardingTheme.goldColor,
                      borderRadius: BorderRadius.all(Radius.circular(1)),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Reference — title case, letter-spaced, gold, w700.
                  // Consistent with reading screen / verse library / home.
                  Text(
                    verse.reference,
                    style: const TextStyle(
                      fontFamily: OnboardingTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: OnboardingTheme.goldColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─── 3. Premium stat pair ─────────────────────────────────────────────────

  Widget _buildCompactStats(BuildContext context) {
    return Obx(() {
      final stats = controller.userStats.value;
      final timeSaved = stats?.screenTimeReducedFormatted ?? '0 min';
      final versesRead = '${stats?.totalVersesRead ?? 0}';

      return Row(
        children: [
          Expanded(
            child: _CompactStatTile(
              value: timeSaved,
              label: 'timeSaved'.tr,
              icon: CupertinoIcons.clock_fill, // replaces ⏱️
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CompactStatTile(
              value: versesRead,
              label: 'versesRead'.tr,
              icon: CupertinoIcons.book_fill, // replaces 📖
            ),
          ),
        ],
      );
    });
  }

  // ─── 4. Primary action CTA ────────────────────────────────────────────────

  Widget _buildPrimaryAction() {
    return Obx(() {
      final lockedCount = controller.lockedAppsCount.value;
      final hasApps = lockedCount > 0;

      return _AnimatedCTAButton(
        hasApps: hasApps,
        onTap: () async {
          HapticFeedback.mediumImpact();

          final prefs = PreferencesService();
          // Honor a remembered preference and skip the sheet. Only 'audio' is
          // remembered for now — textual is still "coming soon", so we never
          // trap the user on an unfinished destination.
          String? choice = await prefs.readString(_kPrayerModePrefKey);

          if (choice == null) {
            final result = await showPrayerModeSelector();
            if (result == null) return; // dismissed
            choice = result.mode;
            if (result.remember && choice == 'audio') {
              await prefs.writeString(_kPrayerModePrefKey, choice);
            }
          }

          if (choice == 'audio') {
            await Get.to(
              () => const PrayerLibraryScreen(),
              transition: Transition.cupertino,
              duration: const Duration(milliseconds: 300),
            );
            controller.loadStats();
            controller.loadLockedAppsCount();
          } else if (choice == 'text') {
            // Textual prayer experience — destination to be finalized.
            if (Get.context != null) {
              CozyToast.show(Get.context!, 'Textual prayer is on the way.');
            }
          }
        },
        onSelectApps: () async {
          HapticFeedback.lightImpact();
          await controller.openAppPicker();
        },
      );
    });
  }
}

// ─── Prayer-mode selector (full-screen, dark + gold) ──────────────────────────

/// SharedPreferences key storing the remembered prayer mode ('audio'|'text').
const String _kPrayerModePrefKey = 'prayer_mode_preference';

/// Result returned by [showPrayerModeSelector].
class PrayerModeResult {
  const PrayerModeResult({required this.mode, required this.remember});

  /// 'audio' | 'text'
  final String mode;

  /// Whether the user asked us to remember this choice.
  final bool remember;
}

/// Presents the full-screen prayer-mode selector. Slides up as a modal page and
/// returns null when dismissed.
Future<PrayerModeResult?>? showPrayerModeSelector() {
  return Get.to<PrayerModeResult>(
    () => const _PrayerModeScreen(),
    fullscreenDialog: true,
    transition: Transition.downToUp,
    duration: const Duration(milliseconds: 350),
  );
}

class _PrayerModeScreen extends StatefulWidget {
  const _PrayerModeScreen();

  @override
  State<_PrayerModeScreen> createState() => _PrayerModeScreenState();
}

class _PrayerModeScreenState extends State<_PrayerModeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  bool _remember = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _pick(String mode) {
    HapticFeedback.mediumImpact();
    Get.back(result: PrayerModeResult(mode: mode, remember: _remember));
  }

  /// Staggered fade + rise for entrance polish.
  Widget _entrance(int order, Widget child) {
    final start = (order * 0.1).clamp(0.0, 0.6);
    final anim = CurvedAnimation(
      parent: _intro,
      curve: Interval(
        start,
        (start + 0.55).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position:
            Tween(begin: const Offset(0, 0.14), end: Offset.zero).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141416),
      body: Stack(
        children: [
          // Ambient gold glow, top.
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      OnboardingTheme.goldColor.withValues(alpha: 0.18),
                      OnboardingTheme.goldColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              OnboardingTheme.goldColor.withValues(alpha: 0.08),
                          border: Border.all(
                            color: OnboardingTheme.goldColor
                                .withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Icon(
                          CupertinoIcons.xmark,
                          size: 16,
                          color: OnboardingTheme.labelSecondary,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  _entrance(0, const _PrayingHalo()),
                  const SizedBox(height: 28),
                  _entrance(
                    1,
                    Text(
                      'How would you\nlike to pray?',
                      textAlign: TextAlign.center,
                      style: OnboardingTheme.largeTitle.copyWith(
                        fontSize: 34,
                        height: 1.1,
                        color: OnboardingTheme.labelPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _entrance(
                    2,
                    Text(
                      'Pick the one that feels right for you today.',
                      textAlign: TextAlign.center,
                      style: OnboardingTheme.callout.copyWith(
                        color: OnboardingTheme.labelSecondary,
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  _entrance(
                    3,
                    _PrayerModeCard(
                      icon: CupertinoIcons.waveform,
                      title: 'Audio prayer',
                      subtitle: 'Listen and pray along, gently guided.',
                      onTap: () => _pick('audio'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _entrance(
                    4,
                    _PrayerModeCard(
                      icon: CupertinoIcons.book,
                      title: 'Textual prayer',
                      subtitle: 'Read a written prayer in your own words.',
                      onTap: () => _pick('text'),
                    ),
                  ),
                  const Spacer(flex: 2),
                  _entrance(
                    5,
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _remember = !_remember),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Remember my preference',
                                style: OnboardingTheme.subhead.copyWith(
                                  color: OnboardingTheme.labelSecondary,
                                ),
                              ),
                            ),
                            CupertinoSwitch(
                              value: _remember,
                              activeTrackColor: OnboardingTheme.goldColor,
                              onChanged: (v) => setState(() => _remember = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Praying-Judah avatar inside a glowing gold halo.
class _PrayingHalo extends StatelessWidget {
  const _PrayingHalo();

  @override
  Widget build(BuildContext context) {
    const halo = 150.0;
    const inner = 108.0;
    return SizedBox(
      width: halo,
      height: halo,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: halo,
            height: halo,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  OnboardingTheme.goldColor.withValues(alpha: 0.35),
                  OnboardingTheme.goldColor.withValues(alpha: 0),
                ],
                stops: const [0.45, 1.0],
              ),
            ),
          ),
          Container(
            width: inner,
            height: inner,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: OnboardingTheme.goldColor.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: OnboardingTheme.goldColor.withValues(alpha: 0.4),
                  blurRadius: 26,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: Transform.scale(
                scale: 1.08,
                child: const JudahMascot(
                  state: JudahState.praying,
                  size: JudahSize.l,
                  showMessage: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large pressable prayer-mode card with a gold glow and press feedback.
class _PrayerModeCard extends StatefulWidget {
  const _PrayerModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_PrayerModeCard> createState() => _PrayerModeCardState();
}

class _PrayerModeCardState extends State<_PrayerModeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                OnboardingTheme.goldColor.withValues(alpha: 0.14),
                OnboardingTheme.goldColor.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: OnboardingTheme.goldColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: OnboardingTheme.goldColor.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      OnboardingTheme.goldColor,
                      Color(0xFFD9C089),
                    ],
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: OnboardingTheme.backgroundColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: OnboardingTheme.title3.copyWith(
                        color: OnboardingTheme.labelPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: OnboardingTheme.subhead.copyWith(
                        color: OnboardingTheme.labelSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: OnboardingTheme.goldColor.withValues(alpha: 0.16),
                ),
                child: const Icon(
                  CupertinoIcons.arrow_right,
                  size: 15,
                  color: OnboardingTheme.goldColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Animated CTA button with press scale ─────────────────────────────────────

class _AnimatedCTAButton extends StatefulWidget {
  const _AnimatedCTAButton({
    required this.hasApps,
    required this.onTap,
    required this.onSelectApps,
  });

  final bool hasApps;
  final VoidCallback onTap;
  final VoidCallback onSelectApps;

  @override
  State<_AnimatedCTAButton> createState() => _AnimatedCTAButtonState();
}

class _AnimatedCTAButtonState extends State<_AnimatedCTAButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _press, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFD4B46A), // slightly lighter gold at top
                OnboardingTheme.goldColor,
                Color(0xFFB8943A), // deeper amber at bottom
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.45, 1.0],
            ),
            borderRadius: BorderRadius.circular(29),
            boxShadow: [
              BoxShadow(
                color: OnboardingTheme.goldColor.withValues(alpha: 0.40),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: OnboardingTheme.goldColor.withValues(alpha: 0.12),
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Refined Cupertino icon — no emoji
              const Icon(
                CupertinoIcons.hand_raised_fill, // replaces 🙏
                color: OnboardingTheme.backgroundColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'letsPrayNow'.tr,
                style: const TextStyle(
                  fontFamily: OnboardingTheme.fontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: OnboardingTheme.backgroundColor,
                  letterSpacing: 0.1,
                ),
              ),
              // Cleaner secondary "Select Apps" chip when no apps locked
              if (!widget.hasApps) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: (widget.onSelectApps),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.10),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.app_badge,
                          color: OnboardingTheme.backgroundColor,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'selectApps'.tr,
                          style: const TextStyle(
                            fontFamily: OnboardingTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: OnboardingTheme.backgroundColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
