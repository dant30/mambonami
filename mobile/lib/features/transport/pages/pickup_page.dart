import 'package:flutter/material.dart';
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
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
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
                  onPressed: _isSubmitting ? null : _submitPickup,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm Pickup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitPickup() {
    setState(() => _isSubmitting = true);
    context.read<TripBloc>().add(
          MarkPickupEvent(
            tripUuid: widget.tripUuid,
            photoPath: _selectedPhotoPath,
          ),
        );
  }
}
