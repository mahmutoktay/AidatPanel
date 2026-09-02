import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/strings.g.dart';
import '../../shared/widgets/premium_bottom_sheet.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_typography.dart';
import 'upload_file_utils.dart';

/// Galeri (Photo Picker) / kamera / PDF seçimi sonucu.
class PickedUploadFile {
  final String fileName;
  final Uint8List bytes;
  final String? path;

  const PickedUploadFile({
    required this.fileName,
    required this.bytes,
    this.path,
  });

  PlatformFile toPlatformFile() => PlatformFile(
        name: fileName,
        size: bytes.length,
        bytes: bytes,
        path: path,
      );
}

/// Makbuz/dekont için sistem fotoğraf seçicisi veya PDF dosya seçicisi.
///
/// Android'de galeri [ImagePicker] ile Photo Picker açılır; geniş medya izni gerekmez.
/// PDF için [FilePicker] (belge seçici) kullanılır.
Future<PickedUploadFile?> pickReceiptUploadFile(BuildContext context) async {
  final choice = await _showReceiptSourceSheet(context);
  if (choice == null || !context.mounted) return null;

  final picker = ImagePicker();

  switch (choice) {
    case _ReceiptPickSource.gallery:
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4096,
        maxHeight: 4096,
        imageQuality: 90,
      );
      if (picked == null) return null;
      final bytes = await picked.readAsBytes();
      final name = UploadFileUtils.safeFileName(
        picked.path,
        fallback: 'receipt.jpg',
      );
      return PickedUploadFile(
        fileName: name,
        bytes: bytes,
        path: picked.path,
      );

    case _ReceiptPickSource.camera:
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 4096,
        maxHeight: 4096,
        imageQuality: 90,
      );
      if (picked == null) return null;
      final bytes = await picked.readAsBytes();
      final name = UploadFileUtils.safeFileName(
        picked.path,
        fallback: 'receipt.jpg',
      );
      return PickedUploadFile(
        fileName: name,
        bytes: bytes,
        path: picked.path,
      );

    case _ReceiptPickSource.pdf:
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (result == null || result.files.isEmpty) return null;
      final file = result.files.single;
      final bytes = file.path != null
          ? await File(file.path!).readAsBytes()
          : await file.readAsBytes();
      if (bytes.isEmpty) return null;
      return PickedUploadFile(
        fileName: UploadFileUtils.safeFileName(
          file.name.isNotEmpty ? file.name : (file.path ?? 'receipt.pdf'),
          fallback: 'receipt.pdf',
        ),
        bytes: bytes,
        path: file.path,
      );
  }
}

enum _ReceiptPickSource { gallery, camera, pdf }

Future<_ReceiptPickSource?> _showReceiptSourceSheet(BuildContext context) {
  final t = context.t.common.filePick;
  return PremiumBottomSheetScaffold.show<_ReceiptPickSource>(
    context: context,
    builder: (ctx) => PremiumBottomSheetScaffold(
      scrollable: false,
      showCloseButton: true,
      title: t.sourceTitle,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSizes.spacingS),
          _ReceiptSourceTile(
            icon: Icons.photo_library_outlined,
            label: t.gallery,
            onTap: () => Navigator.pop(ctx, _ReceiptPickSource.gallery),
          ),
          const SizedBox(height: AppSizes.spacingS),
          _ReceiptSourceTile(
            icon: Icons.photo_camera_outlined,
            label: t.camera,
            onTap: () => Navigator.pop(ctx, _ReceiptPickSource.camera),
          ),
          const SizedBox(height: AppSizes.spacingS),
          _ReceiptSourceTile(
            icon: Icons.picture_as_pdf_outlined,
            label: t.pdf,
            onTap: () => Navigator.pop(ctx, _ReceiptPickSource.pdf),
          ),
          const SizedBox(height: AppSizes.spacingM),
        ],
      ),
    ),
  );
}

class _ReceiptSourceTile extends StatelessWidget {
  const _ReceiptSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fill,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: AppSizes.spacingM,
            ),
            child: Row(
              children: [
                Icon(icon, size: 28, color: AppColors.brand),
                const SizedBox(width: AppSizes.spacingM),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
