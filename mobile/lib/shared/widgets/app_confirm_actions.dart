import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/profile/presentation/theme/profile_settings_ui.dart';

/// Ortak onay aksiyonları — İptal sol, Onay sağ (yan yana).
class AppConfirmActions extends StatelessWidget {
  const AppConfirmActions({
    super.key,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.confirmLoading = false,
    this.dangerConfirm = false,
    this.dense = false,
  });

  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool confirmLoading;
  final bool dangerConfirm;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final height = AppSizes.buttonHeightSecondary;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: height,
            child: OutlinedButton(
              onPressed: confirmLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.inkDark,
                side: ProfileSettingsUi.cardBorderSide,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ProfileSettingsUi.primaryButtonRadius,
                  ),
                ),
                textStyle: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(cancelLabel),
            ),
          ),
        ),
        SizedBox(width: dense ? AppSizes.spacingXS : AppSizes.spacingS),
        Expanded(
          child: SizedBox(
            height: height,
            child: FilledButton(
              onPressed: confirmLoading ? null : onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor:
                    dangerConfirm ? ProfileSettingsUi.danger : null,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ProfileSettingsUi.primaryButtonRadius,
                  ),
                ),
                textStyle: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: confirmLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(confirmLabel),
            ),
          ),
        ),
      ],
    );
  }
}
