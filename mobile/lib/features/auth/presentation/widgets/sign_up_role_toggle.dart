import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';

/// Üye ol ekranında sakin / yönetici anlık geçişi.
class SignUpRoleToggle extends StatelessWidget {
  const SignUpRoleToggle({
    super.key,
    required this.isManager,
    required this.residentLabel,
    required this.managerLabel,
    required this.onResidentTap,
    required this.onManagerTap,
    this.enabled = true,
  });

  final bool isManager;
  final String residentLabel;
  final String managerLabel;
  final VoidCallback onResidentTap;
  final VoidCallback onManagerTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleTab(
            label: residentLabel,
            selected: !isManager,
            onTap: enabled ? onResidentTap : null,
            alignment: Alignment.center,
          ),
        ),
        Container(
          width: 1,
          height: AppSizes.minTouchTarget * 0.6,
          color: AppColors.border,
        ),
        Expanded(
          child: _RoleTab(
            label: managerLabel,
            selected: isManager,
            onTap: enabled ? onManagerTap : null,
            alignment: Alignment.center,
          ),
        ),
      ],
    );
  }
}

class _RoleTab extends StatelessWidget {
  const _RoleTab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.alignment,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
            child: Align(
              alignment: alignment,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingS,
                  vertical: AppSizes.spacingS,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTypography.body1.copyWith(
                        color: color,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingXS),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      height: 3,
                      width: selected ? 40 : 0,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
