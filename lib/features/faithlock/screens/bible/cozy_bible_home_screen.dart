import 'dart:async';

import 'package:faithlock/features/bible/controllers/bible_controller.dart';
import 'package:faithlock/features/bible/models/bible_book.dart';
import 'package:faithlock/features/faithlock/screens/bible/cozy_book_detail_screen.dart';
import 'package:faithlock/features/faithlock/screens/bible/cozy_reflections_screen.dart';
import 'package:faithlock/navigation/controllers/navigation_controller.dart';
import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:faithlock/shared/widgets/cozy/cozy.dart';

// ── Screen ─────────────────────────────────────────────────────────────────

/// Bible home screen wired to [BibleController].
class CozyBibleHomeScreen extends StatefulWidget {
  const CozyBibleHomeScreen({super.key});

  @override
  State<CozyBibleHomeScreen> createState() => _CozyBibleHomeScreenState();
}

class _CozyBibleHomeScreenState extends State<CozyBibleHomeScreen> {
  // 0 = Old Testament, 1 = New Testament
  int _testament = 0;

  final PostHogService _analytics = PostHogService.instance;

  void _track(String event, [Map<String, dynamic> props = const {}]) {
    if (_analytics.isReady) _analytics.events.trackCustom(event, props);
  }

  BibleController get _ctrl {
    if (!Get.isRegistered<BibleController>()) {
      Get.put(BibleController());
    }
    return Get.find<BibleController>();
  }

  /// The Bible tab's index in the bottom-nav shell (Today=0, Bible=1, …).
  static const int _bibleTabIndex = 1;

