import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/user_entity.dart';

/// Adım 1 — büyük rol kartları.
class OnboardingRoleCards extends StatelessWidget {
  const OnboardingRoleCards({
    super.key,
    required this.selectedRole,
    required this.managerLabel,
    required this.residentLabel,
    required this.onManagerTap,
    required this.onResidentTap,
    this.enabled = true,
  });

  final UserRole? selectedRole;
  final String managerLabel;
  final String residentLabel;
  final VoidCallback onManagerTap;
  final VoidCallback onResidentTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RoleCard(
          label: managerLabel,
          icon: Icons.apartment_outlined,
          selected: selectedRole == UserRole.manager,
          onTap: enabled ? onManagerTap : null,
        ),
        const SizedBox(height: AppSizes.spacingM),
        _RoleCard(
          label: residentLabel,
          icon: Icons.home_outlined,
          selected: selectedRole == UserRole.resident,
          onTap: enabled ? onResidentTap : null,
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    final Color bg;
    final Color fg;
    final Color iconColor;
    final Color borderColor;
    final double borderWidth;

    if (selected) {
      bg = AppColors.action;
      fg = AppColors.onAction;
      iconColor = fg;
      borderColor = Colors.transparent;
      borderWidth = 0;
    } else {
      bg = isDark ? AppColors.fill : AppColors.surface;
      fg = AppColors.ink;
      iconColor = AppColors.textSecondary;
      borderColor = AppColors.border;
      borderWidth = 1.5;
    }

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        elevation: selected ? (isDark ? 0 : 2) : 0,
        shadowColor: AppColors.brand.withValues(alpha: 0.2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: AppSizes.buttonHeightPrimary,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingL,
              vertical: AppSizes.spacingM,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: borderWidth > 0
                  ? Border.all(color: borderColor, width: borderWidth)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: AppSizes.iconSizeLarge, color: iconColor),
                const SizedBox(width: AppSizes.spacingM),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.h3.copyWith(
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
