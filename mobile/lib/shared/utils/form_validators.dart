// mobile/lib/shared/utils/form_validators.dart
import 'package:flutter/material.dart';

class FormValidators {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    final pattern = RegExp(r'^(?:254|0)?(7\d{8})$');
    if (!pattern.hasMatch(cleaned)) {
      return 'Enter a valid Kenyan phone (e.g., 0712345678)';
    }
    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP code is required';
    }
    if (value.length != 4 || !RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must be 4 digits';
    }
    return null;
  }

  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    final pattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!pattern.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value, {String fieldName = 'Amount'}) {
    if (value == null || value.isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return '$fieldName must be a positive number';
    }
    return null;
  }

  static String? validateGPS(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(',');
    if (parts.length != 2) {
      return 'Format: latitude,longitude (e.g., -1.2921,36.8219)';
    }
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) {
      return 'Invalid coordinates';
    }
    if (lat < -90 || lat > 90) {
      return 'Latitude must be between -90 and 90';
    }
    if (lng < -180 || lng > 180) {
      return 'Longitude must be between -180 and 180';
    }
    return null;
  }
}