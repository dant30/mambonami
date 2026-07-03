// mobile/lib/shared/themes/app_shadows.dart
import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x140F1F15),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x332FA84F),
      blurRadius: 30,
      spreadRadius: 0,
      offset: Offset(0, 14),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x1A0F1F15),
      blurRadius: 34,
      spreadRadius: 0,
      offset: Offset(0, 18),
    ),
  ];
}
