import 'dart:async';

import 'package:faithlock/features/companion/models/companion_conversation.dart';
import 'package:faithlock/features/companion/models/companion_settings.dart';
import 'package:faithlock/features/companion/screens/companion_history_screen.dart';
import 'package:faithlock/features/companion/screens/companion_settings_sheet.dart';
import 'package:faithlock/features/companion/screens/companion_voice_download_dialog.dart';
import 'package:faithlock/features/companion/services/companion_chat_service.dart';
import 'package:faithlock/features/companion/services/companion_history_service.dart';
import 'package:faithlock/features/companion/services/companion_settings_service.dart';
import 'package:faithlock/features/companion/services/companion_voice_model_installer.dart';
import 'package:faithlock/features/companion/services/companion_voice_service.dart';
import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/shared/widgets/cozy/cozy.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

/// "The Companion" — a warm, Scripture-grounded chat woven into the Bible.
///
/// Reached from the floating sparkle-bible button (overlays Today + Bible) and,
/// soon, from a verse's "Ask the AI" action — [verseContext] preloads the passage
/// so the conversation never starts from a blank page.
class CompanionChatScreen extends StatefulWidget {
  /// Optional passage preloaded into the conversation (reference + text).
  final String? verseContext;

  /// Optional human-readable label for the preloaded passage (e.g. "John 3:16").
  final String? verseLabel;

  const CompanionChatScreen({super.key, this.verseContext, this.verseLabel});

  @override
  State<CompanionChatScreen> createState() => _CompanionChatScreenState();
}

class _CompanionChatScreenState extends State<CompanionChatScreen> {
  final CompanionChatService _service = CompanionChatService();
  final CompanionHistoryService _history = CompanionHistoryService();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<CompanionMessage> _messages = [];
  CompanionConversation? _conversation; // current saved thread (local-only)
  bool _sending = false; // true → animated thinking dots (before first token)
  String? _streaming; // assistant text accumulating in real time
  StreamSubscription<String>? _sub;

  final CompanionSettingsService _settingsService = CompanionSettingsService();
  final CompanionVoiceService _voice = CompanionVoiceService();
  CompanionSettings _settings = CompanionSettings.defaults;

  final PostHogService _analytics = PostHogService.instance;

  // Tracks the start of the current reply so `companion_reply_completed` can
  // report the round-trip time. Reset on each send.
  int? _replyStartedAtMs;
  bool _replyHadError = false;

  void _track(String event, [Map<String, dynamic> props = const {}]) {
    if (_analytics.isReady) _analytics.events.trackCustom(event, props);
  }

  bool get _hasVerseContext =>
      widget.verseContext != null && widget.verseContext!.trim().isNotEmpty;

  List<String> get _starters => [
        'companion_starter1'.tr,
        'companion_starter2'.tr,
        'companion_starter3'.tr,
        'companion_starter4'.tr,
      ];

  @override
  void initState() {
    super.initState();
    _track('companion_opened', {
      'source': _hasVerseContext ? 'verse' : 'fab',
      'has_verse_context': _hasVerseContext,
    });
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await _settingsService.load();
    if (!mounted) return;
    setState(() => _settings = s);
    if (!s.configured) {
      // First open → ask translation + voice mode; the download dialog (if voice
      // is on) is shown right after they confirm, in _openSettings.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _openSettings(firstRun: true));
    } else if (s.voiceEnabled) {
      _voice.prewarm(); // already set up → quietly ready the neural voice
    }
  }

  /// Ensure the neural voice is ready. If the model isn't downloaded yet, show
  /// the loading dialog (with a "use basic voice" escape).
  Future<void> _ensureVoiceReady() async {
    if (await CompanionVoiceModelInstaller().isInstalled()) {
      _voice.prewarm();
      return;
    }
    if (!mounted) return;
    await CompanionVoiceDownloadDialog.show(context);
    _voice.prewarm(); // inits the neural engine if the download finished
  }

