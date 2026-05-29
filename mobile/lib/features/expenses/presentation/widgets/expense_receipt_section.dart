import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';

/// Gider formu — makbuz seçimi (galeri). Başlık + sağda [+] fotoğraf simgesi.
class ExpenseReceiptSection extends StatelessWidget {
  final XFile? pickedFile;
  final String? existingReceiptUrl;
  final bool enabled;
  final ValueChanged<XFile?> onChanged;
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
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (file != null) onChanged(file);
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
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                child: Image.file(
                  File(pickedFile!.path),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.spacingS),
                child: Material(
                  color: AppColors.surface.withValues(alpha: 0.92),
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
