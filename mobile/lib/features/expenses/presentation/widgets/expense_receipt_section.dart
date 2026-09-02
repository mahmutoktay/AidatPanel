import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/utils/receipt_file_picker.dart';
import '../../../../core/utils/upload_file_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';

/// Gider formu — çoklu makbuz seçimi.
class ExpenseReceiptSection extends StatelessWidget {
  final List<PlatformFile> pickedFiles;
  final String? existingReceiptUrl;
  final bool enabled;
  final ValueChanged<List<PlatformFile>> onChanged;
  final VoidCallback? onPickFailed;
  final String? caption;
  final String? amountLabel;

  const ExpenseReceiptSection({
    super.key,
    required this.pickedFiles,
    this.existingReceiptUrl,
    required this.enabled,
    required this.onChanged,
    this.onPickFailed,
    this.caption,
    this.amountLabel,
  });

  Future<void> _pick(BuildContext context) async {
    try {
      final picked = await pickReceiptUploadFile(context);
      if (picked == null) return;
      final validationError = UploadFileUtils.validateReceiptBytes(
        picked.bytes,
        picked.fileName,
      );
      if (validationError != null) {
        onPickFailed?.call();
        return;
      }
      final platformFile = picked.toPlatformFile();
      final newFiles = List<PlatformFile>.from(pickedFiles);
      if (!newFiles.any(
        (f) => f.name == platformFile.name && f.size == platformFile.size,
      )) {
        newFiles.add(platformFile);
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
      borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.spacingM,
          horizontal: AppSizes.spacingM,
        ),
        decoration: BoxDecoration(
          color: AppColors.brand.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
          border: Border.all(
            color: AppColors.brand.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.attach_file,
                color: AppColors.brand,
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
                      color: AppColors.brand,
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
      decoration: DashboardScreenStyle.whiteCard(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        child: Row(
          children: [
            if (isImage && file.path != null && !kIsWeb)
              Image.file(
                File(file.path!),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFileIcon(
                  Icons.image_outlined,
                  AppColors.textSecondary,
                ),
              )
            else if (ext == 'pdf')
              _buildFileIcon(Icons.picture_as_pdf_outlined, Colors.red[700]!)
            else
              _buildFileIcon(Icons.description_outlined, AppColors.brand),
            const SizedBox(width: AppSizes.spacingM),
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
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? () => _removeFile(file) : null,
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
      decoration: DashboardScreenStyle.whiteCard(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        child: Row(
          children: [
            _buildFileIcon(
              isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
              isPdf ? Colors.red[700]! : AppColors.brand,
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
                      context.t.features.expenses.receiptStoredOnServer,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.spacingS),
              child: TextButton.icon(
                onPressed: enabled ? () => _pick(context) : null,
                icon: const Icon(Icons.sync, size: 16),
                label: Text(context.t.features.expenses.receiptChange),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brand,
                  minimumSize: const Size(60, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingS,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get _contentItemCount {
    final hasLocal = pickedFiles.isNotEmpty && !kIsWeb;
    final hasRemote =
        existingReceiptUrl != null && existingReceiptUrl!.isNotEmpty;

    if (!hasLocal && !hasRemote) return 1; // dropzone
    if (hasLocal) return pickedFiles.length + 1; // files + add button
    return 1; // remote file
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
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                t.receiptTitle,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            if (amountLabel != null)
              Text(
                amountLabel!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        if (caption != null && caption!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            caption!,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: AppSizes.spacingS),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _contentItemCount,
          itemBuilder: (context, index) {
            if (!hasLocal && !hasRemote) {
              return _buildDropzone(context);
            }

            if (hasLocal) {
              if (index < pickedFiles.length) {
                return _buildLocalFileItem(context, pickedFiles[index]);
              }
              return Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: enabled ? () => _pick(context) : null,
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(t.receiptAdd),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.brand,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingS,
                      vertical: AppSizes.spacingXS,
                    ),
                  ),
                ),
              );
            }

            return _buildRemoteFileItem(context);
          },
        ),
      ],
    );
  }
}
