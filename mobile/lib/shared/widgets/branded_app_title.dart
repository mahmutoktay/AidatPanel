import 'package:flutter/material.dart';

import '../../core/theme/app_brand_colors.dart';
import '../../core/theme/app_typography.dart';

/// "Aidat" + "Panel" — logo renkleri, SemiBold.
class BrandedAppTitle extends StatelessWidget {
  final double fontSize;
  final TextAlign textAlign;

  const BrandedAppTitle({
    super.key,
    this.fontSize = 32,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.12,
      letterSpacing: 0.3,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Aidat',
            style: base.copyWith(color: AppBrandColors.aidatOrange),
          ),
          TextSpan(
            text: 'Panel',
            style: base.copyWith(color: AppBrandColors.panelColor(context)),
          ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
