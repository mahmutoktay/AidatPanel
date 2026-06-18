import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';

/// Auth ekranları form alanı dekorasyonları.
abstract final class AuthFormStyles {
  static InputDecoration whiteField({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    String? prefixText,
    Widget? suffixIcon,
    String? errorText,
    String? helperText,
    String? counterText,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      borderSide: BorderSide.none,
    );
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixText: prefixText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      helperText: helperText,
      counterText: counterText,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingM,
      ),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: AppColors.lineLight, width: 1),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
    );
  }
}
