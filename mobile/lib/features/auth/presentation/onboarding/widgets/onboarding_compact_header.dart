import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../l10n/strings.g.dart';

/// Adım 2+ üst logo şeridi — referans görseldeki kompakt marka alanı.
class OnboardingCompactHeader extends StatelessWidget {
  const OnboardingCompactHeader({super.key});

  static const String _logoAsset = 'assets/brand/app_logo.png';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(_logoAsset, width: 36, height: 36, fit: BoxFit.contain),
          const SizedBox(width: AppSizes.spacingS),
          Text(
            context.t.features.auth.appTitle,
            style: GoogleFonts.archivoBlack(
              fontSize: 20,
              letterSpacing: 0.8,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
