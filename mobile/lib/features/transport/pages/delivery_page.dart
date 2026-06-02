// mobile/lib/features/transport/pages/delivery_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../blocs/trip/trip_bloc.dart';
import '../widgets/photo_capture_widget.dart';

class DeliveryPage extends StatefulWidget {
  final String tripUuid;

  const DeliveryPage({super.key, required this.tripUuid});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  String? _otpCode;
  bool _isGeneratingOtp = false;
  bool _isVerifyingOtp = false;
  late TextEditingController _otpController;
  String? _selectedPhotoPath;
  double? _deliveryLat;
  double? _deliveryLng;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Complete Delivery'),
      body: BlocListener<TripBloc, TripState>(
        listener: (context, state) {
          if (state is DeliveryMarked) {
            // Delivery location/photo saved — now generate OTP
            context.read<TripBloc>().add(GenerateOtpEvent(widget.tripUuid));
          } else if (state is OtpGenerated) {
            setState(() => _otpCode = state.otp);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('OTP generated: ${state.otp}')),
            );
            setState(() => _isGeneratingOtp = false);
          } else if (state is DeliveryConfirmed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Delivery confirmed!')),
            );
            Navigator.of(context).pop();
          } else if (state is TripError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
            setState(() {
              _isGeneratingOtp = false;
              _isVerifyingOtp = false;
            });
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhotoCaptureWidget(
                title: 'Delivery Photo',
                description: 'Take a photo confirming delivery',
                onPhotoSelected: (file) {
                  setState(() => _selectedPhotoPath = file?.path);
                },
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OTP Verification',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (_otpCode == null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _selectedPhotoPath == null || _isGeneratingOtp
                                    ? null
                                    : _generateOtp,
                            child: _isGeneratingOtp
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Generate OTP'),
                          ),
                        ),
                        if (_selectedPhotoPath == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Delivery photo is required before generating the OTP.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.redAccent),
                            ),
                          ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OTP Generated',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Text(
                                _otpCode!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter OTP',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isVerifyingOtp ? null : _verifyOtp,
                            child: _isVerifyingOtp
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Verify OTP'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateOtp() {
    if (_selectedPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please add a delivery photo before generating OTP.')),
      );
      return;
    }

    setState(() => _isGeneratingOtp = true);
    _captureLocationAndMarkDelivery();
  }

  Future<void> _captureLocationAndMarkDelivery() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')));
        setState(() => _isGeneratingOtp = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')));
        setState(() => _isGeneratingOtp = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _deliveryLat = pos.latitude;
        _deliveryLng = pos.longitude;
      });

      context.read<TripBloc>().add(MarkDeliveryEvent(
            tripUuid: widget.tripUuid,
            latitude: _deliveryLat,
            longitude: _deliveryLng,
            photoPath: _selectedPhotoPath,
          ));
    } catch (e) {
      setState(() => _isGeneratingOtp = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing location: $e')));
    }
  }

  void _verifyOtp() {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
      return;
    }
    setState(() => _isVerifyingOtp = true);
    context.read<TripBloc>().add(
          VerifyOtpEvent(widget.tripUuid, _otpController.text),
        );
  }
}
