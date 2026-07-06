// mobile/lib/shared/themes/app_radius.dart
import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const Radius sm = Radius.circular(8);
  static const Radius md = Radius.circular(12);
  static const Radius lg = Radius.circular(16);
  static const Radius xl = Radius.circular(20);
  static const Radius xxl = Radius.circular(24);

  static const BorderRadius small = BorderRadius.all(sm);
  static const BorderRadius medium = BorderRadius.all(md);
  static const BorderRadius large = BorderRadius.all(lg);
  static const BorderRadius extraLarge = BorderRadius.all(xl);
  static const BorderRadius extraExtraLarge = BorderRadius.all(xxl);

  static const BorderRadius mdRadius = medium;
  static const BorderRadius lgRadius = large;
  static const BorderRadius xxlRadius = extraExtraLarge;
}
