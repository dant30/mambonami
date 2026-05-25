// mobile/lib/shared/widgets/custom_image_picker.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CustomImagePicker {
  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static Future<List<File>> pickMultipleImages({int maxCount = 5}) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(limit: maxCount);
    return pickedFiles.map((f) => File(f.path)).toList();
  }
}