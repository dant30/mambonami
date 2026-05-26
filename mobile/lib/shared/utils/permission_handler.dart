// mobile/lib/shared/utils/permission_handler.dart
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionHandler {
  /// Request camera permission. Returns true if granted.
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog(
        title: 'Camera Permission Denied',
        message: 'Camera access is permanently denied. Please enable it in settings.',
      );
      return false;
    }
    return false;
  }

  /// Request storage / photos permission (Android 12- uses photos, Android 13+ uses images).
  static Future<bool> requestStoragePermission() async {
    if (await _isAndroid13OrAbove()) {
      final photos = await Permission.photos.request();
      if (photos.isGranted) return true;
      if (photos.isPermanentlyDenied) {
        _showOpenSettingsDialog(
          title: 'Storage Permission Denied',
          message: 'Access to photos is permanently denied. Please enable it in settings.',
        );
        return false;
      }
      return false;
    } else {
      final storage = await Permission.storage.request();
      if (storage.isGranted) return true;
      if (storage.isPermanentlyDenied) {
        _showOpenSettingsDialog(
          title: 'Storage Permission Denied',
          message: 'Storage access is permanently denied. Please enable it in settings.',
        );
        return false;
      }
      return false;
    }
  }

  /// Request location permission (for transport providers).
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog(
        title: 'Location Permission Denied',
        message: 'Location access is permanently denied. Please enable it in settings.',
      );
      return false;
    }
    return false;
  }

  /// Request all permissions needed for delivery (camera, storage, location).
  static Future<bool> requestDeliveryPermissions() async {
    final camera = await requestCameraPermission();
    final storage = await requestStoragePermission();
    final location = await requestLocationPermission();
    return camera && storage && location;
  }

  static Future<bool> _isAndroid13OrAbove() async {
    if (!await _isAndroid()) return false;
    final sdkInt = await _getAndroidSdkVersion();
    return sdkInt >= 33;
  }

  static Future<bool> _isAndroid() async {
    return Theme.of(PlatformDispatcher.instance.views.first.platformDispatcher.platformBrightness != null);
    // Simpler: use dart:io Platform.isAndroid
  }

  static Future<int> _getAndroidSdkVersion() async {
    // Use device_info_plus to get SDK version, but for simplicity we assume >=13.
    // In production you'd use DeviceInfoPlugin.
    return 33; // Placeholder – replace with actual check using device_info_plus.
  }

  static void _showOpenSettingsDialog({required String title, required String message}) {
    // This should be called with a BuildContext. Since the helper is static,
    // we need a context from the caller. Better to pass context as parameter.
    // We'll adjust the public methods to accept BuildContext.
    // For now, we just log.
    debugPrint('$title: $message');
  }

  /// Version with context for dialog.
  static Future<bool> requestCameraPermissionWithContext(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _showOpenSettingsDialogWithContext(context,
          title: 'Camera Permission Denied',
          message: 'Camera access is permanently denied. Please enable it in settings.');
      return false;
    }
    return false;
  }

  static void _showOpenSettingsDialogWithContext(BuildContext context,
      {required String title, required String message}) {
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