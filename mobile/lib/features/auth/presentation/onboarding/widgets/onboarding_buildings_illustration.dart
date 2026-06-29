import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';

/// Adım 1 alt dekor — basit bina silüeti (referans illüstrasyon).
class OnboardingBuildingsIllustration extends StatelessWidget {
  const OnboardingBuildingsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.spacingXL),
      child: SizedBox(
        height: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Building(width: 48, height: 72, color: const Color(0xFF90CAF9)),
            const SizedBox(width: 8),
            _Building(width: 56, height: 96, color: const Color(0xFF42A5F5)),
            const SizedBox(width: 8),
            _Building(width: 44, height: 64, color: const Color(0xFF64B5F6)),
            const SizedBox(width: 8),
            _Building(width: 52, height: 88, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _Building extends StatelessWidget {
  const _Building({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(3, (row) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, left: 6, right: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (_) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
