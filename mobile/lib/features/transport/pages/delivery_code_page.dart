import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../config/route_paths.dart';
import '../../../data/repositories/trip_repository.dart';
import '../../../shared/themes/app_colors.dart';

class DeliveryPage extends StatefulWidget {
  final String tripUuid;

  const DeliveryPage({super.key, required this.tripUuid});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  bool _sending = false;
  String? _message;
  String? _error;

  Future<void> _sendCode() async {
    setState(() { _sending = true; _error = null; _message = null; });
    try {
      final result = await GetIt.instance<TripRepository>().generateOtp(widget.tripUuid);
      if (!mounted) return;
      setState(() => _message = result.message.isNotEmpty ? result.message : 'Delivery code sent to the buyer.');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Buyer confirmation'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.sms_outlined, size: 46, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text('Send delivery code', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.dark)),
                  const SizedBox(height: 8),
                  Text('A six-digit code will be sent to the buyer’s registered phone. The buyer enters it and uploads delivery proof from their order tracking screen.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
                  if (_message != null) ...[
                    const SizedBox(height: 18),
                    Text(_message!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 18),
                    Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
                  ],
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _sending ? null : _sendCode,
                    icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded),
                    label: Text(_sending ? 'Sending…' : _message == null ? 'Send code to buyer' : 'Resend code'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(onPressed: () => context.go(RoutePaths.transportProviderDashboard), child: const Text('Back to trips')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}