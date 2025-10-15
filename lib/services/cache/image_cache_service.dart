import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iOS-optimized image caching service that provides efficient image loading
/// and caching for list performance optimization
class IOSImageCacheService {
  static final IOSImageCacheService _instance =
      IOSImageCacheService._internal();
  factory IOSImageCacheService() => _instance;
  IOSImageCacheService._internal();

  // Cache for decoded images
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, Future<ui.Image>> _loadingImages = {};

  // Maximum cache size (number of images)
  static const int maxCacheSize = 100;

  // LRU tracking
  final List<String> _accessOrder = [];

  /// Preload and cache an image for iOS list performance
  Future<ui.Image?> preloadImage(String imageUrl, {Size? targetSize}) async {
    if (_imageCache.containsKey(imageUrl)) {
      _updateAccessOrder(imageUrl);
      return _imageCache[imageUrl];
    }

    // Check if already loading
    if (_loadingImages.containsKey(imageUrl)) {
      return await _loadingImages[imageUrl];
    }

    // Start loading
    final Future<ui.Image> loadingFuture =
        _loadImage(imageUrl, targetSize: targetSize);
    _loadingImages[imageUrl] = loadingFuture;

    try {
      final ui.Image image = await loadingFuture;
      _cacheImage(imageUrl, image);
      return image;
    } catch (e) {
      debugPrint('Failed to load image: $imageUrl, error: $e');
      return null;
    } finally {
      _loadingImages.remove(imageUrl);
    }
  }

  /// Load image with iOS-optimized decoding
  Future<ui.Image> _loadImage(String imageUrl, {Size? targetSize}) async {
    late Uint8List bytes;

    if (imageUrl.startsWith('http')) {
      // Network image
      final HttpClient client = HttpClient();
      try {
        final HttpClientRequest request =
            await client.getUrl(Uri.parse(imageUrl));
        final HttpClientResponse response = await request.close();

        if (response.statusCode == 200) {
          bytes = await consolidateHttpClientResponseBytes(response);
        } else {
          throw Exception('Failed to load image: ${response.statusCode}');
        }
      } finally {
        client.close();
      }
    } else {
      // Asset image
      final ByteData data = await rootBundle.load(imageUrl);
      bytes = data.buffer.asUint8List();
    }

    // Decode with target size for memory optimization
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetSize?.width.round(),
      targetHeight: targetSize?.height.round(),
    );

    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  /// Cache image with LRU eviction
  void _cacheImage(String key, ui.Image image) {
    // Remove if already exists to update position
    if (_imageCache.containsKey(key)) {
      _accessOrder.remove(key);
    }

    // Add to cache
    _imageCache[key] = image;
    _accessOrder.add(key);

    // Evict oldest if cache is full
    while (_imageCache.length > maxCacheSize) {
      final String oldestKey = _accessOrder.removeAt(0);
      final ui.Image? oldImage = _imageCache.remove(oldestKey);
      oldImage?.dispose();
    }
  }

  /// Update access order for LRU
  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  /// Get cached image
  ui.Image? getCachedImage(String imageUrl) {
    if (_imageCache.containsKey(imageUrl)) {
      _updateAccessOrder(imageUrl);
      return _imageCache[imageUrl];
    }
    return null;
  }

  /// Clear cache
  void clearCache() {
    for (final ui.Image image in _imageCache.values) {
      image.dispose();
    }
    _imageCache.clear();
    _accessOrder.clear();
    _loadingImages.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedImages': _imageCache.length,
      'loadingImages': _loadingImages.length,
      'maxCacheSize': maxCacheSize,
    };
  }
}

/// iOS-optimized cached network image widget
class FastCachedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableMemoryCache;

  const FastCachedImage({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableMemoryCache = true,
  });

  @override
  State<FastCachedImage> createState() => _FastCachedImageState();
}

class _FastCachedImageState extends State<FastCachedImage> {
  ui.Image? _cachedImage;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(FastCachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!widget.enableMemoryCache) {
      return; // Fall back to regular Image.network
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final Size? targetSize = widget.width != null && widget.height != null
          ? Size(widget.width!, widget.height!)
          : null;

      final ui.Image? image = await IOSImageCacheService().preloadImage(
        widget.imageUrl,
        targetSize: targetSize,
      );

      if (mounted) {
        setState(() {
          _cachedImage = image;
          _isLoading = false;
          _hasError = image == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableMemoryCache) {
      // Fallback to regular network image
      return Image.network(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return widget.placeholder ?? const CupertinoActivityIndicator();
        },
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? const Icon(Icons.error);
        },
      );
    }

    if (_isLoading || _cachedImage == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.placeholder ?? const CupertinoActivityIndicator(),
      );
    }

    if (_hasError) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.errorWidget ?? const Icon(Icons.error),
      );
    }

    return CustomPaint(
      size: Size(
          widget.width ?? double.infinity, widget.height ?? double.infinity),
      painter: _CachedImagePainter(_cachedImage!, widget.fit),
    );
  }
}

class _CachedImagePainter extends CustomPainter {
  final ui.Image image;
  final BoxFit fit;

  _CachedImagePainter(this.image, this.fit);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect imageRect =
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble());
    final Rect canvasRect = Offset.zero & size;

    final FittedSizes fittedSizes =
        applyBoxFit(fit, imageRect.size, canvasRect.size);
    final Rect sourceRect =
        Alignment.center.inscribe(fittedSizes.source, imageRect);
    final Rect destRect =
        Alignment.center.inscribe(fittedSizes.destination, canvasRect);

    canvas.drawImageRect(image, sourceRect, destRect, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _CachedImagePainter || oldDelegate.image != image;
  }
}
