/// **FastText** - iOS-style text widget with Dynamic Type support and semantic text styles.
///
/// **Use Case:**
/// Use this for all text display throughout your app to ensure consistent typography
/// that follows iOS Human Interface Guidelines. Perfect for titles, body text, labels,
/// and UI elements that need to adapt to user accessibility settings and device scaling.
///
/// **Key Features:**
/// - Complete iOS typography hierarchy (Large Title, Title 1-3, Headline, Body, etc.)
/// - Dynamic Type support with automatic scaling based on user accessibility settings
/// - Semantic text styles for common UI components (navigation, lists, buttons, forms)
/// - Platform-adaptive fallbacks to Material Design typography on Android
/// - Comprehensive text styling options (color, alignment, overflow, selection)
/// - Built-in accessibility support with semantic labels and screen reader compatibility
/// - Convenient named constructors for quick styling without enum parameters
///
/// **Important Parameters:**
/// - `text`: The text content to display (required)
/// - `style`: iOS text style enum (largeTitle, title1, body, etc.)
/// - `semantic`: Semantic style enum (navigationTitle, listTitle, error, etc.)
/// - `customStyle`: Override with custom TextStyle
/// - `color`: Text color override
/// - `enableDynamicType`: Whether to respect user's accessibility text size settings
/// - `selectable`: Whether text can be selected and copied by user
///
/// **Usage Example:**
/// ```dart
/// // Basic text with iOS styling
/// FastText(
///   'Hello World',
///   style: FastTextStyle.title1,
///   color: Colors.blue,
/// )
///
/// // Using convenient constructors
/// FastText.largeTitle('App Title')
/// FastText.body('This is body text content')
/// FastText.caption1('Small detail text')
///
/// // Semantic text for UI components
/// FastText.navigationTitle('Settings')
/// FastText.listTitle('Primary List Item')
/// FastText.listSubtitle('Secondary information')
/// FastText.error('Invalid input')
/// FastText.success('Operation completed')
///
/// // Advanced configuration
/// FastText(
///   'Long text that might overflow...',
///   style: FastTextStyle.body,
///   maxLines: 2,
///   overflow: TextOverflow.ellipsis,
///   selectable: true,
///   semanticsLabel: 'Accessible description',
/// )
/// ```

import 'package:flutter/material.dart';

import 'fast_text_style.dart';

/// Text style types for FastText widget
enum FastTextStyleType {
  largeTitle,
  title1,
  title2,
  title3,
  headline,
  body,
  callout,
  subheadline,
  footnote,
  caption1,
  caption2,
}

/// Semantic text styles for common use cases
enum FastTextSemantic {
  navigationTitle,
  navigationLargeTitle,
  button,
  listTitle,
  listSubtitle,
  tabLabel,
  textInput,
  textInputPlaceholder,
  error,
  success,
  secondaryLabel,
  tertiaryLabel,
}

/// A text widget that automatically applies iOS typography styles
/// with Dynamic Type support and fallback to Material styles
class FastText extends StatelessWidget {
  /// The text to display
  final String text;

  /// iOS text style to apply
  final FastTextStyleType? style;

  /// Semantic text style to apply
  final FastTextSemantic? semantic;

  /// Custom text style to apply (overrides style and semantic)
  final TextStyle? customStyle;

  /// Text color (overrides default color)
  final Color? color;

  /// Whether to enable Dynamic Type scaling
  final bool enableDynamicType;

  /// Text alignment
  final TextAlign? textAlign;

  /// Text overflow behavior
  final TextOverflow? overflow;

  /// Maximum number of lines
  final int? maxLines;

  /// Whether text should be soft wrapped
  final bool? softWrap;

  /// Text selection behavior
  final bool selectable;

  /// Semantic label for accessibility
  final String? semanticsLabel;

  const FastText(
    this.text, {
    super.key,
    this.style,
    this.semantic,
    this.customStyle,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  }) : assert(
          (style == null) != (semantic == null) || customStyle != null,
          'Either style or semantic must be provided, or use customStyle',
        );

