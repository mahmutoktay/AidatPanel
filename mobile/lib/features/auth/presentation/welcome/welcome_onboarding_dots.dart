import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

class WelcomeOnboardingDots extends StatelessWidget {
  const WelcomeOnboardingDots({
    super.key,
    required this.count,
    required this.index,
    required this.semanticsLabel,
  });

  final int count;
  final int index;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final active = i == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.accent
                  : AppColors.textSecondary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
            ),
          );
        }),
      ),
    );
  }
}
