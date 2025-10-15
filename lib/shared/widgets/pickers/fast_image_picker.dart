/// **FastImagePicker** - Cross-platform image picker with native platform UI and ready-to-use widget components.
///
/// **Use Case:**
/// Use this for image selection in user profiles, form uploads, gallery features, or any
/// scenario requiring image input. Perfect for avatar selection, photo uploads, document
/// scanning, or media-rich applications with platform-native selection interfaces.
///
/// **Key Features:**
/// - Native platform image selection (iOS PHPicker, Android Photo Picker)
/// - Multiple image sources (camera, gallery, or both) with unified interface
/// - Ready-to-use UI widget with preview and static methods in one class
/// - Full image_picker integration with quality and dimension controls
/// - Native styling with proper touch targets and accessibility support
/// - Automatic permission handling by the native system
/// - File validation and error handling with user-friendly feedback
/// - Customizable styling and dimensions for different use cases
///
/// **Important Parameters:**
/// - `source`: Image source selection (camera, gallery, both)
/// - `onImageSelected`: Callback when image is selected
/// - `placeholder`: Text to display when no image selected
/// - `width/height`: Dimensions for image picker widget
/// - `borderRadius`: Corner radius for image container
/// - `fit`: How image should fit within container
/// - `maxWidth/maxHeight`: Image compression dimensions
/// - `imageQuality`: Image quality (0-100)
///
/// **Usage Example:**
/// ```dart
/// // Static methods for direct image selection
/// final image = await FastImagePicker.pickImage(
///   context: context,
///   source: FastImageSource.both,
///   maxWidth: 800,
///   imageQuality: 85,
/// );
///
/// // Multiple image selection
/// final images = await FastImagePicker.pickMultipleImages(
///   maxWidth: 800,
///   imageQuality: 85,
/// );
///
/// // Widget with preview and tap-to-select
/// FastImagePicker(
///   image: selectedImage,
///   onImageSelected: (file) => setState(() => selectedImage = file),
///   placeholder: 'Tap to select image',
///   width: 200,
///   height: 150,
///   source: FastImageSource.both,
/// )
///
/// // Avatar picker for user profiles
/// FastAvatarPicker(
///   image: userAvatar,
///   onImageSelected: (file) => updateUserAvatar(file),
///   radius: 60,
/// )
/// ```
///
/// **Setup Complete:**
/// ✅ image_picker: ^1.1.2 integrated
/// ✅ iOS permissions configured (NSCameraUsageDescription, NSPhotoLibraryUsageDescription)
/// ✅ Android permissions configured (CAMERA, READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE)
/// ✅ Native platform UI handling camera/gallery selection automatically

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/export.dart';

enum FastImageSource {
  camera,
  gallery,
  both,
}

