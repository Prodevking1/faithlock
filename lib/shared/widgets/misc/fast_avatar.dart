// Start Generation Here
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A versatile and customizable avatar widget that adapts to different platforms,
/// providing a native feel for each. It supports displaying images, initials,
/// and provides customization options for shape, size, borders, and more.
///
/// Example Usage:
/// ```
/// Avatar(
///   imageUrl: 'https://example.com/avatar.png',
///   initials: 'AB',
///   size: 60.0,
///   backgroundColor: Colors.blue,
///   border: Border.all(color: Colors.white, width: 2),
///   onTap: () {
///     // Handle avatar tap
///   },
/// )
/// ```
class FastAvatar extends StatelessWidget {
  final String? imageUrl;

  final Uint8List? imageBytes;

  final String? initials;

  final double size;

  final Color backgroundColor;

  final TextStyle? textStyle;

  final VoidCallback? onTap;

  final BoxBorder? border;

  final BoxShape shape;

  const FastAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 50.0,
    this.backgroundColor = Colors.grey,
    this.textStyle,
    this.onTap,
    this.border,
    this.shape = BoxShape.circle,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final Widget avatarContent = ClipOval(
      child: imageUrl != null 
          ? Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            )
          : _buildPlaceholder(),
    );

    final Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border,
        shape: shape,
      ),
      child: shape == BoxShape.circle
          ? ClipOval(child: avatarContent)
          : avatarContent,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: _platformAvatar(context, avatar),
      );
    } else {
      return _platformAvatar(context, avatar);
    }
  }

  Widget _platformAvatar(BuildContext context, Widget avatar) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: avatar,
      );
    } else {
      return Material(
        color: Colors.transparent,
        child: avatar,
      );
    }
  }

  Widget _buildPlaceholder() {
    if (initials != null && initials!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        color: backgroundColor,
        child: Text(
          _getInitials(),
          style: textStyle ??
              TextStyle(
                color: Colors.white,
                fontSize: size / 2,
                fontWeight: FontWeight.bold,
              ),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        color: backgroundColor,
        child: Icon(
          Icons.person,
          size: size / 2,
          color: Colors.white,
        ),
      );
    }
  }

  String _getInitials() {
    if (initials == null) return '';
    final parts = initials!.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
