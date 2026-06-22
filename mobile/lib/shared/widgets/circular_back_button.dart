import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';

/// Dairesel geri butonu — görsel 38dp, dokunma alanı min 48dp.
class CircularBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CircularBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.minTouchTarget,
      height: AppSizes.minTouchTarget,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed ?? () => Navigator.of(context).maybePop(),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.iconButtonBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.iconButtonBorder,
                  width: 0.5,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_left_rounded,
                color: AppColors.iconButtonForeground,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
