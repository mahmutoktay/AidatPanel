import 'package:flutter/material.dart';

import '../../../../../core/theme/app_sizes.dart';
import '../../../../../l10n/strings.g.dart';
import '../../widgets/auth_brand_mark.dart';

/// Onboarding üst marka alanı — logo üstte, AidatPanel altta.
class OnboardingCompactHeader extends StatelessWidget {
  const OnboardingCompactHeader({
    super.key,
    this.size = AuthBrandMarkSize.standard,
    this.showSubtitle = false,
  });

  final AuthBrandMarkSize size;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.auth;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: AuthBrandMark(
        size: size,
        showSubtitle: showSubtitle,
        subtitle: t.appSubtitle,
      ),
    );
  }
}
