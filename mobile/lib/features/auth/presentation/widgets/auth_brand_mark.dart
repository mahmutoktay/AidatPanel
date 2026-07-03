import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/branded_app_logo.dart';
import '../../../../shared/widgets/branded_app_title.dart';

/// Marka alanı boyutu — görsel ölçüler [AuthBrandHeader] vertical ile aynıdır.
enum AuthBrandMarkSize {
  /// Rol seçimi — alt başlık gösterilir.
  hero,

  /// Diğer adımlar — logo + başlık (alt başlık yok).
  standard,
}

/// Logo üstte, AidatPanel yazısı altta — [AuthBrandHeader] vertical ile birebir.
class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({
    super.key,
    this.size = AuthBrandMarkSize.standard,
    this.showSubtitle = false,
    this.subtitle,
  });

  final AuthBrandMarkSize size;
  final bool showSubtitle;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandedAppLogo(size: 88, padding: 5),
        const SizedBox(height: AppSizes.spacingM),
        const BrandedAppTitle(fontSize: 30),
        if (showSubtitle && subtitle != null) ...[
          const SizedBox(height: AppSizes.spacingXS),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
