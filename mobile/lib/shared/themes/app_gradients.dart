import 'package:flutter/material.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B7F3B), Color(0xFF2FA84F), Color(0xFFD4AF37)],
  );

  static const LinearGradient warm = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF4D6), Color(0xFFD4AF37)],
  );

  static const LinearGradient cool = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B7F3B), Color(0xFF4EC36F)],
  );

  static const LinearGradient field = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2FA84F), Color(0xFF5FD283)],
  );

  static const LinearGradient logistics = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFF0F1F15)],
  );
}
