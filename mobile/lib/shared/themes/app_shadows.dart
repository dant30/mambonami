import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x3360AD5E),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];
}
