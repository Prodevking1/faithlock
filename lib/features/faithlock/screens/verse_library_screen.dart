import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:faithlock/core/constants/core/fast_spacing.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/layout/export.dart';
import 'package:faithlock/shared/widgets/lists/fast_list_section.dart';
import 'package:faithlock/shared/widgets/lists/fast_list_tile.dart';
import 'package:faithlock/features/faithlock/controllers/verse_library_controller.dart';
import 'package:faithlock/features/faithlock/models/export.dart';

/// Verse Library Screen
/// Browse, search, and favorite Bible verses
class VerseLibraryScreen extends StatelessWidget {
  const VerseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerseLibraryController());

    return Scaffold(
      backgroundColor: FastColors.surface(context),
      appBar: AppBar(
        title: Text(
          'Verse Library',
          style: TextStyle(
            color: FastColors.primaryText(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: FastColors.surface(context),
        elevation: 0,
        actions: [
          // Favorites toggle
          Obx(() => IconButton(
                icon: Icon(
                  controller.showFavoritesOnly.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: controller.showFavoritesOnly.value
                      ? FastColors.error
                      : FastColors.primaryText(context),
                ),
                onPressed: controller.toggleFavoritesView,
              )),
          // Refresh
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: FastColors.primaryText(context),
            ),
            onPressed: controller.refreshData,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: FastSpacing.px16,
              child: TextField(
                onChanged: controller.searchVerses,
                style: TextStyle(color: FastColors.primaryText(context)),
                decoration: InputDecoration(
                  hintText: 'Search verses...',
                  hintStyle: TextStyle(color: FastColors.tertiaryText(context)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: FastColors.secondaryText(context),
                  ),
                  filled: true,
                  fillColor: FastColors.surfaceVariant(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            FastSpacing.h16,

            // Category filter chips
            Obx(() => SizedBox(
                  height: 50,
                  child: ListView(
                    padding: FastSpacing.px16,
                    scrollDirection: Axis.horizontal,
                    children: [
                      // All categories chip
                      _buildFilterChip(
                        context,
                        label: 'All',
                        isSelected: controller.selectedCategory.value == null,
                        onTap: () => controller.filterByCategory(null),
                      ),
                      const SizedBox(width: 8),
                      // Category chips
                      ...VerseCategory.values.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            context,
                            label: _getCategoryLabel(category),
                            isSelected:
                                controller.selectedCategory.value == category,
                            onTap: () => controller.filterByCategory(category),
                          ),
                        );
                      }),
                    ],
                  ),
                )),
            FastSpacing.h16,

            // Verses list
            Expanded(
              child: Obx(() {
                // Loading state
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: FastColors.primary,
                    ),
                  );
                }

                // Error state
                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: FastColors.error,
                        ),
                        FastSpacing.h16,
                        Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: FastColors.secondaryText(context),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        FastSpacing.h24,
                        FastButton(
                          text: 'Retry',
                          onTap: controller.loadVerses,
                        ),
                      ],
                    ),
                  );
                }

                // Empty state
                if (controller.filteredVerses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 64,
                          color: FastColors.disabled(context),
                        ),
                        FastSpacing.h16,
                        Text(
                          controller.showFavoritesOnly.value
                              ? 'No favorite verses yet'
                              : 'No verses found',
                          style: TextStyle(
                            color: FastColors.secondaryText(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        FastSpacing.h8,
                        Text(
                          controller.showFavoritesOnly.value
                              ? 'Tap the heart icon to add favorites'
                              : 'Try a different search or category',
                          style: TextStyle(
                            color: FastColors.tertiaryText(context),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Verses list
                return ListView.builder(
                  padding: FastSpacing.px16,
                  itemCount: controller.filteredVerses.length,
                  itemBuilder: (context, index) {
                    final verse = controller.filteredVerses[index];
                    final isFavorite = controller.isFavorite(verse.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: FastColors.surfaceVariant(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: FastColors.border(context),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category badge and favorite button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(verse.category)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getCategoryLabel(verse.category),
                                    style: TextStyle(
                                      color: _getCategoryColor(verse.category),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? FastColors.error
                                        : FastColors.secondaryText(context),
                                  ),
                                  onPressed: () =>
                                      controller.toggleFavorite(verse),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Verse text
                            Text(
                              '"${verse.text}"',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                                color: FastColors.primaryText(context),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Reference
                            Text(
                              verse.reference,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: FastColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Build category filter chip
  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? FastColors.primary
              : FastColors.surfaceVariant(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? FastColors.primary
                : FastColors.border(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : FastColors.primaryText(context),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Get category display label
  String _getCategoryLabel(VerseCategory category) {
    return category.displayName;
  }

  /// Get category color
  Color _getCategoryColor(VerseCategory category) {
    switch (category) {
      case VerseCategory.temptation:
        return const Color(0xFFFF5722); // Red-Orange - Danger
      case VerseCategory.fearAnxiety:
        return const Color(0xFF2196F3); // Blue - Calm
      case VerseCategory.pride:
        return const Color(0xFF9C27B0); // Purple - Royal
      case VerseCategory.lust:
        return const Color(0xFFF44336); // Red - Warning
      case VerseCategory.anger:
        return const Color(0xFFFF9800); // Orange - Alert
    }
  }
}
