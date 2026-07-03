import 'package:flutter/material.dart';

import '../../../domain/entities/user_entity.dart';
import 'onboarding_fixed_choice_layout.dart';
import 'onboarding_role_cards.dart';

/// Adım 1 — rol seçimi tam ekran düzeni.
class OnboardingRoleStep extends StatelessWidget {
  const OnboardingRoleStep({
    super.key,
    required this.title,
    required this.managerLabel,
    required this.residentLabel,
    required this.selectedRole,
    required this.onManagerTap,
    required this.onResidentTap,
    this.enabled = true,
  });

  final String title;
  final String managerLabel;
  final String residentLabel;
  final UserRole? selectedRole;
  final VoidCallback onManagerTap;
  final VoidCallback onResidentTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return OnboardingFixedChoiceLayout(
      title: title,
      centerTitle: true,
      choices: OnboardingRoleCards(
        selectedRole: selectedRole,
        managerLabel: managerLabel,
        residentLabel: residentLabel,
        onManagerTap: onManagerTap,
        onResidentTap: onResidentTap,
        enabled: enabled,
      ),
    );
  }
}
