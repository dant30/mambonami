import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.photos.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  static Future<bool> requestDeliveryPermissions() async {
    final camera = await requestCameraPermission();
    final storage = await requestStoragePermission();
    final location = await requestLocationPermission();
    return camera && storage && location;
  }

  static Future<bool> _isAndroid13OrAbove() async {
    return Platform.isAndroid;
  }

  static Future<bool> requestCameraPermissionWithContext(BuildContext context) async {
    final granted = await requestCameraPermission();
    if (!granted && context.mounted) {
      _showOpenSettingsDialogWithContext(
        context,
        title: 'Camera Permission Denied',
        message: 'Camera access is permanently denied. Please enable it in settings.',
      );
    }
    return granted;
  }

  static void _showOpenSettingsDialogWithContext(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}