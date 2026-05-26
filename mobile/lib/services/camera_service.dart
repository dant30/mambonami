import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  CameraService._();

  static final ImagePicker _picker = ImagePicker();

  /// Capture a single photo using the device camera.
  ///
  /// Returns a [File] when the user successfully takes a picture.
  /// Returns null when the user cancels or if an error occurs.
  static Future<File?> capturePhoto({
    int imageQuality = 80,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      return pickedFile == null ? null : File(pickedFile.path);
    } catch (error, stackTrace) {
      debugPrint('CameraService.capturePhoto failed: $error');
      debugPrint(stackTrace.toString());
      return null;
    }
  }

  /// Pick a single image from the device gallery.
  static Future<File?> pickFromGallery({
    int imageQuality = 80,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      return pickedFile == null ? null : File(pickedFile.path);
    } catch (error, stackTrace) {
      debugPrint('CameraService.pickFromGallery failed: $error');
      debugPrint(stackTrace.toString());
      return null;
    }
  }

  /// Pick multiple images from the gallery.
  static Future<List<File>> pickMultipleFromGallery({
    int maxImages = 5,
  }) async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      if (pickedFiles == null) return <File>[];
      return pickedFiles.take(maxImages).map((file) => File(file.path)).toList();
    } catch (error, stackTrace) {
      debugPrint('CameraService.pickMultipleFromGallery failed: $error');
      debugPrint(stackTrace.toString());
      return <File>[];
    }
  }
}

