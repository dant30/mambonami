// mobile/lib/shared/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? labelText;
  final String? hint;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? obscureTextOverride;
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
    this.hint,
    this.hintText,
    this.obscureText = false,
    this.obscureTextOverride,
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
    final effectiveObscureText = obscureTextOverride ?? obscureText;

    // Build decoration
    final inputDecoration = InputDecoration(
      labelText: effectiveLabel,
      hintText: hint ?? hintText,
      helperText: helperText,
      errorText: errorText,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      alignLabelWithHint: maxLines != 1,
      isDense: true,
      errorMaxLines: 3,
      prefixIcon: prefixIcon != null
          ? IconTheme(
              data: IconThemeData(
                color: errorText != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
              child: prefixIcon!,
            )
          : null,
      suffixIcon: suffixIcon != null
          ? IconTheme(
              data: IconThemeData(
                color: errorText != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
              child: suffixIcon!,
            )
          : null,
      filled: true,
      fillColor: enabled
          ? theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.92 : 1.0,
            )
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
      helperStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: theme.colorScheme.primary),
    );

    // Apply if we want to use theme's inputDecorationTheme? We'll override with explicit.
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: effectiveObscureText,
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
      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
      cursorColor: theme.colorScheme.primary,
      decoration: inputDecoration,
    );
  }
}