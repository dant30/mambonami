// lib/features/auth/pages/farmer_register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/progress_indicator.dart';

class FarmerRegisterPage extends StatefulWidget {
  const FarmerRegisterPage({super.key});

  @override
  State<FarmerRegisterPage> createState() => _FarmerRegisterPageState();
}

class _FarmerRegisterPageState extends State<FarmerRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _coopController = TextEditingController();
  final _gpsController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _coopController.dispose();
    _gpsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is RegisterSuccess) {
          ctx.go(RoutePaths.success, extra: 'farmer');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Farmer Registration'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.go(RoutePaths.roleSelect),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressIndicator(4, 'Farm Details'),
                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: AppRadius.xl,
                        ),
                        child: Image.asset('assets/icons/farmer_icon.png', width: 48, height: 48),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: AppRadius.lg,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'John Kamau',
                  validator: (v) => v == null || v.isEmpty ? 'Enter full name' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _idController,
                  label: 'National ID Number',
                  hint: '12345678',
                  prefixIcon: const Icon(Icons.file_present_outlined, color: AppColors.textMuted, size: 18),
                  validator: (v) => v == null || v.isEmpty ? 'Enter ID number' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'M-Pesa Number',
                  hint: '+254 7XX XXX XXX',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.textMuted, size: 18),
                  validator: (v) => v == null || v.isEmpty ? 'Enter M-Pesa number' : null,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: AppRadius.lg,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Farm GPS Location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                            Text('Tap to pick on map', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          // TODO: Open map picker
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                        ),
                        child: const Text('Pick', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _coopController,
                  label: 'Cooperative Name (optional)',
                  hint: 'e.g. Kiambu Growers Coop',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: AppRadius.lg,
                    border: Border.all(color: AppColors.goldAccent.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.goldAccent, size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cooperative endorsement increases buyer trust and gives you priority listings. Unaffiliated farmers may continue without it.',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (ctx, state) {
                    return CustomButton(
                      label: 'Create Account',
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ctx.read<AuthBloc>().add(
                            RegisterRequested(
                              dto: {
                                'role': 'farmer',
                                'full_name': _fullNameController.text.trim(),
                                'id_number': _idController.text.trim(),
                                'mpesa_number': _phoneController.text.trim(),
                                'cooperative': _coopController.text.trim(),
                                'farm_gps': _gpsController.text.trim(),
                              },
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int step, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Step $step of 4', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: step / 4,
          minHeight: 6,
          backgroundColor: AppColors.lightGreen,
          color: AppColors.primaryGreen,
          borderRadius: AppRadius.full,
        ),
      ],
    );
  }
}