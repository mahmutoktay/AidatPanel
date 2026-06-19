import 'package:flutter/material.dart';

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

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
      ),
    );
  }
}
