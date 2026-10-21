import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';

import '../data/repositories/address_repository.dart';
import 'location_service.dart';

class BuyerCoordinates {
  final double latitude;
  final double longitude;

  const BuyerCoordinates({required this.latitude, required this.longitude});
}

class BuyerLocationService {
  BuyerLocationService._();

  static Future<BuyerCoordinates?> resolve({bool requestPermission = false}) async {
    try {
      final locator = GetIt.instance;
      if (locator.isRegistered<AddressRepository>()) {
        final addressRepository = locator<AddressRepository>();
        await addressRepository.init();
        final address = addressRepository.defaultAddress;
        if (address?.latitude != null && address?.longitude != null) {
          return BuyerCoordinates(
            latitude: address!.latitude!,
            longitude: address.longitude!,
          );
        }
      }

      var permission = await LocationService.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await LocationService.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await LocationService.getCurrentPosition(
        accuracy: LocationAccuracy.low,
        timeout: const Duration(seconds: 6),
      );
      if (position == null) return null;
      return BuyerCoordinates(latitude: position.latitude, longitude: position.longitude);
    } catch (_) {
      return null;
    }
  }
}
