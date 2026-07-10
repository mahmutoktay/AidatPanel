import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_confirm_actions.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/apartments_store.dart';
import '../../domain/entities/apartment_entity.dart';

/// Daire silme onay dialog'u. Bina silmenin aksine tip-to-confirm yok;
/// daire silmek nispeten daha sık bir işlem ve daha az hasar vericidir.
/// FK varsa (sakin/aidat var) backend 400 döner ve mesajı insanlaştırırız.
class DeleteApartmentDialog extends ConsumerStatefulWidget {
  final ApartmentEntity apartment;

  const DeleteApartmentDialog({super.key, required this.apartment});

  static Future<bool?> show(
    BuildContext context, {
    required ApartmentEntity apartment,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteApartmentDialog(apartment: apartment),
    );
  }

  @override
  ConsumerState<DeleteApartmentDialog> createState() =>
      _DeleteApartmentDialogState();
}

class _DeleteApartmentDialogState extends ConsumerState<DeleteApartmentDialog> {
  bool _deleting = false;

  Future<void> _delete() async {
    setState(() => _deleting = true);
    try {
      await ref
          .read(apartmentsStoreProvider(widget.apartment.buildingId).notifier)
          .removeApartment(widget.apartment.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ref.read(toastProvider.notifier).show(
            context.t.common.apartmentDeleted,
            type: ToastType.success,
          );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ref.read(toastProvider.notifier).show(
            userFacingError(e),
            type: ToastType.error,
            duration: const Duration(seconds: 6),
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ref.read(toastProvider.notifier).show(
            context.t.common.apartmentDeleteFailed,
            type: ToastType.error,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.spacingS),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Text(
              context.t.common.deleteApartment,
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
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
            context.t.common.deleteApartmentConfirm,
            style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: AppSizes.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              border: AppColors.cardBorder,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.door_front_door_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSizes.spacingS),
                Expanded(
                  child: Text(
                    widget.apartment.apartmentNumber,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSizes.spacingL,
        0,
        AppSizes.spacingL,
        AppSizes.spacingM,
      ),
      actions: [
        SizedBox(
          width: double.maxFinite,
          child: AppConfirmActions(
            cancelLabel: context.t.common.cancelBtn,
            confirmLabel: context.t.common.delete,
            onCancel: _deleting ? null : () => Navigator.of(context).pop(false),
            onConfirm: _deleting ? null : _delete,
            confirmLoading: _deleting,
            dangerConfirm: true,
          ),
        ),
      ],
    );
  }
}
