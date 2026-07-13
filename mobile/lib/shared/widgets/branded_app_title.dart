import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// AidatPanel yazısı — logo renkleri (turuncu + lacivert), SemiBold.
class BrandedAppTitle extends StatelessWidget {
  const BrandedAppTitle({
    super.key,
    required this.fontSize,
    this.textAlign = TextAlign.center,
  });

  final double fontSize;
  final TextAlign textAlign;

  static const _aidat = 'Aidat';
  static const _panel = 'Panel';

  @override
  Widget build(BuildContext context) {
    final panelColor = AppColors.isDark ? AppColors.ink : AppColors.brand;
    final style = GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.1,
      letterSpacing: 0.4,
    );

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        children: [
          TextSpan(
            text: _aidat,
            style: style.copyWith(color: AppColors.accent),
          ),
          TextSpan(
            text: _panel,
            style: style.copyWith(color: panelColor),
          ),
        ],
      ),
    );
  }
}