  @override
  void dispose() {
    _sub?.cancel();
    _voice.stop();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _openSettings({bool firstRun = false}) async {
    final updated = await CompanionSettingsSheet.show(
      context,
      initial: _settings,
      firstRun: firstRun,
    );
    if (updated == null || !mounted) return;
    await _settingsService.save(updated);
    _track('companion_settings_saved', {
      'translation': updated.bibleVersion,
      'read_aloud': updated.voiceEnabled,
      'is_first_run': firstRun,
    });
    if (!mounted) return;
    setState(() => _settings = updated);
    if (updated.voiceEnabled) {
      _ensureVoiceReady(); // downloads with a loading dialog if needed
    } else {
      _voice.stop();
    }
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _sending || _streaming != null) return;
    _voice.stop(); // hush any in-progress reading
    _input.clear();

    final isFirstMessage = !_messages.any((m) => m.role == 'user');
    _track('companion_message_sent', {
      'message_length': text.length,
      'is_first_message': isFirstMessage,
      'has_verse_context': _hasVerseContext,
    });
    _replyStartedAtMs = DateTime.now().millisecondsSinceEpoch;
    _replyHadError = false;

    setState(() {
      _messages.add(CompanionMessage(role: 'user', content: text));
      _sending = true; // thinking dots until the first token lands
      _streaming = null;
    });
    _scrollToEnd();

    _sub = _service
        .replyStream(
      history: _messages,
      bibleVersion: _settings.bibleVersion,
      verseContext: widget.verseContext,
    )
        .listen(
      (delta) {
        if (!mounted) return;
        setState(() {
          _sending = false; // first token → swap dots for live text
          _streaming = (_streaming ?? '') + delta;
        });
        _scrollToEnd(animated: false); // pin instantly while streaming
      },
      onError: (Object e) {
        if (!mounted) return;
        _replyHadError = true;
        _track('companion_reply_error', {
          'error_type': e.runtimeType.toString(),
        });
        _trackReplyCompleted(replyLength: 0);
        setState(() {
          _messages.add(CompanionMessage(
            role: 'assistant',
            content: 'companion_connectionError'.tr,
          ));
          _streaming = null;
          _sending = false;
        });
        _scrollToEnd();
      },
      onDone: () {
        if (!mounted) return;
        final t = _streaming?.trim();
        if (!_replyHadError) {
          _trackReplyCompleted(replyLength: t?.length ?? 0);
        }
        setState(() {
          if (t != null && t.isNotEmpty) {
            _messages.add(CompanionMessage(role: 'assistant', content: t));
          }
          _streaming = null;
          _sending = false;
        });
        _scrollToEnd(animated: false); // same text, no wobble on finalize
        _persist();
        if (t != null && t.isNotEmpty && _settings.voiceEnabled) {
          _voice.speak(t);
        }
      },
    );
  }

  /// Emits `companion_reply_completed` once per turn with the round-trip time.
  void _trackReplyCompleted({required int replyLength}) {
    final started = _replyStartedAtMs;
    final elapsed =
        started == null ? 0 : DateTime.now().millisecondsSinceEpoch - started;
    _replyStartedAtMs = null;
    _track('companion_reply_completed', {
      'reply_length': replyLength,
      'exchange_time_ms': elapsed,
      'had_error': _replyHadError,
    });
  }

