
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/utils/upload_file_utils.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';

/// Gider formu — makbuz seçimi (galeri). Başlık + sağda [+] fotoğraf simgesi.
class ExpenseReceiptSection extends StatelessWidget {
  final PlatformFile? pickedFile;
  final String? existingReceiptUrl;
  final bool enabled;
  final ValueChanged<PlatformFile?> onChanged;
  final VoidCallback? onPickFailed;

  const ExpenseReceiptSection({
    super.key,
    required this.pickedFile,
    this.existingReceiptUrl,
    required this.enabled,
    required this.onChanged,
    this.onPickFailed,
  });

  Future<void> _pick(BuildContext context) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: UploadFileUtils.allowedExtensions.toList(),
      );
      if (result != null && result.files.isNotEmpty) {
        onChanged(result.files.single);
      }
    } catch (_) {
      onPickFailed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.expenses;
    final hasLocal = pickedFile != null && !kIsWeb;
    final hasRemote =
        existingReceiptUrl != null && existingReceiptUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                t.receiptTitle,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Semantics(
              button: true,
              label: hasLocal ? t.receiptChange : t.receiptAdd,
              child: IconButton(
                onPressed: enabled ? () => _pick(context) : null,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                color: AppColors.primary,
                iconSize: AppSizes.iconSize,
                tooltip: hasLocal ? t.receiptChange : t.receiptAdd,
                constraints: const BoxConstraints(
                  minWidth: AppSizes.minTouchTarget,
                  minHeight: AppSizes.minTouchTarget,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingXS),
        Text(
          t.receiptHint,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        if (hasLocal) ...[
          const SizedBox(height: AppSizes.spacingM),
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.spacingL),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, color: AppColors.primary, size: 32),
                    const SizedBox(width: AppSizes.spacingM),
                    Expanded(
                      child: Text(
                        pickedFile!.name,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.spacingXS),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: enabled ? () => onChanged(null) : null,
                    icon: const Icon(Icons.close, size: 22),
                    color: AppColors.error,
                    tooltip: t.receiptRemove,
                    constraints: const BoxConstraints(
                      minWidth: AppSizes.minTouchTarget,
                      minHeight: AppSizes.minTouchTarget,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else if (hasRemote) ...[
          const SizedBox(height: AppSizes.spacingS),
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.primary,
                size: AppSizes.iconSizeSmall,
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: Text(
                  existingReceiptUrl!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
