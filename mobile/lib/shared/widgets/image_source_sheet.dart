import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/strings.g.dart';
import 'premium_bottom_sheet.dart';

/// Kamera / Galeri seçim sheet'i. İptalde `null` döner.
Future<ImageSource?> showImageSourceSheet(BuildContext context) {
  final t = context.t.features.profile;
  return PremiumBottomSheetScaffold.show<ImageSource>(
    context: context,
    builder: (ctx) => PremiumBottomSheetScaffold(
      scrollable: false,
      showCloseButton: true,
      title: t.avatarChooseSource,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSizes.spacingS),
          _ImageSourceTile(
            icon: Icons.photo_camera_outlined,
            label: t.avatarCamera,
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          const SizedBox(height: AppSizes.spacingS),
          _ImageSourceTile(
            icon: Icons.photo_library_outlined,
            label: t.avatarGallery,
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          const SizedBox(height: AppSizes.spacingM),
        ],
      ),
    ),
  );
}

class _ImageSourceTile extends StatelessWidget {
  const _ImageSourceTile({
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