  /// Save (or update) the current conversation locally after each completed turn.
  Future<void> _persist() async {
    if (_messages.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final firstUser = _messages.firstWhere(
      (m) => m.role == 'user',
      orElse: () => _messages.first,
    );
    final title = firstUser.content.trim().replaceAll('\n', ' ');
    final convo = _conversation ??= CompanionConversation(
      id: now.toString(),
      title: title.length > 48 ? '${title.substring(0, 48)}…' : title,
      createdAt: now,
      updatedAt: now,
      messages: const [],
    );
    convo
      ..updatedAt = now
      ..messages = List<CompanionMessage>.from(_messages);
    await _history.upsert(convo);
  }

  void _newChat() {
    _track('companion_new_chat', {
      'previous_message_count': _messages.length,
    });
    _sub?.cancel();
    _voice.stop();
    setState(() {
      _messages.clear();
      _conversation = null;
      _streaming = null;
      _sending = false;
    });
  }

  Future<void> _openHistory() async {
    final selected = await Navigator.of(context).push<CompanionConversation>(
      MaterialPageRoute(builder: (_) => const CompanionHistoryScreen()),
    );
    if (selected == null || !mounted) return;
    _track('companion_conversation_loaded', {
      'message_count': selected.messages.length,
    });
    _sub?.cancel();
    _voice.stop();
    setState(() {
      _conversation = selected;
      _messages
        ..clear()
        ..addAll(selected.messages);
      _streaming = null;
      _sending = false;
    });
    _scrollToEnd();
  }

  /// Keeps the newest message in view.
  ///
  /// While streaming, pass [animated] = false: tokens arrive faster than the
  /// 220ms eased animation can settle, so animating to a target that keeps
  /// growing (and overshooting) made the answer card visibly zigzag. An instant
  /// `jumpTo` pins it to the bottom cleanly. Discrete events (send / error /
  /// history load) still animate.
  void _scrollToEnd({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final target = _scroll.position.maxScrollExtent;
      if (animated) {
        _scroll.animateTo(
          target,
          duration: CozyTokens.base,
          curve: Curves.easeOut,
        );
      } else {
        _scroll.jumpTo(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CozyColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty ? _buildEmptyState() : _buildList(),
            ),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: CozyColors.background,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: CozyColors.ink, size: 20),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: ShapeDecoration(
              color: CozyColors.peach,
              shape: CozyTokens.smooth(
                12,
                side: const BorderSide(
                  color: CozyColors.outline,
                  width: CozyTokens.borderWidth,
                ),
              ),
            ),
            child: const Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedBubbleChatSpark,
                color: CozyColors.ink,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: CozyTokens.space12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('companion_title'.tr, style: CozyText.heading),
              Text('companion_subtitle'.tr, style: CozyText.label),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'companion_history'.tr,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedClock01,
              color: CozyColors.ink,
              size: 22),
          onPressed: _openHistory,
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'companion_newChat'.tr,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedBubbleChatAdd,
              color: CozyColors.ink,
              size: 22),
          onPressed: _newChat,
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'companion_settings'.tr,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedSettings01,
              color: CozyColors.ink,
              size: 22),
          onPressed: () => _openSettings(),
        ),
        const SizedBox(width: CozyTokens.space8),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        CozyTokens.space20,
        CozyTokens.space32,
        CozyTokens.space20,
        CozyTokens.space20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('companion_emptyTitle'.tr, style: CozyText.title),
          const SizedBox(height: CozyTokens.space8),
          Text(
            widget.verseLabel != null
                ? 'companion_emptyReflecting'
                    .trParams({'label': widget.verseLabel ?? ''})
                : 'companion_emptyDefault'.tr,
            style: CozyText.subtitle,
          ),
          const SizedBox(height: CozyTokens.space24),
          Text('companion_tryAsking'.tr, style: CozyText.label),
          const SizedBox(height: CozyTokens.space12),
          Wrap(
            spacing: CozyTokens.space8,
            runSpacing: CozyTokens.space8,
            children: [
              for (int i = 0; i < _starters.length; i++)
                _starterChip(_starters[i], i),
            ],
          ),
        ],
      ),
    );
  }

  Widget _starterChip(String text, int index) {
    return GestureDetector(
      onTap: () {
        _track('companion_starter_tapped', {'starter_index': index});
        _send(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CozyTokens.space16,
          vertical: CozyTokens.space12,
        ),
        decoration: ShapeDecoration(
          color: CozyColors.surface,
          shape: CozyTokens.smooth(
            CozyTokens.radiusPill,
            side: const BorderSide(
              color: CozyColors.outline,
              width: CozyTokens.borderWidthThin,
            ),
          ),
        ),
        child: Text(text, style: CozyText.body),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(
        CozyTokens.space16,
        CozyTokens.space16,
        CozyTokens.space16,
        CozyTokens.space24,
      ),
      itemCount: _messages.length + ((_streaming != null || _sending) ? 1 : 0),
      itemBuilder: (context, i) {
        if (i < _messages.length) return _MessageBubble(message: _messages[i]);
        if (_streaming != null) {
          return _MessageBubble(
            message: CompanionMessage(role: 'assistant', content: _streaming!),
            streaming: true,
          );
        }
        return const _TypingBubble();
      },
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        CozyTokens.space16,
        CozyTokens.space8,
        CozyTokens.space16,
        CozyTokens.space16,
      ),
      color: CozyColors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: CozyTextField(
              controller: _input,
              hintText: 'companion_composerHint'.tr,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: CozyTokens.space12),
          GestureDetector(
            onTap: () => _send(_input.text),
            child: Container(
              width: 52,
              height: 52,
              decoration: ShapeDecoration(
                color: _input.text.trim().isEmpty
                    ? CozyColors.surfaceMuted
                    : CozyColors.primary,
                shape: CozyTokens.smooth(
                  16,
                  side: const BorderSide(
                    color: CozyColors.outline,
                    width: CozyTokens.borderWidth,
                  ),
                ),
                shadows: CozyTokens.shadowHard,
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: _input.text.trim().isEmpty
                    ? CozyColors.inkMuted
                    : CozyColors.onPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final CompanionMessage message;
  final bool streaming;
  const _MessageBubble({required this.message, this.streaming = false});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: CozyTokens.space12),
        padding: const EdgeInsets.symmetric(
          horizontal: CozyTokens.space16,
          vertical: CozyTokens.space12,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: ShapeDecoration(
          color: isUser ? CozyColors.primary : CozyColors.surface,
          shape: CozyTokens.smooth(
            CozyTokens.radiusMd,
            side: BorderSide(
              color: CozyColors.outline,
              width:
                  isUser ? CozyTokens.borderWidthThin : CozyTokens.borderWidth,
            ),
          ),
          shadows: isUser ? null : CozyTokens.shadowHard,
        ),
        child: Text(
          streaming ? '${message.content}▌' : message.content,
          style: CozyText.body.copyWith(
            color: isUser ? CozyColors.onPrimary : CozyColors.ink,
          ),
        ),
      ),
    );
  }
}

/// Animated "thinking" bubble — three dots that rise and fade in a staggered
/// wave while the Companion is composing (before the first streamed token).
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _dot(int i) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // Staggered triangle wave per dot → smooth rise/fall.
        final phase = (_c.value - i * 0.18) % 1.0;
        final wave = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
        return Transform.translate(
          offset: Offset(0, -4 * wave),
          child: Opacity(
            opacity: 0.35 + 0.65 * wave,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: CozyColors.inkMuted,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: CozyTokens.space12),
        padding: const EdgeInsets.symmetric(
          horizontal: CozyTokens.space16,
          vertical: CozyTokens.space16 + 2,
        ),
        decoration: ShapeDecoration(
          color: CozyColors.surface,
          shape: CozyTokens.smooth(
            CozyTokens.radiusMd,
            side: const BorderSide(
              color: CozyColors.outline,
              width: CozyTokens.borderWidth,
            ),
          ),
          shadows: CozyTokens.shadowHard,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(0),
            const SizedBox(width: 5),
            _dot(1),
            const SizedBox(width: 5),
            _dot(2),
          ],
        ),
      ),
    );
  }
}
