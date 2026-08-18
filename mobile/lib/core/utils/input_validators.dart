import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Input validation utilities for AidatPanel forms
/// Provides comprehensive validation with Turkish error messages
/// Backend `passwordSchema` in `shared.js` ile uyumludur.
class InputValidators {
  // Regex patterns
  static final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final phoneRegex = RegExp(r'^5[0-9]{9}$');
  static final _phoneStripRegex = RegExp(r'[^0-9]');

  static final nameRegex = RegExp(r'^[a-zA-ZçğıöşüÇĞİÖŞÜ\s]{2,50}$');

  /// Backend [`passwordSchema`](backend/src/validators/shared.js) ile eşleşir.
  /// En az 6 karakter, en az bir harf ve bir rakam. Özel karakter isteğe bağlı.
  static final _passwordLetterRegex = RegExp(r'[A-Za-zÇĞİÖŞÜçğıöşü]');
  static final _passwordDigitRegex = RegExp(r'[0-9]');

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

    if (value.length > 100) {
      return 'password_too_long';
    }

    if (!_passwordLetterRegex.hasMatch(value)) {
      return 'password_letter_required';
    }

    if (!_passwordDigitRegex.hasMatch(value)) {
      return 'password_number_required';
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
      return 'field_required';
    }

    if (value != null) {
      if (minLength != null && value.length < minLength) {
        return 'field_too_short';
      }

      if (maxLength != null && value.length > maxLength) {
        return 'field_too_long';
      }

      if (customRegex != null && !RegExp(customRegex).hasMatch(value)) {
        return customMessage ?? 'field_invalid';
      }
    }

    return null;
  }

  /// Password strength indicator (0-3 scale)
  static int getPasswordStrength(String password) {
    if (password.length < 6) return 0;
    final hasLetter = _passwordLetterRegex.hasMatch(password);
    final hasDigit = _passwordDigitRegex.hasMatch(password);
    if (!hasLetter || !hasDigit) return 1;
    if (password.length < 8) return 2;
    return 3;
  }

  /// Password strength text
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'password_strength_weak';
      case 2:
        return 'password_strength_medium';
      case 3:
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
        return AppColors.textSecondary;
      case 3:
        return AppColors.textPrimary;
      default:
        return AppColors.textDisabled;
    }
  }

  /// E-posta veya TR cep telefonu — onboarding identifier alanı.
  /// Kabul: `05xxxxxxxxx` (11) veya kanonik `5xxxxxxxxx` (10).
  static String? validateLoginIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'identifier_required';
    }
    final trimmed = value.trim();
    if (trimmed.contains('@')) {
      return validateEmail(trimmed);
    }
    final digits = trimmed.replaceAll(_phoneStripRegex, '');
    if (digits.length == 10 && phoneRegex.hasMatch(digits)) {
      return null;
    }
    if (digits.length == 11 && digits.startsWith('0')) {
      if (!phoneRegex.hasMatch(digits.substring(1))) {
        return 'phone_invalid';
      }
      return null;
    }
    return 'phone_invalid_eleven_digits';
  }
}
