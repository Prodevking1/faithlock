import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';

import 'package:faithlock/features/bible/controllers/bible_engagement_controller.dart';
import 'package:faithlock/shared/widgets/cozy/cozy.dart';
import 'cozy_reflection_note_screen.dart';

// ── Screen ──────────────────────────────────────────────────────────────────

/// Reading view with native drag-to-select text. Selecting text opens a cozy
/// floating toolbar (Copy / Highlight / Bookmark / Share / Reflect) positioned
/// by Flutter's selection system so it never hides the verse. The verse only
/// becomes visually highlighted when the user taps the paintbrush icon — plain
/// selection has no persistent visual side-effect.
class CozyReadingScreen extends StatefulWidget {
  /// Human-readable chapter reference, e.g. "Genesis 1".
  final String reference;

  /// Ordered list of verses. Each record has a [number] and [text].
  final List<({int number, String text})> verses;

  const CozyReadingScreen({
    super.key,
    required this.reference,
    required this.verses,
  });

  @override
  State<CozyReadingScreen> createState() => _CozyReadingScreenState();
}

class _CozyReadingScreenState extends State<CozyReadingScreen> {
  // Lazily find-or-create the engagement controller.
  BibleEngagementController get _engagement {
    if (!Get.isRegistered<BibleEngagementController>()) {
      Get.put(BibleEngagementController());
    }
    return Get.find<BibleEngagementController>();
  }

  String get _bookAbbr => widget.reference.split(' ').first;

  int get _chapterNumber {
    final parts = widget.reference.trim().split(' ');
    return int.tryParse(parts.last) ?? 1;
  }

  // ── Per-verse actions ──────────────────────────────────────────────────────

  Future<void> _copy(int verseIndex, String? selection) async {
    final verse = widget.verses[verseIndex];
    final body = (selection != null && selection.trim().isNotEmpty)
        ? selection
        : verse.text;
    final text = '${widget.reference}:${verse.number} — $body';
    await Clipboard.setData(ClipboardData(text: text));
    _showSnackbar('bibleui_copiedToClipboard'.tr);
  }

  Future<void> _share(int verseIndex, String? selection, Rect? origin) async {
    final verse = widget.verses[verseIndex];
    final body = (selection != null && selection.trim().isNotEmpty)
        ? selection
        : verse.text;
    // Same designed verse image as the Verse-of-the-Day share.
    await shareVerseAsImage(
      context,
      verseText: body.trim(),
      reference: '${widget.reference}:${verse.number}',
      sharePositionOrigin: origin,
    );
  }

