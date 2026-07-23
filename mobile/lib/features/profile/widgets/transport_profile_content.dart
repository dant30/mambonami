// lib/features/profile/widgets/transport_profile_content.dart
import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/section_header.dart';

class TransportProfileContent extends StatelessWidget {
  final Map<String, dynamic>? transportProfile;
  final bool isEditing;
  final TextEditingController? vehicleTypeController;
  final TextEditingController? licensePlateController;
  final TextEditingController? driverLicenseController;
  final TextEditingController? bankAccountController;

  const TransportProfileContent({
    super.key,
    this.transportProfile,
    required this.isEditing,
    this.vehicleTypeController,
    this.licensePlateController,
    this.driverLicenseController,
    this.bankAccountController,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEditing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transport Profile',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.dark),
            ),
            const SizedBox(height: 8),
            _readOnlyRow('Vehicle Type', transportProfile?['vehicle_type'] ?? 'Not set'),
            _readOnlyRow('License Plate', transportProfile?['license_plate'] ?? 'Not set'),
            _readOnlyRow('Driver License', transportProfile?['driver_license'] ?? 'Not set'),
            _readOnlyRow('Bank Account', transportProfile?['bank_account'] ?? 'Not set'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const SectionHeader(title: 'Transport Provider Info', padding: EdgeInsets.zero),
        const SizedBox(height: 12),
        CustomTextField(
          controller: vehicleTypeController ?? TextEditingController(),
          label: 'Vehicle Type',
          hint: 'e.g. motorcycle, pickup',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: licensePlateController ?? TextEditingController(),
          label: 'License Plate',
          hint: 'e.g. KAA 123A',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: driverLicenseController ?? TextEditingController(),
          label: 'Driver License',
          hint: 'Driver license number',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: bankAccountController ?? TextEditingController(),
          label: 'Bank Account',
          hint: 'e.g. 1234567890',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _readOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: AppColors.dark),
            ),
          ),
        ],
      ),
    );
  }
}
