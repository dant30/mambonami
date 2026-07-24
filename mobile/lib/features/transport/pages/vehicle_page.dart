import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../widgets/vehicle_card.dart';

class TransportVehiclePage extends StatelessWidget {
  const TransportVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    String vehicleType = 'Vehicle';
    String? licensePlate;
    double rating = 4.9;
    int completedDeliveries = 0;

    if (authState is AuthAuthenticated) {
      vehicleType = authState.vehicleType ?? 'Vehicle';
      licensePlate = authState.licensePlate;
      rating = authState.providerRating ?? 4.9;
      completedDeliveries = authState.completedDeliveries ?? 0;
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Vehicle',
        fallbackRoute: RoutePaths.transportProviderDashboard,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VehicleCard(
                vehicleType: vehicleType,
                licensePlate: licensePlate,
                rating: rating,
                completedDeliveries: completedDeliveries,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.light),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(label: 'Type', value: vehicleType),
                    _DetailRow(label: 'Plate', value: licensePlate ?? 'Not set'),
                    _DetailRow(label: 'Rating', value: rating.toStringAsFixed(1)),
                    _DetailRow(label: 'Completed deliveries', value: '$completedDeliveries'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}
