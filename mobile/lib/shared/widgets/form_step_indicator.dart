import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../theme/dashboard_screen_style.dart';

class FormStepDescriptor {
  final String label;
  final IconData icon;

  const FormStepDescriptor({required this.label, required this.icon});
}

/// Çok adımlı form wizard'ları için yatay adım göstergesi.
/// Aktif adım ekran dışındaysa otomatik görünür alana kaydırılır.
class FormStepIndicator extends StatefulWidget {
  final List<FormStepDescriptor> steps;
  final int currentStep;

  const FormStepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  State<FormStepIndicator> createState() => _FormStepIndicatorState();
}

class _FormStepIndicatorState extends State<FormStepIndicator> {
  static const _scrollDuration = Duration(milliseconds: 200);
  static const _scrollCurve = Curves.easeInOut;

  late List<GlobalKey> _stepKeys;

  @override
  void initState() {
    super.initState();
    _stepKeys = List.generate(widget.steps.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureCurrentVisible());
  }

  @override
  void didUpdateWidget(FormStepIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.steps.length != widget.steps.length) {
      _stepKeys = List.generate(widget.steps.length, (_) => GlobalKey());
    }
    if (oldWidget.currentStep != widget.currentStep ||
        oldWidget.steps.length != widget.steps.length) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _ensureCurrentVisible());
    }
  }

  void _ensureCurrentVisible() {
    if (!mounted || widget.steps.isEmpty) return;
    final index = widget.currentStep.clamp(0, widget.steps.length - 1);
    final ctx = _stepKeys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: _scrollDuration,
      curve: _scrollCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.dashboardScreenPaddingHorizontal,
        AppSizes.spacingM,
        AppSizes.dashboardScreenPaddingHorizontal,
        AppSizes.spacingS,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingM,
        ),
        decoration: DashboardScreenStyle.whiteCard(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final lineActive = widget.currentStep >= (i ~/ 2) + 1;
              return SizedBox(
                width: 20,
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 18),
                  color: lineActive
                      ? AppColors.action
                      : AppColors.borderColor.withValues(alpha: 0.35),
                ),
              );
            }
            final stepIndex = i ~/ 2;
            final active = widget.currentStep >= stepIndex;
            final completed = widget.currentStep > stepIndex;
            final step = widget.steps[stepIndex];
            return SizedBox(
              key: _stepKeys[stepIndex],
              width: 72,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: active ? AppColors.action : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: active
                            ? AppColors.action
                            : AppColors.borderColor.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      completed ? Icons.check_rounded : step.icon,
                      size: 18,
                      color:
                          active ? AppColors.onAction : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step.label,
                    style: AppTypography.caption.copyWith(
                      color: active
                          ? AppColors.brand
                          : AppColors.textSecondary,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
