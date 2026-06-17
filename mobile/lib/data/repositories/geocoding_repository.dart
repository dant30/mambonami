// mobile/lib/data/repositories/geocoding_repository.dart
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/storage/hive_geocode_cache.dart';

class GeocodingRepository {
  final GeocodeCache _cache;

  GeocodingRepository(this._cache);

  // In-memory cache (for current session)
  final Map<String, LatLng> _memoryCache = {};

  Future<LatLng> geocodeAddress(String address) async {
    // 1. Check memory cache
    if (_memoryCache.containsKey(address)) {
      return _memoryCache[address]!;
    }

    // 2. Check Hive cache
    final cached = _cache.get(address);
    if (cached != null) {
      _memoryCache[address] = cached;
      return cached;
    }

    // 3. Call Google Geocoding API (via geocoding package)
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) {
        throw Exception('Address not found');
      }
      final latLng = LatLng(locations.first.latitude, locations.first.longitude);
      
      // 4. Store in both caches
      _memoryCache[address] = latLng;
      await _cache.set(address, latLng);
      return latLng;
    } catch (e) {
      throw Exception('Failed to geocode address: $e');
    }
  }

  Future<String> reverseGeocode(LatLng latLng) async {
    // Reverse geocoding can also be cached, but we'll keep it simple – address is less likely to be reused exactly.
    final placemarks = await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );
    if (placemarks.isEmpty) return 'Unknown location';
    final p = placemarks.first;
    final parts = [p.street, p.locality, p.administrativeArea, p.postalCode, p.country]
        .where((s) => s != null && s.isNotEmpty)
        .toList();
    return parts.join(', ');
  }
}