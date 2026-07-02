import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../widgets/auth_page_header.dart';
import '../widgets/auth_surface.dart';

class OtpPage extends StatefulWidget {
  final String phone;

  const OtpPage({super.key, required this.phone});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_formKey.currentState!.validate()) {
      context.go(RoutePaths.roleSelect, extra: {'phone': widget.phone});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Verify OTP'),
      body: AppScreen(
        useGradientBackground: true,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthPageHeader(
                title: 'One-time code',
                subtitle:
                    'Enter the 4-digit code sent to ${widget.phone.isNotEmpty ? widget.phone : "your phone"}.',
              ),
              AuthSurface(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _otpController,
                      label: 'OTP code',
                      hintText: '1234',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: (value) =>
                          value == null || value.trim().length != 4
                              ? 'Enter a valid 4-digit code'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      onPressed: _continue,
                      label: 'Continue',
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
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
