// mobile/lib/shared/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
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
  final FocusNode? focusNode;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    this.controller,
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
    this.focusNode,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLabel = label ?? labelText;
    
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
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
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: effectiveLabel,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        alignLabelWithHint: maxLines != 1,
        isDense: true,
        errorMaxLines: 3,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled
            ? theme.inputDecorationTheme.fillColor ??
                theme.colorScheme.surface
            : theme.colorScheme.surface.withValues(alpha: 0.6),
      ),
    );
  }
}