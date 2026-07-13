import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../domain/entities/dekont_entity.dart';

/// Dekont detay — kompakt dosya satırı (ikon, ad, boyut, aksiyonlar).
class DekontDetailFileRow extends StatelessWidget {
  final DekontEntity dekont;
  final int? sizeBytes;
  final bool loadingFile;
  final VoidCallback? onPreview;
  final VoidCallback? onShare;

  const DekontDetailFileRow({
    super.key,
    required this.dekont,
    this.sizeBytes,
    this.loadingFile = false,
    this.onPreview,
    this.onShare,
  });

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dekont;
    final filename = dekont.originalFilename;
    final ext = filename.split('.').last.toLowerCase();
    final isPdf = ext == 'pdf';
    final effectiveSize = sizeBytes ?? dekont.sizeBytes;
    final uploadDate = AppDateFormat.dateTimeMedium(dekont.createdAt);

    final iconColor = isPdf ? AppColors.statusRed : AppColors.brand;
    final iconBg = isPdf ? AppColors.errorBg : AppColors.infoBg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MinimalSectionLabel(title: t.fileSection),
        const SizedBox(height: AppSizes.spacingS),
        Container(
          decoration: BoxDecoration(
            color: AppColors.fill,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingM,
            vertical: AppSizes.spacingS,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(
                    DashboardScreenStyle.iconBoxRadius,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isPdf
                      ? Icons.picture_as_pdf_outlined
                      : Icons.image_outlined,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filename,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (effectiveSize > 0) formatFileSize(effectiveSize),
                        uploadDate,
                      ].join(' · '),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: loadingFile ? null : onPreview,
                icon: loadingFile
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.visibility_outlined),
                color: AppColors.brand,
                tooltip: t.viewDekont,
                constraints: const BoxConstraints(
                  minWidth: AppSizes.minTouchTarget,
                  minHeight: AppSizes.minTouchTarget,
                ),
              ),
              IconButton(
                onPressed: loadingFile ? null : onShare,
                icon: const Icon(Icons.share_outlined),
                color: AppColors.brand,
                tooltip: t.shareFile,
                constraints: const BoxConstraints(
                  minWidth: AppSizes.minTouchTarget,
                  minHeight: AppSizes.minTouchTarget,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
