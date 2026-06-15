import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static const String _logoAsset = 'assets/brand/app_logo.png';

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
          ? _buildHorizontal(
              appTitle: t.appTitle,
              appSubtitle: t.appSubtitle,
            )
          : _buildVertical(
              appTitle: t.appTitle,
              appSubtitle: t.appSubtitle,
            ),
    );
  }

  Widget _buildVertical({
    required String appTitle,
    required String appSubtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          _logoAsset,
          width: 88,
          height: 88,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppSizes.spacingM),
        Text(
          appTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.archivoBlack(
            fontSize: 30,
            height: 1.05,
            letterSpacing: 1.4,
            color: AppColors.textPrimary,
          ),
        ),
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

  Widget _buildHorizontal({
    required String appTitle,
    required String appSubtitle,
  }) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            _logoAsset,
            width: 64,
            height: 64,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: AppSizes.spacingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appTitle,
                style: GoogleFonts.archivoBlack(
                  fontSize: 26,
                  height: 1.05,
                  letterSpacing: 1.2,
                  color: AppColors.textPrimary,
                ),
              ),
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
