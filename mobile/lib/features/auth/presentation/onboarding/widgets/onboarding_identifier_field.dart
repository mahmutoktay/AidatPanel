import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';

/// Tek alan — e-posta veya 0 ile başlayan 11 haneli telefon.
class OnboardingIdentifierField extends StatelessWidget {
  const OnboardingIdentifierField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.phoneNote,
    this.enabled = true,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String phoneNote;
  final bool enabled;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmitted?.call(),
          autofillHints: const [
            AutofillHints.username,
            AutofillHints.email,
            AutofillHints.telephoneNumber,
          ],
          style: AppTypography.body1,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            prefixIcon: const Icon(Icons.alternate_email_outlined),
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.spacingXS),
            Expanded(
              child: Text(
                phoneNote,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Telefon girişi için yalnızca rakam ve en fazla 11 hane (0 ile başlar).
class OnboardingPhoneDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 11) {
      return oldValue;
    }
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
