import 'package:flutter/material.dart';

<<<<<<< HEAD
/// Marka logosu — koyu temada da uygulama simgesi gibi beyaz, hafif kavisli zemin.
class BrandedAppLogo extends StatelessWidget {
  static const String assetPath = 'assets/brand/app_logo.png';

  final double size;
  final double padding;
  final double? borderRadius;

  const BrandedAppLogo({
    super.key,
    required this.size,
    this.padding = 8,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? size * 0.22;
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
<<<<<<< HEAD
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
=======
        borderRadius: BorderRadius.circular(size * _cornerRadiusFraction),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
<<<<<<< HEAD
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
      ),
=======
      child: image,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    );
  }
}
