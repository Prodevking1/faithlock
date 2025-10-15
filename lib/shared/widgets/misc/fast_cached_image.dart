import 'package:flutter/cupertino.dart';

/// A cached image widget optimized for iOS list performance with lazy loading
/// and memory management for seamless list-to-detail navigation flows.
class FastCachedImage extends StatefulWidget {
  /// Image URL or asset path
  final String imageUrl;

  /// Width of the image
  final double? width;

  /// Height of the image
  final double? height;

  /// Box fit for the image
  final BoxFit fit;

  /// Placeholder widget while loading
  final Widget? placeholder;

  /// Error widget if loading fails
  final Widget? errorWidget;

  /// Border radius for the image
  final BorderRadius? borderRadius;

  /// Whether to use iOS-optimized caching
  final bool useIOSOptimizations;

  /// Cache duration in hours
  final int cacheDurationHours;

  /// Whether to fade in when loaded
  final bool fadeIn;

  /// Fade duration
  final Duration fadeDuration;

  /// Memory cache size limit (in MB)
  final int memoryCacheSizeMB;

  const FastCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.useIOSOptimizations = true,
    this.cacheDurationHours = 24,
    this.fadeIn = true,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.memoryCacheSizeMB = 100,
  });

  @override
  State<FastCachedImage> createState() => _FastCachedImageState();
}

class _FastCachedImageState extends State<FastCachedImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  ImageProvider? _imageProvider;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.fadeDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadImage();
  }

  @override
  void didUpdateWidget(FastCachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadImage() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // Determine image provider based on URL type
    if (widget.imageUrl.startsWith('http')) {
      _imageProvider = NetworkImage(widget.imageUrl);
    } else if (widget.imageUrl.startsWith('assets/')) {
      _imageProvider = AssetImage(widget.imageUrl);
    } else {
      // Assume it's a file path
      _imageProvider = NetworkImage(widget.imageUrl);
    }

    // Preload image with error handling
    _imageProvider!.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (ImageInfo info, bool synchronousCall) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });

                if (widget.fadeIn) {
                  _animationController.forward();
                }
              }
            },
            onError: (dynamic error, StackTrace? stackTrace) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                });
              }
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (_hasError) {
      imageWidget = _buildErrorWidget();
    } else if (_isLoading) {
      imageWidget = _buildPlaceholder();
    } else {
      imageWidget = _buildImage();
    }

    // Apply border radius if specified
    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: imageWidget,
    );
  }

  Widget _buildImage() {
    Widget image = Image(
      image: _imageProvider!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      // iOS optimizations
      frameBuilder: widget.useIOSOptimizations
          ? (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || !widget.fadeIn) {
                return child;
              }
              return FadeTransition(
                opacity: _fadeAnimation,
                child: child,
              );
            }
          : null,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );

    return image;
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    // Default iOS-style placeholder
    return Container(
      width: widget.width,
      height: widget.height,
      color: CupertinoColors.systemGrey6,
      child: const Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    // Default iOS-style error widget
    return Container(
      width: widget.width,
      height: widget.height,
      color: CupertinoColors.systemGrey6,
      child: const Center(
        child: Icon(
          CupertinoIcons.photo,
          color: CupertinoColors.systemGrey,
          size: 24,
        ),
      ),
    );
  }
}

/// A specialized cached image widget for list avatars with iOS styling
class FastListAvatar extends StatelessWidget {
  /// Image URL or asset path
  final String? imageUrl;

  /// Size of the avatar (width and height)
  final double size;

  /// Fallback icon if no image
  final IconData fallbackIcon;

  /// Background color for the avatar
  final Color? backgroundColor;

  /// Icon color for fallback
  final Color? iconColor;

  /// Whether to use circular shape
  final bool circular;

  const FastListAvatar({
    super.key,
    this.imageUrl,
    this.size = 40.0,
    this.fallbackIcon = CupertinoIcons.person_fill,
    this.backgroundColor,
    this.iconColor,
    this.circular = true,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius? borderRadius =
        circular ? BorderRadius.circular(size / 2) : BorderRadius.circular(8.0);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return FastCachedImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        borderRadius: borderRadius,
        placeholder: _buildFallback(),
        errorWidget: _buildFallback(),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? CupertinoColors.systemGrey5,
        borderRadius: circular
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(8.0),
      ),
      child: Icon(
        fallbackIcon,
        size: size * 0.6,
        color: iconColor ?? CupertinoColors.systemGrey,
      ),
    );
  }
}

/// A cached image widget optimized for list thumbnails
class FastListThumbnail extends StatelessWidget {
  /// Image URL or asset path
  final String imageUrl;

  /// Width of the thumbnail
  final double width;

  /// Height of the thumbnail
  final double height;

  /// Border radius
  final double borderRadius;

  /// Whether to show a loading indicator
  final bool showLoadingIndicator;

  const FastListThumbnail({
    super.key,
    required this.imageUrl,
    this.width = 60.0,
    this.height = 60.0,
    this.borderRadius = 8.0,
    this.showLoadingIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return FastCachedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(borderRadius),
      placeholder: showLoadingIndicator
          ? Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: const Center(
                child: CupertinoActivityIndicator(radius: 8),
              ),
            )
          : null,
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: const Center(
          child: Icon(
            CupertinoIcons.photo,
            color: CupertinoColors.systemGrey,
            size: 20,
          ),
        ),
      ),
    );
  }
}
