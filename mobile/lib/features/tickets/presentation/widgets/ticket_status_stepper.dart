import 'package:flutter/material.dart';

import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/ticket_entity.dart';
import '../utils/ticket_status_style.dart';

/// Sakin talep detayı — yatay durum izleyici.
/// Reddedilmiş (`CLOSED`) taleplerde doğrusal yol yerine tek durum gösterilir.
class TicketStatusStepper extends StatelessWidget {
  final TicketStatus currentStatus;

  const TicketStatusStepper({super.key, required this.currentStatus});

  static const _happyPath = [
    TicketStatus.open,
    TicketStatus.inProgress,
    TicketStatus.resolved,
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.tickets;
    final headline = _headline(context, currentStatus);
    final headlineColor = ticketStatusColor(currentStatus);

    if (currentStatus == TicketStatus.closed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.spacingM),
        decoration: DashboardScreenStyle.whiteCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _trackerBadge(t.statusTrackerTitle),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: AppTypography.h4.copyWith(
                color: headlineColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: headlineColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              t.statusStepClosed,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = _happyPath.indexOf(currentStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: DashboardScreenStyle.whiteCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _trackerBadge(t.statusTrackerTitle),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: AppTypography.h4.copyWith(
              color: headlineColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _happyPath.length; i++)
                Expanded(
                  child: _StepColumn(
                    stepIndex: i,
                    displayNumber: i + 1,
                    label: _stepLabel(context, _happyPath[i]),
                    icon: _stepIcon(_happyPath[i]),
                    isFirst: i == 0,
                    isLast: i == _happyPath.length - 1,
                    currentIndex: currentIndex,
                    activeColor: ticketStatusColor(_happyPath[i]),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trackerBadge(String title) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: AppTypography.caption.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  String _headline(BuildContext context, TicketStatus status) {
    final t = context.t.features.tickets;
    switch (status) {
      case TicketStatus.open:
        return t.statusHeadlineOpen;
      case TicketStatus.inProgress:
        return t.statusHeadlineInProgress;
      case TicketStatus.resolved:
        return t.statusHeadlineResolved;
      case TicketStatus.closed:
        return t.statusHeadlineClosed;
    }
  }

  String _stepLabel(BuildContext context, TicketStatus status) {
    final t = context.t.features.tickets;
    switch (status) {
      case TicketStatus.open:
        return t.statusStepWaiting;
      case TicketStatus.inProgress:
        return t.statusStepInProgress;
      case TicketStatus.resolved:
        return t.statusStepResolved;
      case TicketStatus.closed:
        return t.statusStepClosed;
    }
  }

  IconData _stepIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return Icons.hourglass_top_rounded;
      case TicketStatus.inProgress:
        return Icons.verified_outlined;
      case TicketStatus.resolved:
        return Icons.task_alt_rounded;
      case TicketStatus.closed:
        return Icons.cancel_outlined;
    }
  }
}

enum _StepVisualState { completed, active, pending }

class _StepColumn extends StatelessWidget {
  final int stepIndex;
  final int displayNumber;
  final String label;
  final IconData icon;
  final bool isFirst;
  final bool isLast;
  final int currentIndex;
  final Color activeColor;

  const _StepColumn({
    required this.stepIndex,
    required this.displayNumber,
    required this.label,
    required this.icon,
    required this.isFirst,
    required this.isLast,
    required this.currentIndex,
    required this.activeColor,
  });

  _StepVisualState get _state {
    if (stepIndex < currentIndex) return _StepVisualState.completed;
    if (stepIndex == currentIndex) return _StepVisualState.active;
    return _StepVisualState.pending;
  }

  Color get _circleColor {
    if (_state == _StepVisualState.pending) return AppColors.surface;
    if (_state == _StepVisualState.active) return activeColor;
    return AppColors.info;
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final circleColor = _circleColor;
    final iconColor = state == _StepVisualState.pending
        ? AppColors.textDisabled
        : Colors.white;
    final borderColor =
        state == _StepVisualState.pending ? AppColors.border : circleColor;

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isFirst)
                Expanded(
                  child: Container(
                    height: 3,
                    color: _lineColorForLeftSegment(),
                  ),
                ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 2),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 22),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 3,
                    color: _lineColorForRightSegment(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '$displayNumber. $label',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: state == _StepVisualState.pending
                  ? AppColors.textDisabled
                  : AppColors.textPrimary,
              fontWeight: state == _StepVisualState.active
                  ? FontWeight.w800
                  : FontWeight.w600,
              height: 1.2,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Color _lineColorForLeftSegment() {
    return stepIndex <= currentIndex ? AppColors.info : AppColors.border;
  }

  Color _lineColorForRightSegment() {
    return stepIndex < currentIndex ? AppColors.info : AppColors.border;
  }
}
