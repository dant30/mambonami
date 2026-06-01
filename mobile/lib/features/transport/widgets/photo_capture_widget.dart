import 'package:flutter/material.dart';
import 'dart:io';

class PhotoCaptureWidget extends StatefulWidget {
  final String title;
  final String? description;
  final Function(File?) onPhotoSelected;
  final String? initialPhotoPath;

  const PhotoCaptureWidget({
    super.key,
    required this.title,
    this.description,
    required this.onPhotoSelected,
    this.initialPhotoPath,
  });

  @override
  State<PhotoCaptureWidget> createState() => _PhotoCaptureWidgetState();
}

class _PhotoCaptureWidgetState extends State<PhotoCaptureWidget> {
  File? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhotoPath != null && widget.initialPhotoPath!.isNotEmpty) {
      _selectedPhoto = File(widget.initialPhotoPath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (widget.description != null) ...[              const SizedBox(height: 4),
              Text(
                widget.description!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            if (_selectedPhoto == null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No photo selected',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedPhoto!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectPhoto,
                    icon: const Icon(Icons.image),
                    label: const Text('Select Photo'),
                  ),
                ),
                if (_selectedPhoto != null) ...[                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _clearPhoto,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectPhoto() {
    // TODO: Implement photo selection using image_picker or camera
    // For now, this is a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo selection to be implemented')),
    );
  }

  void _clearPhoto() {
    setState(() {
      _selectedPhoto = null;
    });
    widget.onPhotoSelected(null);
  }
}

