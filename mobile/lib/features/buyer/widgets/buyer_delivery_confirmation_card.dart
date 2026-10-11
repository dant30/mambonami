import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinput/pinput.dart';

import '../../../data/models/trip.dart';
import '../../../data/repositories/trip_repository.dart';
import '../../../shared/themes/app_colors.dart';

class BuyerDeliveryConfirmationCard extends StatefulWidget {
  final String orderUuid;
  final VoidCallback onConfirmed;

  const BuyerDeliveryConfirmationCard({
    super.key,
    required this.orderUuid,
    required this.onConfirmed,
  });

  @override
  State<BuyerDeliveryConfirmationCard> createState() => _BuyerDeliveryConfirmationCardState();
}

class _BuyerDeliveryConfirmationCardState extends State<BuyerDeliveryConfirmationCard> {
  final _repository = TripRepository();
  final _picker = ImagePicker();
  Trip? _trip;
  File? _photo;
  String _otp = '';
  String? _error;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    setState(() { _loading = true; _error = null; });
    try {
      final trip = await _repository.getBuyerTripForOrder(widget.orderUuid);
      if (!mounted) return;
      setState(() { _trip = trip; _loading = false; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _error = error.toString(); _loading = false; });
    }
  }

  Future<void> _choosePhoto() async {
    final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80, maxWidth: 1400, maxHeight: 1400);
    if (image != null && mounted) setState(() => _photo = File(image.path));
  }

  Future<void> _confirm() async {
    final trip = _trip;
    if (trip == null || !RegExp(r'^\d{6}$').hasMatch(_otp) || _photo == null) {
      setState(() => _error = 'Enter the six-digit SMS code and add a delivery photo.');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      await _repository.verifyBuyerDeliveryOtp(tripUuid: trip.uuid, otp: _otp, deliveryPhotoPath: _photo!.path);
      if (!mounted) return;
      widget.onConfirmed();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Card(child: Padding(padding: EdgeInsets.all(18), child: LinearProgressIndicator()));
    if (_error != null && _trip == null) return Card(child: ListTile(title: const Text('Delivery details unavailable'), subtitle: Text(_error!), trailing: IconButton(onPressed: _loadTrip, icon: const Icon(Icons.refresh))));
    final trip = _trip;
    if (trip == null) return const SizedBox.shrink();
    if (trip.status == 'delivered') return const Card(child: ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('Delivery confirmed')));
    if (trip.status != 'otp_pending') return Card(child: ListTile(leading: const Icon(Icons.sms_outlined), title: const Text('Waiting for delivery code'), subtitle: Text('The transporter will send a code to your registered phone after arriving. Trip: ${trip.status.replaceAll('_', ' ')}')));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Confirm delivery', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Enter the six-digit code sent to your phone and take a photo of the delivered items.'),
          const SizedBox(height: 16),
          Center(child: Pinput(length: 6, keyboardType: TextInputType.number, onChanged: (value) => setState(() => _otp = value))),
          const SizedBox(height: 14),
          OutlinedButton.icon(onPressed: _submitting ? null : _choosePhoto, icon: const Icon(Icons.camera_alt_outlined), label: Text(_photo == null ? 'Take delivery photo' : 'Retake delivery photo')),
          if (_photo != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_photo!.path.split(Platform.pathSeparator).last, maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: AppColors.error))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: _submitting ? null : _confirm, child: Text(_submitting ? 'Confirming…' : 'Confirm receipt')),
        ]),
      ),
    );
  }
}