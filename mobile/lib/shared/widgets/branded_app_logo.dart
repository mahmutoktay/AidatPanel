import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// AidatPanel marka logosu — koyu temada beyaz yuvarlatılmış zemin.
class BrandedAppLogo extends StatelessWidget {
  const BrandedAppLogo({
    super.key,
    required this.size,
    this.padding = 5,
  });

  final double size;
  final double padding;

  static const String logoAsset = 'assets/brand/app_logo.png';
  static const double _cornerRadiusFraction = 0.22;

  @override
  Widget build(BuildContext context) {
    final innerSize = size - padding * 2;
    final image = Image.asset(
      logoAsset,
      width: innerSize,
      height: innerSize,
      fit: BoxFit.contain,
    );

    if (!AppColors.isDark) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(child: image),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * _cornerRadiusFraction),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: image,
    );
  }
}
