import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/user_entity.dart';

/// Adım 1 — büyük rol kartları (referans görsel).
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
          icon: Icons.person_outline,
          selected: selectedRole == UserRole.manager,
          onTap: enabled ? onManagerTap : null,
        ),
        const SizedBox(height: AppSizes.spacingM),
        _RoleCard(
          label: residentLabel,
          icon: Icons.person_outline,
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
    final fg = selected ? Colors.white : AppColors.textPrimary;
    final iconColor = selected ? Colors.white : AppColors.textSecondary;
    final bg = selected ? AppColors.primary : AppColors.surface;
    final borderColor = selected ? AppColors.primary : AppColors.border;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        elevation: selected ? 2 : 0,
        shadowColor: AppColors.primary.withValues(alpha: 0.25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTargetComfort + 8,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingL,
              vertical: AppSizes.spacingM,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border.all(color: borderColor, width: selected ? 0 : 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: AppSizes.iconSizeLarge, color: iconColor),
                const SizedBox(width: AppSizes.spacingM),
                Text(
                  label,
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: fg,
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
