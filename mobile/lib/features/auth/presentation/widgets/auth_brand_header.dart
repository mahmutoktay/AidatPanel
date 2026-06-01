import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';

/// Giriş / kayıt / katılım — marka alanı (logo + başlık + alt başlık).
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  static const String _logoAsset = 'assets/brand/app_logo.png';

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.auth;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPadding,
        AppSizes.spacingL,
        AppSizes.screenPadding,
        AppSizes.spacingM,
      ),
      child: Column(
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
            t.appTitle,
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
            t.appSubtitle,
            textAlign: TextAlign.center,
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