  /// Toggle a verse-level highlight and offer an Undo via a snackbar action.
  Future<void> _toggleHighlight(int verseIndex) async {
    final verse = widget.verses[verseIndex];
    final nowHighlighted = await _engagement.toggleHighlight(
      _bookAbbr,
      _chapterNumber,
      verse.number,
    );
    if (mounted) setState(() {}); // refresh underline state
    _showSnackbar(
      nowHighlighted
          ? 'bible_verseHighlighted'.tr
          : 'bible_highlightRemoved'.tr,
      undo: () async {
        await _engagement.toggleHighlight(
          _bookAbbr,
          _chapterNumber,
          verse.number,
        );
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _toggleVerseBookmark(int verseIndex) async {
    final verse = widget.verses[verseIndex];
    final ref = '${widget.reference}:${verse.number}';
    final nowBookmarked = await _engagement.toggleBookmark(ref);
    if (mounted) setState(() {});
    _showSnackbar(
      nowBookmarked
          ? 'bible_verseBookmarked'.tr
          : 'bible_bookmarkRemoved'.tr,
      undo: () async {
        await _engagement.toggleBookmark(ref);
        if (mounted) setState(() {});
      },
    );
  }

  void _reflect(int verseIndex, String? selection) {
    final verse = widget.verses[verseIndex];
    final passageReference = '${widget.reference}:${verse.number}';
    Get.to(() => CozyReflectionNoteScreen(passageReference: passageReference));
  }

  // ── Chapter-level actions (top bar) ────────────────────────────────────────

  Future<void> _toggleChapterBookmark() async {
    final nowBookmarked = await _engagement.toggleBookmark(widget.reference);
    if (mounted) setState(() {});
    _showSnackbar(
      nowBookmarked
          ? 'bible_chapterBookmarked'
              .trParams({'reference': widget.reference})
          : 'bible_bookmarkRemoved'.tr,
      undo: () async {
        await _engagement.toggleBookmark(widget.reference);
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _shareChapter(BuildContext anchorContext) async {
    final box = anchorContext.findRenderObject() as RenderBox?;
    final origin = (box != null && box.hasSize)
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    await SharePlus.instance.share(
      ShareParams(
        text: 'bibleui_shareChapterText'.trParams({
          'reference': widget.reference,
        }),
        subject: widget.reference,
        sharePositionOrigin: origin,
      ),
    );
  }

  // ── Snackbar with optional Undo action ─────────────────────────────────────

  void _showSnackbar(String message, {Future<void> Function()? undo}) {
    if (!mounted) return;
    // Use Flutter's native ScaffoldMessenger instead of GetX snackbars: GetX's
    // SnackbarController leaves its queue in a state where a later Get.back()
    // (which calls closeCurrentSnackbar internally) throws a
    // LateInitializationError on its uninitialized AnimationController — which
    // broke the back button after acting on a verse.
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: CozyColors.ink,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CozyTokens.radiusMd),
        ),
        content: Text(
          message,
          style: CozyText.body.copyWith(
            color: CozyColors.onPrimary,
            fontSize: 14,
          ),
        ),
        action: undo == null
            ? null
            : SnackBarAction(
                label: 'bibleui_undo'.tr,
                textColor: CozyColors.primaryLight,
                onPressed: () async {
                  await undo();
                },
              ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Theme the system selection color/handles in cozy terracotta so the
    // native drag-select highlight matches the rest of the screen.
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: CozyColors.primary.withValues(alpha: 0.28),
          cursorColor: CozyColors.primary,
          selectionHandleColor: CozyColors.primary,
        ),
      ),
      child: Scaffold(
        backgroundColor: CozyColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          widget.reference,
                          style: CozyText.title.copyWith(fontSize: 22),
                        ),
                      ),
                      ...List.generate(
                        widget.verses.length,
                        (index) => _buildVerseBlock(index),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Obx(() {
      final bookmarked = _engagement.isBookmarked(widget.reference);
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            CozyIconButton.back(onTap: Get.back),
            const Spacer(),
            CozyIconButton(
              icon: bookmarked
                  ? HugeIcons.strokeRoundedBookmarkAdd01
                  : HugeIcons.strokeRoundedBookmark01,
              onTap: _toggleChapterBookmark,
              size: 48,
            ),
            const SizedBox(width: 8),
            Builder(
              builder: (ctx) => CozyIconButton(
                icon: HugeIcons.strokeRoundedShare01,
                onTap: () => _shareChapter(ctx),
                size: 48,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Verse block ────────────────────────────────────────────────────────────

  Widget _buildVerseBlock(int index) {
    final verse = widget.verses[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Obx(() {
              final highlighted = _engagement.isHighlighted(
                _bookAbbr,
                _chapterNumber,
                verse.number,
              );
              return Text(
                '${verse.number}',
                style: CozyText.heading.copyWith(
                  color: highlighted
                      ? CozyColors.primary
                      : CozyColors.inkMuted.withValues(alpha: 0.5),
                  fontSize: 18,
                ),
              );
            }),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Obx(() {
              final highlighted = _engagement.isHighlighted(
                _bookAbbr,
                _chapterNumber,
                verse.number,
              );
              return _buildVerseText(
                verse.text,
                index: index,
                isHighlighted: highlighted,
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Verse text (SelectableText + custom cozy context menu) ─────────────────

  Widget _buildVerseText(
    String text, {
    required int index,
    required bool isHighlighted,
  }) {
    final baseStyle = CozyText.body.copyWith(
      height: 1.75,
      fontSize: 17,
      color: CozyColors.ink,
    );

    // The persistent highlight (peach underline) only appears when the user
    // has tapped the paintbrush icon — never as a side-effect of selecting.
    final style = isHighlighted
        ? baseStyle.copyWith(
            backgroundColor: CozyColors.peach.withValues(alpha: 0.45),
            decoration: TextDecoration.underline,
            decorationColor: CozyColors.primary,
            decorationThickness: 2,
          )
        : baseStyle;

    return SelectableText(
      text,
      style: style,
      // Drag-select, double-tap = word, triple-tap = paragraph, all native.
      enableInteractiveSelection: true,
      // Use our cozy toolbar instead of the OS adaptive default.
      contextMenuBuilder: (context, editableTextState) {
        return _CozyTextSelectionToolbar(
          state: editableTextState,
          actions: [
            _ToolbarAction(
              icon: HugeIcons.strokeRoundedCopy01,
              label: 'bible_toolbarCopy'.tr,
              onTap: () {
                editableTextState.hideToolbar();
                final sel = _selectionOf(editableTextState);
                _copy(index, sel);
              },
            ),
            _ToolbarAction(
              icon: HugeIcons.strokeRoundedPaintBrush02,
              label: 'bible_toolbarHighlight'.tr,
              onTap: () {
                editableTextState.hideToolbar();
                _toggleHighlight(index);
              },
            ),
            _ToolbarAction(
              icon: HugeIcons.strokeRoundedBookmark01,
              label: 'bible_toolbarBookmark'.tr,
              onTap: () {
                editableTextState.hideToolbar();
                _toggleVerseBookmark(index);
              },
            ),
            _ToolbarAction(
              icon: HugeIcons.strokeRoundedShare01,
              label: 'bible_toolbarShare'.tr,
              onTap: () {
                editableTextState.hideToolbar();
                final sel = _selectionOf(editableTextState);
                final origin = _anchorRect(editableTextState);
                _share(index, sel, origin);
              },
            ),
            _ToolbarAction(
              icon: HugeIcons.strokeRoundedNoteEdit,
              label: 'bible_toolbarReflect'.tr,
              onTap: () {
                editableTextState.hideToolbar();
                final sel = _selectionOf(editableTextState);
                _reflect(index, sel);
              },
            ),
          ],
        );
      },
    );
  }

  /// Returns the currently-selected substring, or null if the selection is
  /// collapsed/invalid.
  static String? _selectionOf(EditableTextState state) {
    final v = state.textEditingValue;
    final s = v.selection;
    if (!s.isValid || s.isCollapsed) return null;
    return v.text.substring(s.start, s.end);
  }

  /// Anchor rect for iPad share popover — uses the toolbar's primary anchor
  /// + a small box around it.
  static Rect _anchorRect(EditableTextState state) {
    final a = state.contextMenuAnchors.primaryAnchor;
    return Rect.fromCenter(center: a, width: 1, height: 1);
  }
}

// ── Cozy text-selection toolbar ────────────────────────────────────────────

class _ToolbarAction {
  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// Custom cozy toolbar that uses Flutter's [TextSelectionToolbarAnchors] to
/// position itself above (or below, when there's no room) the selection —
/// so it never sits on top of the verse it's acting on.
class _CozyTextSelectionToolbar extends StatelessWidget {
  final EditableTextState state;
  final List<_ToolbarAction> actions;

  const _CozyTextSelectionToolbar({
    required this.state,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final anchors = state.contextMenuAnchors;
    // [TextSelectionToolbar] (Material) handles the above/below decision
    // automatically using its `anchorAbove` / `anchorBelow` anchors so the
    // toolbar never overlaps the selected text.
    return TextSelectionToolbar(
      anchorAbove: anchors.primaryAnchor,
      anchorBelow:
          anchors.secondaryAnchor ?? anchors.primaryAnchor,
      toolbarBuilder: (context, child) => _ToolbarShell(child: child),
      children: actions.map((a) => _ToolbarButton(action: a)).toList(),
    );
  }
}

/// Chunky cozy chrome around the row of action buttons.
class _ToolbarShell extends StatelessWidget {
  final Widget child;
  const _ToolbarShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: CozyColors.surface,
        shape: CozyTokens.smooth(
          CozyTokens.radiusPill,
          side: const BorderSide(
            color: CozyColors.outline,
            width: CozyTokens.borderWidth,
          ),
        ),
        shadows: CozyTokens.shadowHard,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: child,
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final _ToolbarAction action;
  const _ToolbarButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return CozyTappable(
      onTap: action.onTap,
      pressedScale: 0.9,
      child: Tooltip(
        message: action.label,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: HugeIcon(
            icon: action.icon,
            size: 22,
            color: CozyColors.ink,
          ),
        ),
      ),
    );
  }
}
