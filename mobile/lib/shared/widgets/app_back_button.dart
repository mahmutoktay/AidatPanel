import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';

/// Uygulama genelinde kullanılan tek geri butonu.
///
/// Renkler aktif temadan gelir; açık temada beyaz yüzey/koyu ikon,
/// koyu temada koyu yüzey/açık ikon kullanır.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool enabled;
  final String? tooltip;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.enabled = true,
    this.tooltip,
  });

  static const double visualSize = 38;
  static const double iconSize = 18;
  static const Duration _animationDuration = Duration(milliseconds: 160);

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = enabled
        ? (onPressed ?? () => Navigator.of(context).maybePop())
        : null;
    final tooltipMessage =
        tooltip ?? MaterialLocalizations.of(context).backButtonTooltip;

    final backgroundColor = enabled
        ? AppColors.surface
        : AppColors.surface.withValues(alpha: 0.56);
    final iconColor = enabled ? AppColors.textPrimary : AppColors.textDisabled;
    final borderColor = AppColors.lineLight;

    return Tooltip(
      message: tooltipMessage,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltipMessage,
        child: SizedBox(
          width: AppSizes.minTouchTarget,
          height: AppSizes.minTouchTarget,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: effectiveOnTap,
              child: Center(
                child: AnimatedContainer(
                  duration: _animationDuration,
                  curve: Curves.easeInOut,
                  width: visualSize,
                  height: visualSize,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: iconColor,
                    size: iconSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
