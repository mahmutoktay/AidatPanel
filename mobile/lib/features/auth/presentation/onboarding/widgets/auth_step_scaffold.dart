import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/auth_screen_shell.dart';

class AuthStepScaffold extends StatelessWidget {
  const AuthStepScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryEnabled = true,
    this.isLoading = false,
    this.footer,
    this.secondary,
    this.centerBody = false,
    this.primaryTrailing,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryEnabled;
  final bool isLoading;
  final Widget? footer;
  final Widget? secondary;
  final bool centerBody;
  final Widget? primaryTrailing;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: centerBody
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.stretch,
      children: [
        if (centerBody)
          Text(title, style: AppTypography.h2, textAlign: TextAlign.center)
        else
          Text(title, style: AppTypography.h2),
        if (subtitle != null) ...[
          const SizedBox(height: AppSizes.spacingS),
          Text(
            subtitle!,
            textAlign: centerBody ? TextAlign.center : TextAlign.start,
            style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: AppSizes.spacingL),
        body,
        if (footer != null) ...[
          const SizedBox(height: AppSizes.spacingM),
          footer!,
        ],
        if (secondary != null) ...[
          const SizedBox(height: AppSizes.spacingM),
          secondary!,
        ],
        const SizedBox(height: AppSizes.spacingL),
        AuthScreenShell.primaryBottomBar(
          onPressed: primaryEnabled && !isLoading ? onPrimary : null,
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(primaryLabel),
                    if (primaryTrailing != null) ...[
                      const SizedBox(width: AppSizes.spacingS),
                      primaryTrailing!,
                    ],
                  ],
                ),
        ),
      ],
    );

    return content;
  }
}
