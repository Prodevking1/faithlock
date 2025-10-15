/// **FastSearchInput** - Lightweight search input field with clear functionality and platform styling.
///
/// **Use Case:** 
/// Simple search input for quick filtering and search operations where you need basic search 
/// functionality without the additional UI elements of FastSearchBar. Perfect for embedded 
/// search within lists, tables, or compact layouts where space is limited.
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoSearchTextField on iOS, TextField on Android)
/// - Automatic clear button that appears when text is entered
/// - Customizable prefix and suffix icons
/// - Search-optimized keyboard and text input actions
/// - Internationalization support for placeholder text
/// - Focus management with autofocus capability
/// - Lightweight implementation without additional UI chrome
/// - Real-time text change callbacks for instant filtering
///
/// **Important Parameters:**
/// - `controller`: TextEditingController for managing search text (required)
/// - `hintText`: Placeholder text (defaults to translated "Search")
/// - `onChanged`: Callback when search text changes (real-time search)
/// - `onClear`: Callback when clear button is pressed
/// - `autofocus`: Automatically focus the search input when displayed
/// - `focusNode`: FocusNode for programmatic focus control
/// - `prefixIcon`: Custom prefix icon (defaults to search icon)
/// - `suffixIcon`: Custom suffix icon (clear button functionality preserved)
///
/// **Usage Examples:**
/// ```dart
/// // Basic search input
/// FastSearchInput(
///   controller: searchController,
///   hintText: 'Search items...',
///   onChanged: (query) => filterItems(query)
/// )
///
/// // Search with custom icons and clear handling
/// FastSearchInput(
///   controller: searchController,
///   prefixIcon: Icon(Icons.filter_list),
///   onChanged: (query) => performSearch(query),
///   onClear: () => resetSearchResults(),
///   autofocus: true
/// )
///
/// // Embedded search in list view
/// FastSearchInput(
///   controller: searchController,
///   hintText: 'Filter contacts',
///   onChanged: (query) => contactsController.filterContacts(query),
///   focusNode: searchFocusNode
/// )
/// ```

import 'package:faithlock/shared/widgets/buttons/fast_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/export.dart';

class FastSearchInput extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final bool autofocus;
  final Icon? suffixIcon;
  final Widget? prefixIcon;

  const FastSearchInput({
    required this.controller,
    super.key,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.focusNode,
    this.autofocus = false,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  _FastSearchInputState createState() => _FastSearchInputState();
}

class _FastSearchInputState extends State<FastSearchInput> {
  late bool _showClearButton;

  @override
  void initState() {
    super.initState();
    _showClearButton = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClearButton = widget.controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return isIOS ? _buildCupertinoSearch() : _buildMaterialSearch();
  }

  Widget _buildCupertinoSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CupertinoSearchTextField(
        prefixIcon:
            widget.prefixIcon ?? const FastIconButton(icon: Icon(Icons.search)),
        suffixIcon: widget.suffixIcon ?? const Icon(Icons.clear),
        controller: widget.controller,
        placeholder: widget.hintText ?? 'search'.tr,
        onChanged: widget.onChanged,
        onSubmitted: widget.onChanged,
        autocorrect: false,
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        onSuffixTap: () {
          widget.controller.clear();
          widget.onClear?.call();
        },
        style: const TextStyle(
          fontSize: 16,
        ),
        placeholderStyle: const TextStyle(
          color: CupertinoColors.systemGrey,
          fontSize: 16,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        prefixInsets: const EdgeInsets.only(left: 8, right: 4),
        suffixInsets: const EdgeInsets.only(right: 8),
        itemColor: CupertinoColors.systemGrey,
      ),
    );
  }

  Widget _buildMaterialSearch() {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'search'.tr,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _showClearButton
            ? FastIconButton(
                icon: const Icon(Icons.clear),
                onTap: () {
                  widget.controller.clear();
                  widget.onClear?.call();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FastSpacing.space16),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: FastSpacing.space4,
          horizontal: FastSpacing.space8,
        ),
      ),
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onChanged,
    );
  }
}
