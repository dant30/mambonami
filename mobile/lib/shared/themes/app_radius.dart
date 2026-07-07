// mobile/lib/shared/themes/app_radius.dart
import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(20));
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(24));
  static const BorderRadius full = BorderRadius.all(Radius.circular(999));

  static const BorderRadius small = sm;
  static const BorderRadius medium = md;
  static const BorderRadius large = lg;
  static const BorderRadius extraLarge = xl;
  static const BorderRadius extraExtraLarge = xxl;

  static const BorderRadius mdRadius = md;
  static const BorderRadius lgRadius = lg;
  static const BorderRadius xxlRadius = xxl;
}
