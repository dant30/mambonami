// lib/features/transport/pages/delivery_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinput/pinput.dart';

import '../../../blocs/trip/trip_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/loading_indicator.dart';

/// Transport provider completes delivery by:
/// 1. Taking a delivery photo with GPS location
/// 2. Entering the buyer's OTP
/// 3. Confirming delivery → releases escrow
class DeliveryPage extends StatefulWidget {
  final String tripUuid;

  const DeliveryPage({super.key, required this.tripUuid});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  // ── Controllers ──────────────────────────────────────────────────────────
  final _otpController = TextEditingController();
  final _picker = ImagePicker();

  // ── State ────────────────────────────────────────────────────────────────
  String _otp = '';
  File? _deliveryPhoto;
  double? _deliveryLat;
  double? _deliveryLng;
  bool _isLoading = false;
  bool _photoCaptured = false;
  int _otpAttempts = 0;
  bool _isOtpExpired = false;

  // ── Constants ────────────────────────────────────────────────────────────
  static const int _maxOtpAttempts = 3;
  static const Duration _otpExpiryDuration = Duration(minutes: 5);

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // ── Photo Capture ───────────────────────────────────────────────────────

  Future<void> _takeDeliveryPhoto() async {
    try {
      final permission = await _requestCameraPermission();
      if (!permission) return;

      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (picked != null) {
        setState(() {
          _deliveryPhoto = File(picked.path);
          _photoCaptured = true;
        });
        // Capture location after photo
        await _captureDeliveryLocation();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed to take photo: $e');
      }
    }
  }