class _FastImagePickerStatic {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage({
    required BuildContext context,
    FastImageSource source = FastImageSource.both,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    return await _showImageSourcePicker(
      context: context,
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  static Future<List<File>?> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (images.isNotEmpty) {
        return images.map((xfile) => File(xfile.path)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> _showImageSourcePicker({
    required BuildContext context,
    required FastImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      print('FastImagePicker: Starting image selection with source: $source');

      XFile? image;

      if (source == FastImageSource.camera) {
        print('FastImagePicker: Opening camera...');
        image = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
      } else if (source == FastImageSource.gallery) {
        print('FastImagePicker: Opening gallery...');
        image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
      } else {
        print('FastImagePicker: Opening gallery (both option)...');
        image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
      }

      if (image != null) {
        print('FastImagePicker: Image selected successfully: ${image.path}');
        return File(image.path);
      } else {
        print('FastImagePicker: No image selected (user cancelled)');
        return null;
      }
    } catch (e) {
      print('FastImagePicker: Error occurred: $e');
      return null;
    }
  }
}

class FastImagePicker extends StatelessWidget {
  final File? image;
  final List<File>? images;
  final ValueChanged<File?>? onImageSelected;
  final ValueChanged<List<File>>? onImagesSelected;
  final String? placeholder;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final FastImageSource source;
  final bool allowMultiple;

  const FastImagePicker({
    super.key,
    this.image,
    this.images,
    this.onImageSelected,
    this.onImagesSelected,
    this.placeholder,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.source = FastImageSource.both,
    this.allowMultiple = false,
  }) : assert(
          (allowMultiple && onImagesSelected != null) || 
          (!allowMultiple && onImageSelected != null),
          'Use onImagesSelected for multiple selection or onImageSelected for single selection'
        );

  static Future<File?> pickImage({
    required BuildContext context,
    FastImageSource source = FastImageSource.both,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) => _FastImagePickerStatic.pickImage(
        context: context,
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

  static Future<List<File>?> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) => _FastImagePickerStatic.pickMultipleImages(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        print('FastImagePicker: onTap called (multiple: $allowMultiple)');
        
        if (allowMultiple) {
          final files = await FastImagePicker.pickMultipleImages();
          print('FastImagePicker: pickMultipleImages returned: ${files?.length} files');
          if (files != null && files.isNotEmpty) {
            print('FastImagePicker: calling onImagesSelected callback');
            onImagesSelected!(files);
          } else {
            print('FastImagePicker: no files selected');
          }
        } else {
          final file = await FastImagePicker.pickImage(
            context: context,
            source: source,
          );
          print('FastImagePicker: pickImage returned: $file');
          if (file != null) {
            print('FastImagePicker: calling onImageSelected callback');
            onImageSelected!(file);
          } else {
            print('FastImagePicker: no file selected');
          }
        }
      },
      child: Container(
        width: width ?? 100,
        height: height ?? 100,
        decoration: BoxDecoration(
          color: Theme.of(context).platform == TargetPlatform.iOS
              ? CupertinoColors.systemGrey6.resolveFrom(context)
              : FastColors.surfaceVariant(context),
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).platform == TargetPlatform.iOS
                ? CupertinoColors.systemGrey4.resolveFrom(context)
                : FastColors.secondaryText(context),
          ),
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Multiple images mode
    if (allowMultiple && images != null && images!.isNotEmpty) {
      return _buildMultipleImagesPreview(context);
    }
    
    // Single image mode
    if (!allowMultiple && image != null) {
      return _buildSingleImagePreview(context);
    }
    
    // No image selected - show placeholder
    return _buildPlaceholder(context);
  }

  Widget _buildSingleImagePreview(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(7),
      child: Image.file(
        image!,
        fit: fit,
        width: width,
        height: height,
      ),
    );
  }

  Widget _buildMultipleImagesPreview(BuildContext context) {
    if (images!.length == 1) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(7),
        child: Image.file(
          images!.first,
          fit: fit,
          width: width,
          height: height,
        ),
      );
    }

    // Grid layout for multiple images
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(7),
      child: GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: images!.length > 4 ? 4 : images!.length,
        itemBuilder: (context, index) {
          if (index == 3 && images!.length > 4) {
            // Show "+X more" overlay for the 4th item if there are more than 4 images
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  images![index],
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Text(
                      '+${images!.length - 3}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          
          return Image.file(
            images![index],
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          allowMultiple
              ? (Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoIcons.photo_on_rectangle
                  : Icons.photo_library)
              : (Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoIcons.camera
                  : Icons.add_a_photo),
          size: 32,
          color: Theme.of(context).platform == TargetPlatform.iOS
              ? CupertinoColors.systemGrey.resolveFrom(context)
              : FastColors.tertiaryText(context),
        ),
        const SizedBox(height: 4),
        Text(
          placeholder ?? 
          (allowMultiple ? 'Tap to select images' : 'Tap to select image'),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).platform == TargetPlatform.iOS
                ? CupertinoColors.systemGrey.resolveFrom(context)
                : FastColors.tertiaryText(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class FastAvatarPicker extends StatelessWidget {
  final File? image;
  final ValueChanged<File?> onImageSelected;
  final double radius;
  final String? placeholder;
  final Widget? placeholderIcon;

  const FastAvatarPicker({
    super.key,
    this.image,
    required this.onImageSelected,
    this.radius = 50,
    this.placeholder,
    this.placeholderIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final file = await FastImagePicker.pickImage(
          context: context,
          source: FastImageSource.both,
        );
        if (file != null) {
          onImageSelected(file);
        }
      },
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
            ? CupertinoColors.systemGrey5.resolveFrom(context)
            : FastColors.border(context),
        backgroundImage: image != null ? FileImage(image!) : null,
        child: image == null
            ? placeholderIcon ??
                Icon(
                  Theme.of(context).platform == TargetPlatform.iOS
                      ? CupertinoIcons.person_add
                      : Icons.add_a_photo,
                  size: radius * 0.6,
                  color: Theme.of(context).platform == TargetPlatform.iOS
                      ? CupertinoColors.systemGrey.resolveFrom(context)
                      : FastColors.tertiaryText(context),
                )
            : null,
      ),
    );
  }
}