  /// True while the Bible tab is the active one. The shell keeps every tab
  /// mounted in an IndexedStack, so [initState] runs at app launch even when
  /// the user never opens Bible — we must gate "viewed" events on real
  /// visibility instead of firing them on build.
  bool _visible = true;
  Worker? _tabWorker;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<NavigationController>()) {
      final nav = Get.find<NavigationController>();
      _visible = nav.currentIndex == _bibleTabIndex;
      if (_visible) _track('bible_opened', {'source': 'tab'});
      _tabWorker = ever<int>(nav.currentIndexRx, (i) {
        final nowVisible = i == _bibleTabIndex;
        if (nowVisible && !_visible) _track('bible_opened', {'source': 'tab'});
        if (nowVisible != _visible && mounted) {
          setState(() => _visible = nowVisible);
        }
      });
    } else {
      // Hosted standalone (not in the tab shell) → it's genuinely on screen.
      _track('bible_opened', {'source': 'direct'});
    }
  }

  @override
  void dispose() {
    _tabWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CozyColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 20),
              _verseOfDayCard(),
              const SizedBox(height: 20),
              _searchBar(),
              const SizedBox(height: 16),
              CozySegmentedControl(
                segments: [
                  'bibleui_oldTestament'.tr,
                  'bibleui_newTestament'.tr,
                ],
                selectedIndex: _testament,
                onChanged: (i) => setState(() {
                  _testament = i;
                  _ctrl.clearSearch();
                  _track('bible_testament_switched', {
                    'testament': i == 0 ? 'old' : 'new',
                  });
                }),
              ),
              const SizedBox(height: 16),
              _bookList(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'bible_holyBible'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CozyText.display,
          ),
        ),
        const SizedBox(width: 12),
        CozyIconButton(
          icon: HugeIcons.strokeRoundedNote01,
          onTap: _openReflections,
          size: 48,
        ),
        const SizedBox(width: 10),
        CozyIconButton(
          icon: HugeIcons.strokeRoundedSearch01,
          onTap: _openSearch,
          size: 48,
        ),
      ],
    );
  }

  void _openReflections() {
    _track('reflections_opened', {'source': 'bible_home'});
    Get.to(() => const CozyReflectionsScreen());
  }

  void _openSearch() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: CozyColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CozyTokens.radiusLg),
        ),
      ),
      builder: (_) => _SearchSheet(ctrl: _ctrl),
    );
  }

  // ── Verse of the Day ──────────────────────────────────────────────────────

  Widget _verseOfDayCard() {
    return Obx(() => CozyVerseOfDayCard(
          text: _ctrl.verseOfDay.value?.text,
          reference: _ctrl.verseOfDay.value?.reference,
          loading: _ctrl.isVerseLoading.value,
          // Only counts as "viewed" once the Bible tab is actually on screen
          // (the IndexedStack builds this tab eagerly).
          visible: _visible,
        ));
  }

  // ── Search bar (inline — shown when query is active) ──────────────────────

  Widget _searchBar() {
    return Obx(() {
      final query = _ctrl.searchQuery.value;
      if (query.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'bibleui_resultsFor'.trParams({'query': query}),
                style: CozyText.label.copyWith(color: CozyColors.inkMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            CozyIconButton(
              icon: HugeIcons.strokeRoundedCancel01,
              onTap: _ctrl.clearSearch,
              size: 36,
            ),
          ],
        ),
      );
    });
  }

  // ── Book list ─────────────────────────────────────────────────────────────

  Widget _bookList() {
    return Obx(() {
      // Access searchQuery to rebuild when it changes.
      _ctrl.searchQuery.value;

      final testament =
          _testament == 0 ? Testament.old : Testament.newTestament;
      final books = _ctrl.filteredBooks(testament: testament);

      if (books.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              'bibleui_noBooksFound'.tr,
              style: CozyText.body.copyWith(color: CozyColors.inkMuted),
            ),
          ),
        );
      }

      return Column(
        children: books.map((book) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CozyChoiceCard(
              title: book.name,
              subtitle: 'bibleui_chaptersCategory'.trParams({
                'count': '${book.chapterCount}',
                'category': book.categoryName,
              }),
              leading: CozyLetterBadge(
                label: book.abbreviation,
                background: book.badgeColor,
                size: 52,
              ),
              showChevron: true,
              onTap: () {
                _track('bible_book_opened', {
                  'book': book.name,
                  'testament': book.testament == Testament.old ? 'old' : 'new',
                });
                Get.to(
                  () => CozyBookDetailScreen(
                    bookName: book.name,
                    bookAbbr: book.abbreviation,
                    category: book.categoryName,
                    badgeColor: book.badgeColor,
                    chapterCount: book.chapterCount,
                  ),
                );
              },
            ),
          );
        }).toList(),
      );
    });
  }
}

// ── Search sheet ─────────────────────────────────────────────────────────────

class _SearchSheet extends StatefulWidget {
  final BibleController ctrl;
  const _SearchSheet({required this.ctrl});

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final TextEditingController _textCtrl = TextEditingController();
  final PostHogService _analytics = PostHogService.instance;
  Timer? _searchDebounce;
  String _lastTrackedQuery = '';

  @override
  void initState() {
    super.initState();
    _textCtrl.text = widget.ctrl.searchQuery.value;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _textCtrl.dispose();
    super.dispose();
  }

  /// Fires a single grouped `bible_search` event once the user pauses typing —
  /// never per keystroke. Skips empty/duplicate queries.
  void _onSearchChanged(String query) {
    widget.ctrl.updateSearch(query);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 600), () {
      final q = query.trim();
      if (q.isEmpty || q == _lastTrackedQuery) return;
      _lastTrackedQuery = q;
      final results = widget.ctrl.filteredBooks().length;
      if (_analytics.isReady) {
        _analytics.events.trackCustom('bible_search', {
          'query_length': q.length,
          'results_count': results,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.5;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CozyIconButton(
                    icon: HugeIcons.strokeRoundedCancel01,
                    onTap: Get.back,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('bible_searchBooks'.tr, style: CozyText.title),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CozyTextField(
                controller: _textCtrl,
                hintText: 'bibleui_searchHint'.tr,
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 12),
              Text(
                'bibleui_searchSubtitle'.tr,
                style: CozyText.label.copyWith(color: CozyColors.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
