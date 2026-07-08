// lib/features/auth/pages/transport_register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class TransportRegisterPage extends StatefulWidget {
  const TransportRegisterPage({super.key});

  @override
  State<TransportRegisterPage> createState() => _TransportRegisterPageState();
}

class _TransportRegisterPageState extends State<TransportRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _idController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  String _selectedVehicle = 'Motorcycle';

  final List<Map<String, dynamic>> _vehicles = [
    {'label': 'Motorcycle', 'emoji': '🏍️'},
    {'label': 'Pickup', 'emoji': '🛻'},
    {'label': 'Van', 'emoji': '🚐'},
    {'label': 'Lorry', 'emoji': '🚛'},
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _idController.dispose();
    _licensePlateController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is RegisterOtpPending) {
          ctx.go(RoutePaths.otp, extra: {
            'phone': state.phone,
            'mode': 'register',
            'dto': state.dto,
          });
        } else if (state is RegisterSuccess) {
          ctx.go(RoutePaths.success, extra: 'transport');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Transport Provider Registration'),
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
                _buildProgressIndicator(4, 'Vehicle Details'),
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
                        child: Image.asset('assets/icons/transport_icon.png', width: 48, height: 48),
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
                  hint: 'David Ochieng',
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
                Text('Vehicle Type', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.3,
                  children: _vehicles.map((v) {
                    final isSelected = _selectedVehicle == v['label'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedVehicle = v['label']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.lightGreen : Colors.white,
                          borderRadius: AppRadius.xl,
                          border: Border.all(
                            color: isSelected ? AppColors.primaryGreen : AppColors.primaryGreen.withOpacity(0.15),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(v['emoji'], style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 6),
                            Text(
                              v['label']!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.primaryGreen : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _licensePlateController,
                  label: 'License Plate',
                  hint: 'KAA 000A',
                  validator: (v) => v == null || v.isEmpty ? 'Enter license plate' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _licenseNumberController,
                  label: 'Driver License Number',
                  hint: 'A000000Z',
                  validator: (v) => v == null || v.isEmpty ? 'Enter driver license' : null,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: AppRadius.xl,
                    border: Border.all(color: AppColors.goldAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.goldAccent),
                          const SizedBox(width: 8),
                          const Text('Refundable Deposit: KES 500', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pay via M-Pesa PayBill 123456, Account: DEP-TRANSPORT-{your_id}. '
                        'Fully refunded via B2C when you leave in good standing.',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: launch M-Pesa deeplink
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldAccent,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                        ),
                        child: const Text('Pay Deposit via M-Pesa', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
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
                                'role': 'transport',
                                'full_name': _fullNameController.text.trim(),
                                'id_number': _idController.text.trim(),
                                'vehicle_type': _selectedVehicle,
                                'license_plate': _licensePlateController.text.trim(),
                                'driver_license': _licenseNumberController.text.trim(),
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