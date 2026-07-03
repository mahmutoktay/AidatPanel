import 'package:flutter/material.dart';

<<<<<<< HEAD
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
=======
import 'app_back_button.dart';
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

/// Eski kullanım adı; görsel uygulama [AppBackButton] üzerinden tekilleştirildi.
class CircularBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CircularBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
    return AppBackButton(onPressed: onPressed);
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  }
}
