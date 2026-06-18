// mobile/lib/shared/widgets/avatar.dart
import 'dart:io';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final String? firstName;
  final String? secondName;
  final String? lastName;
  final String? username;
  final double size;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final bool showBorder;

  const Avatar({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.firstName,
    this.secondName,
    this.lastName,
    this.username,
    this.size = 56,
    this.backgroundColor,
    this.textStyle,
    this.showBorder = true,
  });

  String _getInitials() {
    final names = <String>[];
    if (firstName != null && firstName!.isNotEmpty) names.add(firstName![0].toUpperCase());
    if (secondName != null && secondName!.isNotEmpty) names.add(secondName![0].toUpperCase());
    if (lastName != null && lastName!.isNotEmpty) names.add(lastName![0].toUpperCase());
    if (names.isEmpty && username != null && username!.isNotEmpty) {
      names.add(username![0].toUpperCase());
    }
    return names.take(2).join();
  }

  Color _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;
    
    final initials = _getInitials();
    if (initials.isEmpty) {
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    }

    // Pre-defined palette with good contrast
    final colors = [
      const Color(0xFFE53935),
      const Color(0xFFD81B60),
      const Color(0xFF8E24AA),
      const Color(0xFF5E35B1),
      const Color(0xFF3949AB),
      const Color(0xFF1E88E5),
      const Color(0xFF00897B),
      const Color(0xFF43A047),
      const Color(0xFFFDD835),
      const Color(0xFFFB8C00),
      const Color(0xFFF4511E),
      const Color(0xFF6D4C41),
    ];
    return colors[initials.hashCode % colors.length];
  }

  Color _getTextColor(Color bgColor) {
    final brightness = ThemeData.estimateBrightnessForColor(bgColor);
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = _getBackgroundColor(context);
    final textColor = _getTextColor(bgColor);

    final decorationImage = imageFile != null
        ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover)
        : imageUrl != null && imageUrl!.isNotEmpty
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null;

    final initials = _getInitials();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        image: decorationImage,
        border: showBorder
            ? Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
                width: 1.5,
              )
            : null,
      ),
      child: decorationImage == null
          ? Center(
              child: Text(
                initials.isEmpty ? '?' : initials,
                style: textStyle ??
                    theme.textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: size * 0.45,
                    ),
              ),
            )
          : null,
    );
  }
}