import 'package:flutter/material.dart';

import '../../../../shared/widgets/branded_app_logo.dart';
import '../../../../shared/widgets/branded_app_title.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';

enum AuthBrandHeaderLayout {
  /// Logo üstte, başlık altında (giriş ekranı).
  vertical,

  /// Logo solda, başlık sağda (kayıt ekranı).
  horizontal,
}

/// Giriş / kayıt — marka alanı (logo + başlık).
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({
    super.key,
    this.layout = AuthBrandHeaderLayout.vertical,
  });

  final AuthBrandHeaderLayout layout;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.auth;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.screenPadding,
        layout == AuthBrandHeaderLayout.vertical
            ? AppSizes.spacingL
            : AppSizes.spacingM,
        AppSizes.screenPadding,
        layout == AuthBrandHeaderLayout.vertical
            ? AppSizes.spacingM
            : AppSizes.spacingS,
      ),
      child: layout == AuthBrandHeaderLayout.horizontal
          ? _buildHorizontal(appSubtitle: t.appSubtitle)
          : _buildVertical(appSubtitle: t.appSubtitle),
    );
  }

  Widget _buildVertical({required String appSubtitle}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandedAppLogo(size: 88, padding: 5),
        const SizedBox(height: AppSizes.spacingM),
        const BrandedAppTitle(fontSize: 30),
        const SizedBox(height: AppSizes.spacingXS),
        Text(
          appSubtitle,
          textAlign: TextAlign.center,
          style: AppTypography.body1.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontal({required String appSubtitle}) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const BrandedAppLogo(size: 64, padding: 4),
          const SizedBox(width: AppSizes.spacingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandedAppTitle(fontSize: 26, textAlign: TextAlign.start),
              const SizedBox(height: 2),
              Text(
                appSubtitle,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
