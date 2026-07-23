// lib/features/profile/widgets/farmer_profile_content.dart
import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/custom_card.dart';

class FarmerProfileContent extends StatelessWidget {
  final Map<String, dynamic>? farmProfile;
  final bool isEditing;
  final TextEditingController? farmGpsController;
  final TextEditingController? cooperativeController;
  final TextEditingController? mpesaController;
  final TextEditingController? bankAccountController;

  const FarmerProfileContent({
    super.key,
    this.farmProfile,
    required this.isEditing,
    this.farmGpsController,
    this.cooperativeController,
    this.mpesaController,
    this.bankAccountController,
  });

  @override
  Widget build(BuildContext context) {
    // If not editing, show a read-only summary of the farmer profile.
    if (!isEditing) {
      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Farm Details',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.dark),
              ),
              const SizedBox(height: 8),
              _readOnlyRow('Farm GPS', farmProfile?['farm_gps'] ?? 'Not set'),
              _readOnlyRow('Cooperative', farmProfile?['cooperative'] ?? 'Not set'),
              _readOnlyRow('M-Pesa Number', farmProfile?['mpesa_number'] ?? 'Not set'),
              _readOnlyRow('Bank Account', farmProfile?['bank_account'] ?? 'Not set'),
            ],
          ),
        ),
      );
    }

    // Editing mode – show form fields.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const SectionHeader(title: 'Farm Information', padding: EdgeInsets.zero),
        const SizedBox(height: 12),
        CustomTextField(
          controller: farmGpsController ?? TextEditingController(),
          label: 'Farm GPS (lat,lng)',
          hint: 'e.g., -1.234,36.789',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: cooperativeController ?? TextEditingController(),
          label: 'Cooperative Name',
          hint: 'e.g., Kiambu Growers Coop',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: mpesaController ?? TextEditingController(),
          label: 'M-Pesa Number',
          hint: '+254 7XX XXX XXX',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: bankAccountController ?? TextEditingController(),
          label: 'Bank Account',
          hint: 'e.g., 1234567890',
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
            width: 100,
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