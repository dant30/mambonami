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
  final FocusNode _searchFocusNode = FocusNode();

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

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text('Select Location'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: _selectedLocation, zoom: 15),
              onCameraMove: _onCameraMove,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
            ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(Icons.location_pin, size: 40, color: Colors.red[700]),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 64,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.96),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search address or place...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                      onSubmitted: _searchAddress,
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.send_rounded, size: 20),
                      onPressed: () => _searchAddress(_searchController.text),
                      tooltip: 'Search',
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selected location',
                            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Ready',
                            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAddress.isEmpty ? 'Tap the map to adjust the pinpoint.' : _selectedAddress,
                      style: textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _goToCurrentLocation,
                            icon: const Icon(Icons.my_location_rounded, size: 18),
                            label: const Text('Use current location'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomButton(
                            onPressed: _confirmLocation,
                            label: 'Confirm',
                            icon: const Icon(Icons.check, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
