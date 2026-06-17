import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextCapitalization textCapitalization;
  final String? helperText;
  final EdgeInsetsGeometry? contentPadding;
  final TextAlignVertical? textAlignVertical;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.validator,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.onChanged,
    this.onFieldSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.helperText,
    this.contentPadding,
    this.textAlignVertical,
  }) : assert(label != null || labelText != null, 'Provide label or labelText');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      textAlignVertical: textAlignVertical,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      autofocus: autofocus,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label ?? labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        contentPadding: contentPadding,
        alignLabelWithHint: maxLines != 1,
        isDense: true,
        errorMaxLines: 3,
        prefixIcon: prefixIcon == null
            ? null
            : IconTheme(
                data: IconThemeData(
                  color: theme.colorScheme.primary,
                  size: 21,
                ),
                child: prefixIcon!,
              ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor ??
            theme.colorScheme.surface.withValues(alpha: 0.9),
      ),
    );
  }
}
