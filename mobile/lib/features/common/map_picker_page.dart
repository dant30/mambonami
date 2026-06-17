// mobile/lib/features/common/map_picker_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/geocoding_repository.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;
  final GeocodingRepository geocodingRepository;

  const MapPickerPage({
    super.key,
    this.initialLocation,
    this.initialAddress,
    required this.geocodingRepository,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late GoogleMapController _mapController;
  LatLng _selectedLocation = const LatLng(-1.2921, 36.8219); // Nairobi default
  String _selectedAddress = '';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation!;
      _selectedAddress = widget.initialAddress ?? await widget.geocodingRepository.reverseGeocode(_selectedLocation);
    } else {
      // Get current GPS
      final pos = await Geolocator.getCurrentPosition();
      _selectedLocation = LatLng(pos.latitude, pos.longitude);
      _selectedAddress = await widget.geocodingRepository.reverseGeocode(_selectedLocation);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    final latLng = position.target;
    if (latLng != _selectedLocation) {
      setState(() => _selectedLocation = latLng);
      widget.geocodingRepository.reverseGeocode(latLng).then((address) {
        setState(() => _selectedAddress = address);
      });
    }
  }

  void _confirmLocation() {
    Navigator.pop(context, {
      'lat': _selectedLocation.latitude,
      'lng': _selectedLocation.longitude,
      'address': _selectedAddress,
    });
  }

  void _searchAddress(String query) async {
    try {
      final latLng = await widget.geocodingRepository.geocodeAddress(query);
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
      setState(() => _selectedLocation = latLng);
      final address = await widget.geocodingRepository.reverseGeocode(latLng);
      setState(() => _selectedAddress = address);
    } catch (_) {
      // Show error if address not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: Stack(
        children: [
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (!_isLoading)
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: _selectedLocation, zoom: 15),
              onCameraMove: _onCameraMove,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
            ),
          Center(
            child: Icon(Icons.location_pin, size: 40, color: Colors.red[700]),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search address...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: _searchAddress,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedAddress,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmLocation,
                      icon: const Icon(Icons.check),
                      label: const Text('Confirm Location'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}