import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 22,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x2B136F45),
      blurRadius: 28,
      offset: Offset(0, 14),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 30,
      offset: Offset(0, 16),
    ),
  ];
}
