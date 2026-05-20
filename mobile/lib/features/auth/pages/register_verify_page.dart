// OTP + details
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';

class RegisterVerifyPage extends StatefulWidget {
  const RegisterVerifyPage({super.key});

  @override
  State<RegisterVerifyPage> createState() => _RegisterVerifyPageState();
}

class _RegisterVerifyPageState extends State<RegisterVerifyPage> {
  final _otpController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _farmGpsController = TextEditingController();
  final _mpesaController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String _phone;
  late String _role;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _phone = args['phone'];
    _role = args['role'];
  }

  @override
  void dispose() {
    _otpController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _farmGpsController.dispose();
    _mpesaController.dispose();
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  void _verify() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(RegisterVerifyEvent(
            phone: _phone,
            otp: _otpController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            role: _role,
            farmGps: _role == 'farmer' ? _farmGpsController.text : null,
            mpesaNumber: _role == 'farmer' ? _mpesaController.text : null,
            vehicleType: _role == 'transport_provider' ? _vehicleTypeController.text : null,
            licensePlate: _role == 'transport_provider' ? _licensePlateController.text : null,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/${state.role}');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomTextField(
                  controller: _otpController,
                  label: 'OTP Code',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.length != 4 ? 'Enter 4-digit OTP' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _usernameController,
                  label: 'Username',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                ),
                if (_role == 'farmer') ...[
                  const SizedBox(height: 16),
                  CustomTextField(controller: _farmGpsController, label: 'Farm GPS (lat,lng)'),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _mpesaController, label: 'M-Pesa Number'),
                ],
                if (_role == 'transport_provider') ...[
                  const SizedBox(height: 16),
                  CustomTextField(controller: _vehicleTypeController, label: 'Vehicle Type (motorcycle/pickup/lorry/van)'),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _licensePlateController, label: 'License Plate'),
                ],
                const SizedBox(height: 24),
                CustomButton(onPressed: _verify, child: const Text('Verify & Register')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}