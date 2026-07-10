import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_confirm_actions.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/buildings_store.dart';
import '../../domain/entities/saved_iban_item.dart';

class DeleteSavedIbanDialog extends ConsumerStatefulWidget {
  final List<SavedIbanItem> items;

  const DeleteSavedIbanDialog({super.key, required this.items});

  static Future<bool?> show(
    BuildContext context, {
    required List<SavedIbanItem> items,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteSavedIbanDialog(items: items),
    );
  }

  @override
  ConsumerState<DeleteSavedIbanDialog> createState() =>
      _DeleteSavedIbanDialogState();
}

class _DeleteSavedIbanDialogState extends ConsumerState<DeleteSavedIbanDialog> {
  bool _deleting = false;

  int get _linkedBuildingCount =>
      widget.items.fold<int>(0, (sum, i) => sum + i.buildings.length);

  Future<void> _delete() async {
    setState(() => _deleting = true);
    final t = context.t.features.buildings.collection;
    try {
      final keys = widget.items.map((i) => i.ibanKey).toList();
      final bulk = keys.length > 1;
      if (bulk) {
        final result = await ref
            .read(buildingRepositoryProvider)
            .deleteCollectionPresets(matchIbans: keys);
        if (!mounted) return;
        Navigator.of(context).pop(true);
        ref.read(toastProvider.notifier).show(
              t.savedIbansDeleteBulkSuccess.replaceAll(
                '{count}',
                '${result.presetsRemoved}',
              ),
              type: ToastType.success,
            );
      } else {
        await ref
            .read(buildingRepositoryProvider)
            .deleteCollectionPreset(matchIban: keys.first);
        if (!mounted) return;
        Navigator.of(context).pop(true);
        ref.read(toastProvider.notifier).show(
              t.savedIbansDeleteSuccess,
              type: ToastType.success,
            );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ref.read(toastProvider.notifier).show(
            userFacingError(e),
            type: ToastType.error,
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ref.read(toastProvider.notifier).show(
            context.t.common.unexpectedError,
            type: ToastType.error,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.buildings.collection;
    final bulk = widget.items.length > 1;
    final screenH = MediaQuery.sizeOf(context).height;
    final listMaxHeight = (screenH * 0.32).clamp(120.0, 280.0);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      title: Text(
        bulk ? t.savedIbansDeleteBulkTitle : t.savedIbansDeleteTitle,
        style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bulk
                  ? t.savedIbansDeleteBulkMessage.replaceAll(
                      '{count}',
                      '${widget.items.length}',
                    )
                  : t.savedIbansDeleteMessage,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (_linkedBuildingCount > 0) ...[
              const SizedBox(height: AppSizes.spacingS),
              Text(
                t.savedIbansDeleteBuildingWarning.replaceAll(
                  '{count}',
                  '$_linkedBuildingCount',
                ),
                style: AppTypography.body2.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppSizes.spacingM),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: listMaxHeight),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.items.length,
                separatorBuilder: (context, _) =>
                    const SizedBox(height: AppSizes.spacingS),
                itemBuilder: (_, i) {
                  final item = widget.items[i];
                  return Text(
                    IbanUtils.formatDisplay(item.preset.collectionIban),
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
