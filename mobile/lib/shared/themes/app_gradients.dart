import 'package:flutter/material.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F5D3B), Color(0xFF1E8B57), Color(0xFFE5A11A)],
  );

  static const LinearGradient warm = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEAF8EF), Color(0xFFDDF2E5), Color(0xFFF3FAF1)],
  );

  static const LinearGradient cool = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF133E6F), Color(0xFF246BFD)],
  );

  static const LinearGradient field = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F5D3B), Color(0xFF138A4A)],
  );

  static const LinearGradient logistics = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7A3F08), Color(0xFFE5A11A)],
  );
}
