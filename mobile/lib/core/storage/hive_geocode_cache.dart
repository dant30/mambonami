// mobile/lib/core/storage/hive_geocode_cache.dart
import 'package:hive/hive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeocodeCache {
  static const String _boxName = 'geocode_cache';
  late final Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> set(String address, LatLng? latLng) async {
    if (latLng == null) return;
    await _box.put(address, {'lat': latLng.latitude, 'lng': latLng.longitude});
  }

  LatLng? get(String address) {
    final data = _box.get(address);
    if (data != null && data is Map) {
      return LatLng(data['lat'] as double, data['lng'] as double);
    }
    return null;
  }
}