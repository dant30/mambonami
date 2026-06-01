import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          if (state is OtpGenerated) {
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
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhotoCaptureWidget(
                title: 'Delivery Photo',
                description: 'Take a photo confirming delivery',
                onPhotoSelected: (file) {},
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OTP Verification',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (_otpCode == null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isGeneratingOtp ? null : _generateOtp,
                            child: _isGeneratingOtp
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Generate OTP'),
                          ),
                        )
                      else ...[
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
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                    child: CircularProgressIndicator(strokeWidth: 2),
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
    setState(() => _isGeneratingOtp = true);
    context.read<TripBloc>().add(GenerateOtpEvent(widget.tripUuid));
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
