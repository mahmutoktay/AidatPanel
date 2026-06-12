import 'dart:io';
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _getFilename(String url) {
    try {
      final uri = Uri.parse(url);
      final name = uri.pathSegments.last;
      return name.isNotEmpty ? name : url;
    } catch (_) {
      return url;
    }
  }

  Widget _buildFileIcon(IconData icon, Color color) {
    return Container(
      width: 64,
      height: 64,
      color: color.withValues(alpha: 0.08),
      child: Icon(
        icon,
        color: color,
        size: 28,
      ),
    );
  }

  Widget _buildDropzone(BuildContext context) {
    final t = context.t.features.expenses;
    return InkWell(
      onTap: enabled ? () => _pick(context) : null,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.spacingM,
          horizontal: AppSizes.spacingM,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSizes.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.receiptAdd,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.receiptHint,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalFileItem(BuildContext context, PlatformFile file) {
    final ext = file.extension?.toLowerCase() ?? '';
    final isImage = ['jpg', 'jpeg', 'png'].contains(ext);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Row(
          children: [
            // Preview thumbnail
            if (isImage && file.path != null && !kIsWeb)
              Image.file(
                File(file.path!),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFileIcon(Icons.image_outlined, AppColors.textSecondary),
              )
            else if (ext == 'pdf')
              _buildFileIcon(Icons.picture_as_pdf_outlined, Colors.red[700]!)
            else
              _buildFileIcon(Icons.description_outlined, AppColors.primary),
            
            const SizedBox(width: AppSizes.spacingM),
            
            // File Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      file.name,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatFileSize(file.size),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Delete button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? () => _removeFile(file) : null,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(AppSizes.cardRadius),
                ),
                child: Container(
                  width: AppSizes.minTouchTarget,
                  height: 64,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteFileItem(BuildContext context) {
    final filename = _getFilename(existingReceiptUrl!);
    final ext = filename.split('.').last.toLowerCase();
    final isPdf = ext == 'pdf';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Row(
          children: [
            _buildFileIcon(
              isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
              isPdf ? Colors.red[700]! : AppColors.primary,
            ),
            const SizedBox(width: AppSizes.spacingM),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filename,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Sunucuda Kayıtlı Makbuz",
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Change button
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.spacingS),
              child: TextButton.icon(
                onPressed: enabled ? () => _pick(context) : null,
                icon: const Icon(Icons.sync, size: 16),
                label: Text(context.t.features.expenses.receiptChange),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(60, 40),
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingS),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.expenses;
    final hasLocal = pickedFiles.isNotEmpty && !kIsWeb;
    final hasRemote = existingReceiptUrl != null && existingReceiptUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.receiptTitle,
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        if (!hasLocal && !hasRemote)
          _buildDropzone(context)
        else ...[
          if (hasLocal) ...[
            ...pickedFiles.map((file) => _buildLocalFileItem(context, file)),
            const SizedBox(height: AppSizes.spacingXS),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: enabled ? () => _pick(context) : null,
                icon: const Icon(Icons.add, size: 20),
                label: Text(t.receiptAdd),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingS,
                    vertical: AppSizes.spacingXS,
                  ),
                ),
              ),
            ),
          ] else if (hasRemote)
            _buildRemoteFileItem(context),
        ],
      ],
    );
  }
}
