// mobile/lib/shared/widgets/custom_image_picker.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CustomImagePicker {
  static Future<File?> pickImage(
      {ImageSource source = ImageSource.gallery}) async {
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

  static Future<File?> pickImageWithCompression({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static Future<File?> showImageSourceSheet(BuildContext context) {
    final theme = Theme.of(context);
    return showModalBottomSheet<File?>(
      context: context,
      showDragHandle: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add image',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _ImageSourceTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Camera',
                  onTap: () async {
                    final file = await pickImage(source: ImageSource.camera);
                    if (context.mounted) Navigator.pop(context, file);
                  },
                ),
                const SizedBox(height: 8),
                _ImageSourceTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Gallery',
                  onTap: () async {
                    final file = await pickImage(source: ImageSource.gallery);
                    if (context.mounted) Navigator.pop(context, file);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ImageSourceTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      tileColor: theme.colorScheme.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
