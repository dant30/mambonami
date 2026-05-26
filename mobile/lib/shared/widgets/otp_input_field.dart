import 'package:flutter/material.dart';

class OtpInputField extends StatelessWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final TextEditingController? controller;

  const OtpInputField({
    super.key,
    this.length = 4,
    required this.onCompleted,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (index) => _buildPinBox(context, index),
      ),
    );
  }

  Widget _buildPinBox(BuildContext context, int index) {
    return Container(
      width: 50,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          if (value.isNotEmpty && index < length - 1) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          counterText: '',
        ),
      ),
    );
  }
}