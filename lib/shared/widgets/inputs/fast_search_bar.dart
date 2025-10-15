/// **FastSearchBar** - Platform-adaptive search input with cancel functionality and focus management.
///
/// **Use Case:** 
/// Search functionality in apps for filtering content, finding items, or general search features.
/// Provides platform-native search experience with proper focus management, cancel button, 
/// and search-optimized keyboard. Perfect for search screens, filtering, and content discovery.
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoSearchTextField on iOS, Material TextField on Android)
/// - Built-in cancel button that appears when focused
/// - Automatic focus management with customizable autofocus
/// - Search-optimized keyboard and text input handling
/// - Internationalization support for placeholder and cancel text
/// - Custom background color support
/// - Enabled/disabled state management
/// - Real-time search with onChange callback
///
/// **Important Parameters:**
/// - `placeholder`: Search placeholder text (defaults to translated "Search")
/// - `onChanged`: Callback when search text changes (real-time search)
/// - `onSubmitted`: Callback when search is submitted (search button pressed)
/// - `onFocusChanged`: Callback when search bar gains focus
/// - `onCancel`: Callback when cancel button is pressed
/// - `controller`: TextEditingController for programmatic control
/// - `autofocus`: Automatically focus the search bar when displayed
/// - `enabled`: Whether the search bar accepts input
/// - `backgroundColor`: Custom background color for the search field
///
/// **Usage Examples:**
/// ```dart
/// // Basic search bar
/// FastSearchBar(
///   placeholder: 'Search products...',
///   onChanged: (query) => searchProducts(query)
/// )
///
/// // Search with submit and cancel handling
/// FastSearchBar(
///   controller: searchController,
///   autofocus: true,
///   onChanged: (query) => filterResults(query),
///   onSubmitted: (query) => performSearch(query),
///   onCancel: () => clearSearchResults()
/// )
///
/// // Custom styled search
/// FastSearchBar(
///   placeholder: 'Find messages',
///   backgroundColor: Colors.grey[100],
///   onChanged: (query) => searchMessages(query),
///   onFocusChanged: () => trackSearchEngagement()
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FastSearchBar extends StatefulWidget {
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFocusChanged;
  final VoidCallback? onCancel;
  final TextEditingController? controller;
  final bool autofocus;
  final bool enabled;
  final Color? backgroundColor;
  final List<String>? suggestions;
  final Widget Function(String)? suggestionBuilder;

  const FastSearchBar({
    super.key,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
    this.onCancel,
    this.controller,
    this.autofocus = false,
    this.enabled = true,
    this.backgroundColor,
    this.suggestions,
    this.suggestionBuilder,
  });

  @override
  State<FastSearchBar> createState() => _FastSearchBarState();
}

class _FastSearchBarState extends State<FastSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    
    _focusNode.addListener(() {
      setState(() {
        _isActive = _focusNode.hasFocus;
      });
      if (_focusNode.hasFocus) {
        widget.onFocusChanged?.call();
      }
    });

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return _buildCupertinoSearchBar(context);
    } else {
      return _buildMaterialSearchBar(context);
    }
  }

  Widget _buildCupertinoSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: CupertinoSearchTextField(
              controller: _controller,
              placeholder: widget.placeholder ?? 'search'.tr,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              focusNode: _focusNode,
              enabled: widget.enabled,
              backgroundColor: widget.backgroundColor ?? 
                CupertinoColors.tertiarySystemFill.resolveFrom(context),
              style: const TextStyle(
                fontSize: 17,
                color: CupertinoColors.label,
              ),
              placeholderStyle: const TextStyle(
                fontSize: 17,
                color: CupertinoColors.placeholderText,
              ),
            ),
          ),
          if (_isActive) ...[
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _controller.clear();
                _focusNode.unfocus();
                widget.onCancel?.call();
                widget.onChanged?.call('');
              },
              child: Text(
                'cancel'.tr,
                style: TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMaterialSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? 
          Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              enabled: widget.enabled,
              decoration: InputDecoration(
                hintText: widget.placeholder ?? 'search'.tr,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          widget.onChanged?.call('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (_isActive) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                _controller.clear();
                _focusNode.unfocus();
                widget.onCancel?.call();
                widget.onChanged?.call('');
              },
              child: Text('cancel'.tr),
            ),
          ],
        ],
      ),
    );
  }
}

class FastScopedSearchBar extends StatefulWidget {
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<int>? onScopeChanged;
  final List<String> scopes;
  final int selectedScope;
  final TextEditingController? controller;
  final bool autofocus;
  final bool enabled;

  const FastScopedSearchBar({
    super.key,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.onScopeChanged,
    required this.scopes,
    this.selectedScope = 0,
    this.controller,
    this.autofocus = false,
    this.enabled = true,
  });

  @override
  State<FastScopedSearchBar> createState() => _FastScopedSearchBarState();
}

class _FastScopedSearchBarState extends State<FastScopedSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FastSearchBar(
          placeholder: widget.placeholder,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          controller: widget.controller,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
        ),
        if (widget.scopes.isNotEmpty)
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.scopes.length,
              itemBuilder: (context, index) {
                final isSelected = index == widget.selectedScope;
                
                if (Theme.of(context).platform == TargetPlatform.iOS) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onPressed: () => widget.onScopeChanged?.call(index),
                      color: isSelected ? CupertinoColors.activeBlue : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Text(
                        widget.scopes[index],
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected 
                              ? CupertinoColors.white
                              : CupertinoColors.activeBlue,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(widget.scopes[index]),
                      selected: isSelected,
                      onSelected: (_) => widget.onScopeChanged?.call(index),
                    ),
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}