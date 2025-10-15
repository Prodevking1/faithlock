/// **FastSystemCard** - Platform-native card with optional blur effects for modern UI designs.
///
/// **Use Case:** 
/// Perfect for content containers that need to feel integrated with the system UI. 
/// Great for overlays, modal content, or any card that should blend seamlessly 
/// with the platform's design language. The blur option creates modern glassmorphism effects.
///
/// **Key Features:**
/// - Platform-native styling (iOS system background, Material card elevation)
/// - Optional backdrop blur for glassmorphism effects
/// - Customizable padding, margins, and border radius
/// - Interactive tap support
/// - Automatic shadow and elevation handling
/// - Consistent with platform design guidelines
///
/// **Important Parameters:**
/// - `child`: Content widget to display inside the card (required)
/// - `padding`: Internal spacing around content
/// - `margin`: External spacing around the card
/// - `backgroundColor`: Custom background color (uses system default if null)
/// - `borderRadius`: Corner rounding (defaults to 12)
/// - `useBlur`: Enable backdrop blur effect for glassmorphism
/// - `blurSigma`: Blur intensity (default 10.0)
/// - `onTap`: Optional tap interaction callback
///
/// **Usage Examples:**
/// ```dart
/// // Basic system card
/// FastSystemCard(
///   child: Text('System integrated content')
/// )
///
/// // With blur effect for modern look
/// FastSystemCard(
///   useBlur: true,
///   blurSigma: 15.0,
///   child: Column(children: [
///     Text('Glassmorphism Card'),
///     Text('Modern blur effect')
///   ])
/// )
///
/// // Interactive card with custom styling
/// FastSystemCard(
///   backgroundColor: Colors.blue[50],
///   borderRadius: 16,
///   onTap: () => showDetails(),
///   child: ListTile(title: Text('Tap me'))
/// )
/// ```

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FastSystemCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool useBlur;
  final double blurSigma;
  final VoidCallback? onTap;

  const FastSystemCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.useBlur = false,
    this.blurSigma = 10.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return _buildCupertinoCard(context);
    } else {
      return _buildMaterialCard(context);
    }
  }

  Widget _buildCupertinoCard(BuildContext context) {
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.resolveFrom(context).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (useBlur) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: (backgroundColor ?? CupertinoColors.systemBackground.resolveFrom(context))
                  .withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
            padding: padding ?? const EdgeInsets.all(16),
            margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: child,
          ),
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildMaterialCard(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: useBlur ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
      ),
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

/// **FastOutlineCard** - Glassmorphism card with outline border for premium visual effects.
///
/// **Use Case:** 
/// For creating modern, premium-looking cards with glassmorphism effects. Perfect for 
/// hero sections, promotional content, or any interface element that needs to stand out 
/// with a sophisticated, translucent appearance.
///
/// **Key Features:**
/// - Glassmorphism design with backdrop blur
/// - Subtle outline border for definition
/// - Customizable blur intensity and glass color
/// - Platform-adaptive border styling
/// - Premium visual appearance
/// - Interactive tap support
///
/// **Important Parameters:**
/// - `child`: Content widget to display inside the card (required)
/// - `padding`: Internal spacing (defaults to 20px all around)
/// - `margin`: External spacing around the card
/// - `borderRadius`: Corner rounding (defaults to 16)
/// - `blurSigma`: Blur intensity for glass effect (default 15.0)
/// - `glassColor`: Glass overlay color (platform default if null)
/// - `onTap`: Optional tap interaction callback
///
/// **Usage Examples:**
/// ```dart
/// // Premium glass card
/// FastOutlineCard(
///   child: Column(children: [
///     Text('Premium Content', style: TextStyle(fontWeight: FontWeight.bold)),
///     Text('Glassmorphism effect')
///   ])
/// )
///
/// // Custom glass effect
/// FastOutlineCard(
///   blurSigma: 20.0,
///   glassColor: Colors.blue.withOpacity(0.1),
///   borderRadius: 20,
///   child: Text('Custom Glass Card')
/// )
/// ```

class FastOutlineCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double blurSigma;
  final Color? glassColor;
  final VoidCallback? onTap;

  FastOutlineCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurSigma = 15.0,
    this.glassColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveGlassColor = glassColor ??
        (Theme.of(context).platform == TargetPlatform.iOS
            ? CupertinoColors.systemBackground.resolveFrom(context).withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.8));

    Widget glassContent = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: effectiveGlassColor,
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
            border: Border.all(
              color: Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoColors.separator.resolveFrom(context).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: glassContent,
      );
    }

    return glassContent;
  }
}
