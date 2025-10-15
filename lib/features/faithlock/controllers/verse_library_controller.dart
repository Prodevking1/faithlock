import 'package:get/get.dart';
import 'package:faithlock/features/faithlock/models/export.dart';
import 'package:faithlock/features/faithlock/services/export.dart';

/// Controller for Verse Library Screen
/// Manages verse browsing, search, filtering, and favorites
class VerseLibraryController extends GetxController {
  final VerseService _verseService = VerseService();

  // Observable state
  final RxList<BibleVerse> allVerses = <BibleVerse>[].obs;
  final RxList<BibleVerse> filteredVerses = <BibleVerse>[].obs;
  final RxList<BibleVerse> favoriteVerses = <BibleVerse>[].obs;
  final RxString searchQuery = RxString('');
  final Rx<VerseCategory?> selectedCategory = Rx<VerseCategory?>(null);
  final RxBool isLoading = RxBool(true);
  final RxBool showFavoritesOnly = RxBool(false);
  final RxString errorMessage = RxString('');

  @override
  void onInit() {
    super.onInit();
    loadVerses();
    loadFavorites();
  }

  /// Load all verses from service
  Future<void> loadVerses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final verses = await _verseService.getAllVerses();
      allVerses.value = verses;
      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Failed to load verses: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Load favorite verses
  Future<void> loadFavorites() async {
    try {
      final favorites = await _verseService.getFavoriteVerses();
      favoriteVerses.value = favorites;
    } catch (e) {
      // Silent fail for favorites
    }
  }

  /// Search verses by text or reference
  void searchVerses(String query) {
    searchQuery.value = query.trim();
    _applyFilters();
  }

  /// Filter by category
  void filterByCategory(VerseCategory? category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  /// Toggle favorites view
  void toggleFavoritesView() {
    showFavoritesOnly.value = !showFavoritesOnly.value;
    _applyFilters();
  }

  /// Apply all active filters
  void _applyFilters() {
    List<BibleVerse> result = allVerses;

    // Show favorites only
    if (showFavoritesOnly.value) {
      result = favoriteVerses;
    }

    // Filter by category
    if (selectedCategory.value != null) {
      result = result
          .where((verse) => verse.category == selectedCategory.value)
          .toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((verse) {
        return verse.text.toLowerCase().contains(query) ||
            verse.reference.toLowerCase().contains(query) ||
            verse.book.toLowerCase().contains(query);
      }).toList();
    }

    filteredVerses.value = result;
  }

  /// Toggle verse favorite status
  Future<void> toggleFavorite(BibleVerse verse) async {
    try {
      final isFavorite = favoriteVerses.any((v) => v.id == verse.id);

      if (isFavorite) {
        await _verseService.toggleFavorite(verse.id);
        favoriteVerses.removeWhere((v) => v.id == verse.id);
      } else {
        await _verseService.toggleFavorite(verse.id);
        favoriteVerses.add(verse);
      }

      // Reapply filters to update view
      _applyFilters();
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to update favorite: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Check if verse is favorite
  bool isFavorite(String verseId) {
    return favoriteVerses.any((v) => v.id == verseId);
  }

  /// Get verse count by category
  int getVersesCountByCategory(VerseCategory category) {
    return allVerses.where((v) => v.category == category).length;
  }

  /// Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = null;
    showFavoritesOnly.value = false;
    _applyFilters();
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadVerses(),
      loadFavorites(),
    ]);
  }
}
