// mobile/lib/shared/utils/image_picker_helper.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery.
  static Future<File?> pickImageFromGallery({bool requestFullMetadata = true}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        requestFullMetadata: requestFullMetadata,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Gallery pick error: $e');
      return null;
    }
  }

  /// Take a photo with camera.
  static Future<File?> pickImageFromCamera({double maxWidth = 1200, double maxHeight = 1200}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Camera error: $e');
      return null;
    }
  }

  /// Show a bottom sheet with options: Gallery / Camera / Cancel.
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
    if (result == null) return null;
    if (result == ImageSource.gallery) {
      return await pickImageFromGallery();
    } else if (result == ImageSource.camera) {
      return await pickImageFromCamera();
    }
    return null;
  }
}