import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Input validation utilities for AidatPanel forms
/// Provides comprehensive validation with Turkish error messages
class InputValidators {
  // Regex patterns
  static final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final phoneRegex = RegExp(r'^5[0-9]{9}$');
  static final _phoneStripRegex = RegExp(r'[^0-9]');

  static final nameRegex = RegExp(r'^[a-zA-ZçğıöşüÇĞİÖŞÜ\s]{2,50}$');

  static final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&.])[A-Za-z\d@$!%*?&.]{6,}$',
  );

  static final _pwUpperRegex = RegExp(r'[A-Z]');
  static final _pwLowerRegex = RegExp(r'[a-z]');
  static final _pwDigitRegex = RegExp(r'[0-9]');
  static final _pwSpecialRegex = RegExp(r'[@$!%*?&.]');

  /// Email validation - returns error keys for localization
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'email_required';
    }

    if (!emailRegex.hasMatch(value.trim())) {
      return 'email_invalid';
    }

    if (value.length > 100) {
      return 'email_too_long';
    }

    return null;
  }

  /// Phone number validation (10 digits without country code)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'phone_required';
    }

    final cleanPhone = value.replaceAll(_phoneStripRegex, '');

    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'phone_invalid';
    }

    return null;
  }

  /// Password validation - returns error keys for localization
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'password_required';
    }

    if (value.length < 6) {
      return 'password_too_short';
    }

    if (value.length > 50) {
      return 'password_too_long';
    }

    if (!value.contains(_pwUpperRegex)) {
      return 'password_uppercase_required';
    }

    if (!value.contains(_pwLowerRegex)) {
      return 'password_lowercase_required';
    }

    if (!value.contains(_pwDigitRegex)) {
      return 'password_number_required';
    }

    if (!value.contains(_pwSpecialRegex)) {
      return 'password_special_char_required';
    }

    return null;
  }

  /// Name validation (first and last name)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'name_required';
    }

    if (value.length < 2) {
      return 'name_too_short';
    }

    if (value.length > 50) {
      return 'name_too_long';
    }

    if (!nameRegex.hasMatch(value.trim())) {
      return 'name_invalid';
    }

    return null;
  }

  /// Building name validation
  static String? validateBuildingName(String? value) {
    if (value == null || value.isEmpty) {
      return 'building_name_required';
    }

    if (value.length < 3) {
      return 'building_name_too_short';
    }

    if (value.length > 100) {
      return 'building_name_too_long';
    }

    return null;
  }

  /// Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'address_required';
    }

    if (value.length < 10) {
      return 'address_too_short';
    }

    if (value.length > 200) {
      return 'address_too_long';
    }

    return null;
  }

  /// Apartment number validation
  static String? validateApartmentNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'apartment_number_required';
    }

    if (value.length > 10) {
      return 'apartment_number_too_long';
    }

    return null;
  }

  /// Amount validation (for dues, payments, etc.)
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'amount_required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'amount_invalid';
    }

    if (amount < 0) {
      return 'amount_negative';
    }

    if (amount > 1000000) {
      return 'amount_too_large';
    }

    return null;
  }

  /// Generic field validation with custom rules
  static String? validateField({
    required String? value,
    required String fieldName,
    int? minLength,
    int? maxLength,
    bool required = true,
    String? customRegex,
    String? customMessage,
  }) {
    if (required && (value == null || value.isEmpty)) {
      return '$fieldName boş bırakılamaz';
    }

    if (value != null) {
      if (minLength != null && value.length < minLength) {
        return '$fieldName en az $minLength karakter olmalıdır';
      }

      if (maxLength != null && value.length > maxLength) {
        return '$fieldName çok uzun';
      }

      if (customRegex != null && !RegExp(customRegex).hasMatch(value)) {
        return customMessage ?? 'Geçerli bir $fieldName giriniz';
      }
    }

    return null;
  }

  /// Password strength indicator (0-4 scale)
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 6) strength++;
    if (password.contains(_pwUpperRegex)) strength++;
    if (password.contains(_pwLowerRegex)) strength++;
    if (password.contains(_pwDigitRegex)) strength++;
    if (password.contains(_pwSpecialRegex)) strength++;

    return strength;
  }

  /// Password strength text
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'password_strength_weak';
      case 2:
      case 3:
        return 'password_strength_medium';
      case 4:
      case 5:
        return 'password_strength_strong';
      default:
        return 'password_strength_unknown';
    }
  }

  /// Password strength color
  static Color getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.textDisabled;
      case 2:
      case 3:
        return AppColors.textSecondary;
      case 4:
      case 5:
        return AppColors.textPrimary;
      default:
        return AppColors.textDisabled;
    }
  }
}
