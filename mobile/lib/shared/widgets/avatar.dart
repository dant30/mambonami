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
  });

  String _getInitials() {
    List<String> names = [];
    if (firstName != null && firstName!.isNotEmpty) names.add(firstName![0].toUpperCase());
    if (secondName != null && secondName!.isNotEmpty) names.add(secondName![0].toUpperCase());
    if (lastName != null && lastName!.isNotEmpty) names.add(lastName![0].toUpperCase());
    if (names.isEmpty && username != null && username!.isNotEmpty) {
      names.add(username![0].toUpperCase());
    }
    return names.join();
  }

  Color _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;
    
    // Generate color from initials
    final initials = _getInitials();
    if (initials.isEmpty) return Colors.grey;
    
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[initials.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final decorationImage = imageFile != null
        ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover)
        : imageUrl != null && imageUrl!.isNotEmpty
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        shape: BoxShape.circle,
        image: decorationImage,
      ),
      child: decorationImage == null
          ? Center(
              child: Text(
                _getInitials(),
                style: textStyle ??
                    Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
              ),
            )
          : null,
    );
  }
}
