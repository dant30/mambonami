// mobile/lib/features/transport/widgets/map_preview.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/models/trip.dart';
import '../../../shared/themes/app_colors.dart';

class LiveMapPreview extends StatelessWidget {
  final Trip trip;

  const LiveMapPreview({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final hasPickup = trip.pickupLat != null && trip.pickupLng != null;
    final hasDelivery = trip.deliveryLat != null && trip.deliveryLng != null;

    if (!hasPickup || !hasDelivery) {
      return const SizedBox.shrink();
    }

    final pickup = LatLng(trip.pickupLat!, trip.pickupLng!);
    final delivery = LatLng(trip.deliveryLat!, trip.deliveryLng!);
    final midpoint = LatLng(
      (pickup.latitude + delivery.latitude) / 2,
      (pickup.longitude + delivery.longitude) / 2,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Route Preview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: midpoint,
                  zoom: 11,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: pickup,
                    infoWindow: const InfoWindow(title: 'Pickup'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId('delivery'),
                    position: delivery,
                    infoWindow: const InfoWindow(title: 'Delivery'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}