import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/strings.g.dart';
import '../domain/feature_tour_models.dart';
import 'feature_tour_provider.dart';
import 'feature_tour_targets.dart';

/// Delikli karartma + açıklama kartı (İleri / Atla).
class FeatureTourOverlay extends ConsumerWidget {
  const FeatureTourOverlay({super.key});

  static const double _holePadding = 8;
  static const double _holeRadius = 12;
  static const double _cardMaxWidth = 360;
  static const double _gap = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourState = ref.watch(featureTourProvider);
    final step = tourState.currentStep;
    if (!tourState.visible || step == null) {
      return const SizedBox.shrink();
    }

    final rect = FeatureTourTargets.rectFor(step);
    if (rect == null) {
      return const SizedBox.shrink();
    }

    final t = context.t.features.featureTour;
    final (title, body) = _copyFor(t, tourState.tourId!, step);
    final media = MediaQuery.of(context);
    final screen = media.size;
    final hole = Rect.fromLTRB(
      (rect.left - _holePadding).clamp(0.0, screen.width),
      (rect.top - _holePadding).clamp(0.0, screen.height),
      (rect.right + _holePadding).clamp(0.0, screen.width),
      (rect.bottom + _holePadding).clamp(0.0, screen.height),
    );

    final spaceBelow = screen.height - hole.bottom - media.padding.bottom;
    final preferBelow = spaceBelow >= 200;
    final cardTop = preferBelow
        ? hole.bottom + _gap
        : (hole.top - _gap - 220).clamp(media.padding.top + 8, hole.top - _gap);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _SpotlightPainter(hole: hole, radius: _holeRadius),
          ),
        ),
        // Karartmaya tıklama adım ilerletmez; kart üstte olduğu için butonlar çalışır.
        const Positioned.fill(
          child: ModalBarrier(dismissible: false, color: Colors.transparent),
        ),
        Positioned(
          left: AppSizes.spacingM,
          right: AppSizes.spacingM,
          top: cardTop,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _cardMaxWidth,
                maxHeight: screen.height * 0.42,
              ),
              child: Material(
                color: AppColors.surface,
                elevation: 6,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacingM),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${tourState.stepIndex + 1} / ${tourState.steps.length}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingS),
                        Text(
                          title,
                          style: AppTypography.h4.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingS),
                        Text(
                          body,
                          style: AppTypography.body1.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: AppSizes.spacingM),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: AppSizes.buttonHeightSecondary,
                                child: TextButton(
                                  onPressed: () => ref
                                      .read(featureTourProvider.notifier)
                                      .skip(),
                                  child: Text(
                                    t.skip,
                                    style: AppTypography.button.copyWith(
                                      color: AppColors.brand,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.spacingS),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: AppSizes.buttonHeightPrimary,
                                child: ElevatedButton(
                                  style: AppButtonStyles.elevatedPrimary(
                                    fullWidth: true,
                                  ),
                                  onPressed: () => ref
                                      .read(featureTourProvider.notifier)
                                      .next(),
                                  child: Text(
                                    tourState.isLastStep ? t.done : t.next,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  (String, String) _copyFor(
    dynamic t,
    FeatureTourId tourId,
    FeatureTourStepId step,
  ) {
    return switch ((tourId, step)) {
      (FeatureTourId.managerHome, FeatureTourStepId.buildingSelector) => (
          t.managerSelectorTitle as String,
          t.managerSelectorBody as String,
        ),
      (FeatureTourId.managerHome, FeatureTourStepId.summary) => (
          t.managerSummaryTitle as String,
          t.managerSummaryBody as String,
        ),
      (FeatureTourId.managerHome, FeatureTourStepId.quickActions) => (
          t.managerQuickTitle as String,
          t.managerQuickBody as String,
        ),
      (FeatureTourId.managerHome, FeatureTourStepId.bottomNav) => (
          t.managerNavTitle as String,
          t.managerNavBody as String,
        ),
      (FeatureTourId.managerHome, FeatureTourStepId.notifications) => (
          t.managerNotifTitle as String,
          t.managerNotifBody as String,
        ),
      (FeatureTourId.residentHome, FeatureTourStepId.summary) => (
          t.residentSummaryTitle as String,
          t.residentSummaryBody as String,
        ),
      (FeatureTourId.residentHome, FeatureTourStepId.quickActions) => (
          t.residentQuickTitle as String,
          t.residentQuickBody as String,
        ),
      (FeatureTourId.residentHome, FeatureTourStepId.bottomNav) => (
          t.residentNavTitle as String,
          t.residentNavBody as String,
        ),
      (FeatureTourId.residentHome, FeatureTourStepId.notifications) => (
          t.residentNotifTitle as String,
          t.residentNotifBody as String,
        ),
      _ => (
          t.managerNavTitle as String,
          t.managerNavBody as String,
        ),
    };
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect hole;
  final double radius;

  _SpotlightPainter({required this.hole, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()..addRect(Offset.zero & size);
    final cutout = Path()
      ..addRRect(
        RRect.fromRectAndRadius(hole, Radius.circular(radius)),
      );
    final path = Path.combine(PathOperation.difference, overlay, cutout);
    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.62),
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.hole != hole || oldDelegate.radius != radius;
  }
}
