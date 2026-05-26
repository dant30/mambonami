import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  /// Check whether location services are enabled on the device.
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check the current location permission state.
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission from the user.
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get the current device position.
  ///
  /// Returns null if the location could not be retrieved.
  static Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.best,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      ).timeout(timeout);
    } on PermissionDeniedException catch (_) {
      return null;
    } on LocationServiceDisabledException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get the last known position if available.
  static Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  /// Compute the distance in meters between two locations.
  static double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}