  /// Create a large title text
  FastText.largeTitle(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = FastTextStyleType.largeTitle,
        semantic = null,
        customStyle = null;

  /// Create a title 1 text
  FastText.title1(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = FastTextStyleType.title1,
        semantic = null,
        customStyle = null;

  /// Create a title 2 text
  FastText.title2(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = FastTextStyleType.title2,
        semantic = null,
        customStyle = null;

  /// Create a title 3 text
  FastText.title3(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = FastTextStyleType.title3,
        semantic = null,
        customStyle = null;

  /// Create a headline text
  FastText.headline(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = FastTextStyleType.headline,
        semantic = null,
        customStyle = null;

  /// Create a body text
  FastText.body(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = FastTextStyleType.body,
        semantic = null,
        customStyle = null;

  /// Create a callout text
  FastText.callout(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = FastTextStyleType.callout,
        semantic = null,
        customStyle = null;

  /// Create a subheadline text
  FastText.subheadline(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = FastTextStyleType.subheadline,
        semantic = null,
        customStyle = null;

  /// Create a footnote text
  FastText.footnote(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = FastTextStyleType.footnote,
        semantic = null,
        customStyle = null;

  /// Create a caption 1 text
  FastText.caption1(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = FastTextStyleType.caption1,
        semantic = null,
        customStyle = null;

  /// Create a caption 2 text
  FastText.caption2(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = FastTextStyleType.caption2,
        semantic = null,
        customStyle = null;

  // Semantic constructors

  /// Create a navigation title text
  FastText.navigationTitle(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = null,
        semantic = FastTextSemantic.navigationTitle,
        customStyle = null;

  /// Create a list title text
  FastText.listTitle(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = null,
        semantic = FastTextSemantic.listTitle,
        customStyle = null;

  /// Create a list subtitle text
  FastText.listSubtitle(
    this.text, {
    super.key,
    this.color,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = null,
        semantic = FastTextSemantic.listSubtitle,
        customStyle = null;

  /// Create an error text
  FastText.error(
    this.text, {
    super.key,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = null,
        semantic = FastTextSemantic.error,
        customStyle = null,
        color = null;

  /// Create a success text
  FastText.success(
    this.text, {
    super.key,
    this.enableDynamicType = true,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.selectable = false,
    this.semanticsLabel,
  })  : style = null,
        semantic = FastTextSemantic.success,
        customStyle = null,
        color = null;

  @override
  Widget build(BuildContext context) {
    TextStyle effectiveStyle;

    if (customStyle != null) {
      effectiveStyle = customStyle!;
    } else if (style != null) {
      effectiveStyle = _getStyleFromEnum(context, style!);
    } else if (semantic != null) {
      effectiveStyle = _getSemanticStyle(context, semantic!);
    } else {
      effectiveStyle = FastTextStyle.body(context);
    }

    // Apply color override if provided
    if (color != null) {
      effectiveStyle = effectiveStyle.copyWith(color: color);
    }

    Widget textWidget = Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      semanticsLabel: semanticsLabel,
    );

    // Return selectable text if requested
    if (selectable) {
      return SelectableText(
        text,
        style: effectiveStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
      );
    }

    return textWidget;
  }

  TextStyle _getStyleFromEnum(BuildContext context, FastTextStyleType style) {
    switch (style) {
      case FastTextStyleType.largeTitle:
        return FastTextStyle.largeTitle(context,
            enableDynamicType: enableDynamicType);
      case FastTextStyleType.title1:
        return FastTextStyle.title1(context,
            enableDynamicType: enableDynamicType);
      case FastTextStyleType.title2:
        return FastTextStyle.title2(context,
            enableDynamicType: enableDynamicType);
      case FastTextStyleType.title3:
        return FastTextStyle.title3(context,
            enableDynamicType: enableDynamicType);
      case FastTextStyleType.headline:
        return FastTextStyle.headline(context,
            enableDynamicType: enableDynamicType);
      case FastTextStyleType.body:
        return FastTextStyle.body(context,
            enableDynamicType: enableDynamicType);
      case FastTextStyleType.callout:
        return FastTextStyle.callout(context,
            enableDynamicType: enableDynamicType);
      case FastTextStyleType.subheadline:
        return FastTextStyle.subheadline(context,
            enableDynamicType: enableDynamicType);
      case FastTextStyleType.footnote:
        return FastTextStyle.footnote(context,
            enableDynamicType: enableDynamicType);
      case FastTextStyleType.caption1:
        return FastTextStyle.caption1(context,
            enableDynamicType: enableDynamicType);
      case FastTextStyleType.caption2:
        return FastTextStyle.caption2(context,
            enableDynamicType: enableDynamicType);
    }
  }

  TextStyle _getSemanticStyle(BuildContext context, FastTextSemantic semantic) {
    switch (semantic) {
      case FastTextSemantic.navigationTitle:
        return FastTextStyle.navigationTitle(context);
      case FastTextSemantic.navigationLargeTitle:
        return FastTextStyle.navigationLargeTitle(context);
      case FastTextSemantic.button:
        return FastTextStyle.button(context, color: color);
      case FastTextSemantic.listTitle:
        return FastTextStyle.listTitle(context);
      case FastTextSemantic.listSubtitle:
        return FastTextStyle.listSubtitle(context);
      case FastTextSemantic.tabLabel:
        return FastTextStyle.tabLabel(context);
      case FastTextSemantic.textInput:
        return FastTextStyle.textInput(context);
      case FastTextSemantic.textInputPlaceholder:
        return FastTextStyle.textInputPlaceholder(context);
      case FastTextSemantic.error:
        return FastTextStyle.error(context);
      case FastTextSemantic.success:
        return FastTextStyle.success(context);
      case FastTextSemantic.secondaryLabel:
        return FastTextStyle.secondaryLabel(context);
      case FastTextSemantic.tertiaryLabel:
        return FastTextStyle.tertiaryLabel(context);
    }
  }
}
