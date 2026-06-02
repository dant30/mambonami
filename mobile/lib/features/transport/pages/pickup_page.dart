// mobile/lib/features/transport/pages/pickup_page.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../blocs/trip/trip_bloc.dart';
import '../widgets/photo_capture_widget.dart';

class PickupPage extends StatefulWidget {
  final String tripUuid;

  const PickupPage({super.key, required this.tripUuid});

  @override
  State<PickupPage> createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  String? _selectedPhotoPath;
  bool _isSubmitting = false;
  double? _latitude;
  double? _longitude;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Mark Pickup'),
      body: BlocListener<TripBloc, TripState>(
        listener: (context, state) {
          if (state is PickupMarked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pickup marked successfully!')),
            );
            Navigator.of(context).pop();
          } else if (state is TripError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
            setState(() => _isSubmitting = false);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhotoCaptureWidget(
                title: 'Pickup Photo',
                description: 'Take a photo of the items being picked up',
                onPhotoSelected: (file) {
                  setState(() => _selectedPhotoPath = file?.path);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedPhotoPath == null || _isSubmitting
                      ? null
                      : _submitPickup,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm Pickup'),
                ),
              ),
              if (_selectedPhotoPath == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Pickup photo is required before confirming pickup.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.redAccent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitPickup() {
    if (_selectedPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please select a pickup photo before confirming pickup.')),
      );
      return;
    }

    () async {
      setState(() => _isSubmitting = true);

      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location services are disabled.')));
          setState(() => _isSubmitting = false);
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location permission denied')));
            setState(() => _isSubmitting = false);
            return;
          }
        }
        if (permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Location permission permanently denied. Please enable it from settings.')));
          setState(() => _isSubmitting = false);
          return;
        }

        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        _latitude = pos.latitude;
        _longitude = pos.longitude;

        context.read<TripBloc>().add(
              MarkPickupEvent(
                tripUuid: widget.tripUuid,
                latitude: _latitude,
                longitude: _longitude,
                photoPath: _selectedPhotoPath,
              ),
            );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to get location: $e')));
        setState(() => _isSubmitting = false);
      }
    }();
  }
}
