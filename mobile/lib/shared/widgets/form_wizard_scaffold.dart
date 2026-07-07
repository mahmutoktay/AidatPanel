import 'package:flutter/material.dart';

import '../../core/theme/app_sizes.dart';
import 'dashboard_secondary_scaffold.dart';
import 'form_step_indicator.dart';
import 'wizard_step_actions.dart';

/// Çok adımlı form iskeleti: başlık, adım göstergesi, içerik, inline aksiyonlar.
class FormWizardScaffold extends StatelessWidget {
  final String title;
  final List<FormStepDescriptor> steps;
  final int currentStep;
  final Widget stepBody;
  final String primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final bool primaryLoading;
  final bool showStepActions;
  final bool absorbing;
  final VoidCallback onBack;
  final bool canPop;

  const FormWizardScaffold({
    super.key,
    required this.title,
    required this.steps,
    required this.currentStep,
    required this.stepBody,
    required this.primaryActionLabel,
    required this.onBack,
    this.onPrimaryAction,
    this.primaryLoading = false,
    this.showStepActions = true,
    this.absorbing = false,
    this.canPop = true,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSecondaryScaffold(
      title: title,
      canPop: canPop && !primaryLoading,
      useMinimalBackButton: true,
      onBack: primaryLoading ? null : onBack,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!primaryLoading) onBack();
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormStepIndicator(steps: steps, currentStep: currentStep),
          Expanded(
            child: SafeArea(
              top: false,
              child: AbsorbPointer(
                absorbing: absorbing || primaryLoading,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: KeyedSubtree(
                    key: ValueKey<int>(currentStep),
                    child: SingleChildScrollView(
                      padding: AppSizes.screenBodyScrollPadding.copyWith(
                        top: AppSizes.spacingS,
                        bottom: AppSizes.spacingXL,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          stepBody,
                          if (showStepActions)
                            WizardStepActions(
                              primaryLabel: primaryActionLabel,
                              onPrimary: onPrimaryAction,
                              onBack: onBack,
                              isLoading: primaryLoading,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
