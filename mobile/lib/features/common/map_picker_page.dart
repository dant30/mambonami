// mobile/lib/features/common/map_picker_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/geocoding_repository.dart';
import '../../shared/widgets/custom_button.dart';

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
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(-1.2921, 36.8219); // Nairobi default
  String _selectedAddress = '';
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      if (widget.initialLocation != null) {
        _selectedLocation = widget.initialLocation!;
        _selectedAddress = widget.initialAddress ??
            await widget.geocodingRepository.reverseGeocode(_selectedLocation);
      } else {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          await Geolocator.requestPermission();
        }

        final pos = await Geolocator.getCurrentPosition();
        _selectedLocation = LatLng(pos.latitude, pos.longitude);
        _selectedAddress =
            await widget.geocodingRepository.reverseGeocode(_selectedLocation);
      }
    } catch (_) {
      _selectedAddress = widget.initialAddress ?? 'Location unavailable';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    if (mounted) {
      setState(() {});
    }
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

  Future<void> _confirmLocation() async {
    Navigator.pop(context, {
      'lat': _selectedLocation.latitude,
      'lng': _selectedLocation.longitude,
      'address': _selectedAddress,
    });
  }

  Future<void> _searchAddress(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    setState(() => _isSearching = true);
    try {
      final latLng = await widget.geocodingRepository.geocodeAddress(trimmedQuery);
      if (!mounted) return;
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
      setState(() => _selectedLocation = latLng);
      final address = await widget.geocodingRepository.reverseGeocode(latLng);
      if (!mounted) return;
      setState(() => _selectedAddress = address);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address not found. Try another place name.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        final status = await Geolocator.requestPermission();
        if (status == LocationPermission.denied ||
            status == LocationPermission.deniedForever) {
          throw Exception('Location permission denied');
        }
      }

      final pos = await Geolocator.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
      setState(() => _selectedLocation = latLng);
      final address = await widget.geocodingRepository.reverseGeocode(latLng);
      if (!mounted) return;
      setState(() => _selectedAddress = address);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to access your current location.')),
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
              initialCameraPosition:
                  CameraPosition(target: _selectedLocation, zoom: 15),
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search address or place...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send_rounded),
                              onPressed: () => _searchAddress(_searchController.text),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: _searchAddress,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _goToCurrentLocation,
                          icon: const Icon(Icons.my_location_rounded),
                          label: const Text('Use current location'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButton(
                          onPressed: _confirmLocation,
                          label: 'Confirm',
                          icon: const Icon(Icons.check),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedAddress,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
