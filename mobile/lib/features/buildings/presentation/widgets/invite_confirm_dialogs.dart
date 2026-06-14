import 'package:flutter/material.dart';

import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../utils/apartment_ui_utils.dart';
import '../../../../l10n/strings.g.dart';

/// Dolu daireye yine de yeni kod üretilmek istendiğinde gösterilen onay dialogu.
class OccupiedApartmentConfirmDialog extends StatelessWidget {
  final ApartmentEntity apartment;
  final VoidCallback onConfirm;

  const OccupiedApartmentConfirmDialog({
    super.key,
    required this.apartment,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final apartmentLabel = ApartmentUiUtils.formatApartmentLabel(
      context,
      apartment.apartmentNumber,
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
      ),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.t.features.buildings.apartmentOccupied,
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$apartmentLabel dairesinde "${apartment.residentName}" kayıtlı.',
            style: AppTypography.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text.rich(
            TextSpan(
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.35,
              ),
              children: [
                TextSpan(text: context.t.features.buildings.newCodePrefix),
                TextSpan(
                  text: context.t.features.buildings.oldUserRemoved,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                TextSpan(text: context.t.common.confirmMessage),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSizes.spacingM,
        0,
        AppSizes.spacingM,
        AppSizes.spacingM,
      ),
      actions: [
        _DialogActionRow(
          confirmLabel: context.t.features.buildings.produceAnyway,
          confirmStyle: AppButtonStyles.elevatedPrimary(fullWidth: true),
          onConfirm: () {
            Navigator.pop(context);
            onConfirm();
          },
        ),
      ],
    );
  }
}

/// Aktif kodu iptal etmek için onay dialogu.
class RevokeInviteCodeDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const RevokeInviteCodeDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
      ),
      title: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.t.features.buildings.cancelCode,
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Text.rich(
        TextSpan(
          style: AppTypography.body1.copyWith(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.35,
          ),
          children: [
            TextSpan(text: context.t.features.buildings.currentCodePrefix),
            TextSpan(
              text: context.t.features.buildings.codeInvalid,
              style: AppTypography.body1.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            TextSpan(text: context.t.common.confirmMessage),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSizes.spacingM,
        0,
        AppSizes.spacingM,
        AppSizes.spacingM,
      ),
      actions: [
        _DialogActionRow(
          confirmLabel: context.t.features.buildings.cancelCode,
          confirmStyle: AppButtonStyles.filledDanger(fullWidth: true),
          onConfirm: () {
            Navigator.pop(context);
            onConfirm();
          },
        ),
      ],
    );
  }
}

/// Vazgeç + onay butonlu yatay aksiyon satırı (dialoglarda kullanılır).
class _DialogActionRow extends StatelessWidget {
  final String confirmLabel;
  final ButtonStyle confirmStyle;
  final VoidCallback onConfirm;

  const _DialogActionRow({
    required this.confirmLabel,
    required this.confirmStyle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightSecondary,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: AppButtonStyles.outlinedNeutral(fullWidth: true),
              child: Text(context.t.common.cancelBtn),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightSecondary,
            child: ElevatedButton(
              style: confirmStyle,
              onPressed: onConfirm,
              child: Text(confirmLabel),
            ),
          ),
        ),
      ],
    );
  }
}
