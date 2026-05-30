import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryLight, AppColors.secondaryLight],
  );

  static const LinearGradient warm = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF7ED), Color(0xFFFFF1E0)],
  );
}
