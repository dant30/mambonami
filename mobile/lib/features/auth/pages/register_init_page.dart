// Phone + role
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';

class RegisterInitPage extends StatefulWidget {
  const RegisterInitPage({super.key});

  @override
  State<RegisterInitPage> createState() => _RegisterInitPageState();
}

class _RegisterInitPageState extends State<RegisterInitPage> {
  final _phoneController = TextEditingController();
  String _selectedRole = 'buyer';
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> _roles = [
    {'value': 'buyer', 'label': 'Buyer (Consumer)'},
    {'value': 'retailer', 'label': 'Retailer'},
    {'value': 'farmer', 'label': 'Farmer'},
    {'value': 'transport_provider', 'label': 'Transport Provider'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOTP() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(RegisterInitEvent(_phoneController.text.trim(), _selectedRole));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegisterInitSuccess) {
            Navigator.pushNamed(context, '/register/verify', arguments: {
              'phone': _phoneController.text.trim(),
              'role': _selectedRole,
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.length < 10 ? 'Enter valid phone' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'I am a...'),
                  items: _roles.map((role) {
                    return DropdownMenuItem(value: role['value'], child: Text(role['label']!));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  onPressed: _sendOTP,
                  child: const Text('Send OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}