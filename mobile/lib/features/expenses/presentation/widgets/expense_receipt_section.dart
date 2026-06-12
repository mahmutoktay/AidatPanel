import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/utils/upload_file_utils.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';

/// Gider formu — çoklu makbuz seçimi.
class ExpenseReceiptSection extends StatelessWidget {
  final List<PlatformFile> pickedFiles;
  final String? existingReceiptUrl;
  final bool enabled;
  final ValueChanged<List<PlatformFile>> onChanged;
  final VoidCallback? onPickFailed;

  const ExpenseReceiptSection({
    super.key,
    required this.pickedFiles,
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
        final newFiles = List<PlatformFile>.from(pickedFiles);
        for (var file in result.files) {
          if (file.path == null) continue;
          if (!newFiles.any((f) => f.name == file.name && f.size == file.size)) {
            newFiles.add(file);
          }
        }
        onChanged(newFiles);
      }
    } catch (_) {
      onPickFailed?.call();
    }
  }

  void _removeFile(PlatformFile file) {
    final newFiles = List<PlatformFile>.from(pickedFiles);
    newFiles.remove(file);
    onChanged(newFiles);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.expenses;
    final hasLocal = pickedFiles.isNotEmpty && !kIsWeb;
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
              label: t.receiptAdd,
              child: IconButton(
                onPressed: enabled ? () => _pick(context) : null,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                color: AppColors.primary,
                iconSize: AppSizes.iconSize,
                tooltip: t.receiptAdd,
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
          ...pickedFiles.map((file) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
            child: Stack(
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
                          file.name,
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
                      onPressed: enabled ? () => _removeFile(file) : null,
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
          )),
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
