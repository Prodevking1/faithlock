import 'package:faithlock/features/faithlock/services/unlock_flow_service.dart';
import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/shared/widgets/cozy/cozy.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

/// First screen of the "earn back a blocked app" flow (routed from the
/// notification / shield). Lets the user choose how to unlock:
///   • Quiz — the classic verse challenge.
///   • Prayer — then Audio or Text; a prayer is matched to their mood.
///
/// If a method was remembered (set here from the 2nd unlock onward, or in
/// Profile), this screen resolves it immediately and skips straight to it.
class UnlockChooserScreen extends StatefulWidget {
  const UnlockChooserScreen({super.key});

  @override
  State<UnlockChooserScreen> createState() => _UnlockChooserScreenState();
}

class _UnlockChooserScreenState extends State<UnlockChooserScreen> {
  final UnlockFlowService _service = UnlockFlowService();
  final PostHogService _analytics = PostHogService.instance;

  void _track(String event, Map<String, dynamic> props) {
    if (_analytics.isReady) _analytics.events.trackCustom(event, props);
  }

  /// Analytics value for the chosen unlock method (`quiz`, `prayer_audio`,
  /// `prayer_text`).
  static String _methodValue(UnlockMethod m) => switch (m) {
        UnlockMethod.quiz => 'quiz',
        UnlockMethod.prayerAudio => 'prayer_audio',
        UnlockMethod.prayerText => 'prayer_text',
      };

  bool _loading = true;
  bool _offerRemember = false;
  bool _remember = false;
  bool _prayerExpanded = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final remembered = await _service.remembered();
    if (remembered != null) {
      // Skip the chooser entirely and run the saved method.
      _track('unlock_method_chosen', {
        'method': _methodValue(remembered),
        'remembered': true,
        'source': 'remembered',
      });
      await _service.start(remembered);
      return;
    }
    final count = await _service.eventCount();
    await _service.bumpEventCount();
    if (!mounted) return;
    // Always offer "Remember my choice" (shown on every unlock, incl. the first).
    const offerRemember = true;
    _track('unlock_chooser_shown', {
      'event_count': count,
      'offered_remember': offerRemember,
    });
    setState(() {
      _offerRemember = offerRemember;
      _loading = false;
    });
  }

  Future<void> _pick(UnlockMethod method) async {
    _track('unlock_method_chosen', {
      'method': _methodValue(method),
      'remembered': _remember,
      'source': 'chooser',
    });
    if (_remember) await _service.remember(method);
    await _service.start(method);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CozyColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: CozyColors.primary),
              )
            : _buildChooser(context),
      ),
    );
  }

  Widget _buildChooser(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: ConstrainedBox(
            // Fill the visible viewport (minus the 24+24 vertical padding) so the
            // column can center vertically, yet still scroll if content overflows.
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
          Text(
            'unlock_chooser_title'.tr,
            style: CozyText.title.copyWith(fontSize: 30, height: 1.12),
          ),
          const SizedBox(height: 8),
          Text(
            'unlock_chooser_subtitle'.tr,
            style: CozyText.subtitle,
          ),
          const SizedBox(height: 28),

          // Quiz
          _OptionCard(
            icon: HugeIcons.strokeRoundedBookOpen01,
            iconBackground: CozyColors.sage,
            title: 'unlock_method_quiz'.tr,
            subtitle: 'unlock_quiz_sub'.tr,
            onTap: () => _pick(UnlockMethod.quiz),
          ),
          const SizedBox(height: 14),

          // Prayer (expands to Audio / Text)
          _OptionCard(
            icon: HugeIcons.strokeRoundedHandPrayer,
            iconBackground: CozyColors.peach,
            title: 'unlock_method_prayer'.tr,
            subtitle: 'unlock_prayer_sub'.tr,
            expanded: _prayerExpanded,
            showChevron: true,
            onTap: () => setState(() => _prayerExpanded = !_prayerExpanded),
          ),
          AnimatedCrossFade(
            duration: CozyTokens.base,
            crossFadeState: _prayerExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12, left: 12),
              child: Column(
                children: [
                  _SubOptionTile(
                    icon: HugeIcons.strokeRoundedHeadphones,
                    title: 'unlock_method_audio'.tr,
                    subtitle: 'unlock_audio_sub'.tr,
                    onTap: () => _pick(UnlockMethod.prayerAudio),
                  ),
                  const SizedBox(height: 10),
                  _SubOptionTile(
                    icon: HugeIcons.strokeRoundedTextFont,
                    title: 'unlock_method_text'.tr,
                    subtitle: 'unlock_text_sub'.tr,
                    onTap: () => _pick(UnlockMethod.prayerText),
                  ),
                ],
              ),
            ),
          ),

          if (_offerRemember) ...[
            const SizedBox(height: 24),
            _RememberRow(
              value: _remember,
              onChanged: (v) => setState(() => _remember = v),
            ),
            const SizedBox(height: 4),
            Text(
              'unlock_remember_hint'.tr,
              style: CozyText.label.copyWith(color: CozyColors.inkMuted),
            ),
          ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Large tappable choice card (Quiz / Prayer).
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.expanded = false,
    this.showChevron = false,
  });

  final List<List<dynamic>> icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool expanded;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return CozyCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: iconBackground,
              shape: CozyTokens.smooth(
                CozyTokens.radiusMd,
                side: const BorderSide(
                  color: CozyColors.outline,
                  width: CozyTokens.borderWidth,
                ),
              ),
            ),
            child: HugeIcon(icon: icon, color: CozyColors.ink, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CozyText.heading.copyWith(fontSize: 18)),
                const SizedBox(height: 2),
                Text(subtitle, style: CozyText.subtitle),
              ],
            ),
          ),
          if (showChevron)
            AnimatedRotation(
              duration: CozyTokens.fast,
              turns: expanded ? 0.25 : 0,
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: CozyColors.inkMuted,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }
}

/// Smaller Audio / Text sub-choice revealed under "Prayer".
class _SubOptionTile extends StatelessWidget {
  const _SubOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CozyCard(
      onTap: onTap,
      color: CozyColors.surfaceMuted,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: CozyColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: CozyText.body.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  subtitle,
                  style: CozyText.label.copyWith(color: CozyColors.inkMuted),
                ),
              ],
            ),
          ),
          const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight01,
            color: CozyColors.inkMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

/// "Remember my choice" checkbox row.
class _RememberRow extends StatelessWidget {
  const _RememberRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          AnimatedContainer(
            duration: CozyTokens.fast,
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: value ? CozyColors.primary : CozyColors.surface,
              shape: CozyTokens.smooth(
                8,
                side: const BorderSide(
                  color: CozyColors.outline,
                  width: CozyTokens.borderWidth,
                ),
              ),
            ),
            child: value
                ? const HugeIcon(
                    icon: HugeIcons.strokeRoundedTick02,
                    color: CozyColors.onPrimary,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            'unlock_remember'.tr,
            style: CozyText.body.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