  Future<bool> _requestCameraPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied) {
        if (mounted) {
          CustomSnackbar.showError(
            context,
            'Camera and location permission required for delivery photo.',
          );
        }
        return false;
      }
    }
    return true;
  }

  Future<void> _captureDeliveryLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          CustomSnackbar.showWarning(
            context,
            'Location services disabled. Please enable GPS for delivery confirmation.',
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _deliveryLat = position.latitude;
        _deliveryLng = position.longitude;
      });
    } catch (e) {
      // Non-blocking – allow manual entry fallback
      debugPrint('Location capture failed: $e');
    }
  }

  // ── OTP Generation ──────────────────────────────────────────────────────

  void _generateOtp() {
    if (_deliveryPhoto == null) {
      CustomSnackbar.showError(
        context,
        'Please take a delivery photo first.',
      );
      return;
    }

    if (_deliveryLat == null || _deliveryLng == null) {
      CustomSnackbar.showWarning(
        context,
        'Location not captured. Proceed anyway?',
      );
    }

    setState(() => _isLoading = true);

    context.read<TripBloc>().add(
          GenerateOtpEvent(widget.tripUuid),
        );
  }

  // ── OTP Verification ────────────────────────────────────────────────────

  void _verifyOtp() {
    if (_otp.length < 4) {
      CustomSnackbar.showError(
        context,
        'Please enter the 4-digit OTP from the buyer.',
      );
      return;
    }

    if (_otpAttempts >= _maxOtpAttempts) {
      CustomSnackbar.showError(
        context,
        'Maximum OTP attempts exceeded. Please request a new OTP.',
      );
      return;
    }

    setState(() => _isLoading = true);

    context.read<TripBloc>().add(
          VerifyOtpEvent(widget.tripUuid, _otp),
        );
  }

  // ── UI Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<TripBloc, TripState>(
      listener: (context, state) {
        if (state is OtpGenerated) {
          setState(() {
            _isLoading = false;
            _otpAttempts = 0;
            _isOtpExpired = false;
          });
          CustomSnackbar.showSuccess(
            context,
            'OTP generated: ${state.otp}\nShare this with the buyer.',
          );
        }

        if (state is DeliveryConfirmed) {
          setState(() => _isLoading = false);
          CustomSnackbar.showSuccess(
            context,
            '✅ Delivery confirmed! Escrow released to farmer and you.',
          );
          context.go(RoutePaths.transportProviderDashboard);
        }

        if (state is TripError) {
          setState(() => _isLoading = false);
          CustomSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isProcessing = state is TripLoading || _isLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Confirm Delivery',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ─────────────────────────────────────────────
                  _buildHeader(context),
                  const SizedBox(height: 24),

                  // ── Delivery Photo ─────────────────────────────────────
                  _buildPhotoSection(context),
                  const SizedBox(height: 24),

                  // ── OTP Section ────────────────────────────────────────
                  _buildOtpSection(context, isProcessing),
                  const SizedBox(height: 20),

                  // ── Warning Card ───────────────────────────────────────
                  _buildWarningCard(context),
                  const SizedBox(height: 24),

                  // ── Confirm Button ─────────────────────────────────────
                  _buildConfirmButton(context, isProcessing),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.light,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Confirm Delivery',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.dark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Take a photo and enter the buyer\'s OTP to complete this delivery',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.muted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Photo Section ───────────────────────────────────────────────────────

  Widget _buildPhotoSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Delivery Photo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Required',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _takeDeliveryPhoto,
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: _photoCaptured ? Colors.transparent : AppColors.light,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _photoCaptured
                    ? AppColors.success
                    : AppColors.primary.withValues(alpha: 0.3),
                width: _photoCaptured ? 2 : 1.5,
              ),
              image: _deliveryPhoto != null
                  ? DecorationImage(
                      image: FileImage(_deliveryPhoto!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _photoCaptured
                ? Stack(
                    children: [
                      // Photo displayed via DecorationImage
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Photo Captured',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _deliveryLat != null
                                    ? '${_deliveryLat!.toStringAsFixed(6)}, ${_deliveryLng!.toStringAsFixed(6)}'
                                    : 'Location pending...',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to take a photo',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Delivery proof with location',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (!_photoCaptured)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.muted,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Photo must include the delivered items at the delivery location',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── OTP Section ─────────────────────────────────────────────────────────

  Widget _buildOtpSection(BuildContext context, bool isProcessing) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Buyer OTP',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'From buyer',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // OTP Input
        Center(
          child: Pinput(
            length: 4,
            onChanged: (value) => setState(() => _otp = value),
            defaultPinTheme: PinTheme(
              width: 64,
              height: 64,
              textStyle: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
            ),
            focusedPinTheme: PinTheme(
              width: 64,
              height: 64,
              textStyle: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            submittedPinTheme: PinTheme(
              width: 64,
              height: 64,
              textStyle: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.success,
                  width: 2,
                ),
              ),
            ),
            errorPinTheme: PinTheme(
              width: 64,
              height: 64,
              textStyle: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.error,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.error,
                  width: 2,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
        ),

        if (_otpAttempts > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                'Attempts: $_otpAttempts/$_maxOtpAttempts',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _otpAttempts >= _maxOtpAttempts
                      ? AppColors.error
                      : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Generate OTP button (if no OTP generated yet)
        if (!_photoCaptured)
          Center(
            child: Text(
              'Take a delivery photo first',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ),
      ],
    );
  }

  // ── Warning Card ─────────────────────────────────────────────────────────

  Widget _buildWarningCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.gold,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'OTP expires in 5 minutes. Max 3 attempts. '
                  'Escrow is released to the farmer and you after successful confirmation.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Confirm Button ──────────────────────────────────────────────────────

  Widget _buildConfirmButton(BuildContext context, bool isProcessing) {
    final isReady = _photoCaptured && _otp.length == 4;

    return Column(
      children: [
        if (isProcessing)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LoadingIndicator(
              message: 'Processing delivery confirmation...',
            ),
          ),
        CustomButton(
          label: isProcessing ? 'Confirming...' : '✓ Confirm Delivery',
          isLoading: isProcessing,
          onPressed: isReady && !isProcessing ? _verifyOtp : null,
          color: isReady ? AppColors.primary : AppColors.muted,
        ),
        if (!_photoCaptured)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please complete all required steps above',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          ),
      ],
    );
  }
}