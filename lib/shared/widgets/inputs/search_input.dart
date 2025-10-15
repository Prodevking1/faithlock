// SearchInput: A customizable search input widget for Flutter applications.
//
// This widget provides a flexible search input field that includes:
// - A text input field for search queries
// - A clear button to easily remove the entered text
// - Customizable hint text
// - Support for text change callbacks
// - Autofocus capability
//
// Key features:
// - Adaptive design for iOS and Android platforms
// - Clear button that appears when text is entered
// - Customizable appearance through theme
// - Support for focus management
//
// Usage:
// SearchInput(
//   controller: _searchController,
//   onChanged: (value) => print('Search query: $value'),
//   hintText: 'Search products...',
// )

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/export.dart';
import '../export.dart';

class FastSearchInput extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final bool autofocus;

  const FastSearchInput({
    required this.controller,
    super.key,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.focusNode,
    this.autofocus = false,
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
