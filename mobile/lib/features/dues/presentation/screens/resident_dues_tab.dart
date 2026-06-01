import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../domain/entities/due_entity.dart';
import '../../domain/resident_dues_list.dart';
import '../providers/dues_provider.dart';

class ResidentDuesTab extends ConsumerStatefulWidget {
  const ResidentDuesTab({super.key});

  @override
  ConsumerState<ResidentDuesTab> createState() => _ResidentDuesTabState();
}

class _ResidentDuesTabState extends ConsumerState<ResidentDuesTab> {
  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    final duesState = ref.watch(duesNotifierProvider);
    final highlightDueId = ref.watch(residentDueHighlightIdProvider);

    if (!_requested) {
      _requested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(duesNotifierProvider.notifier).loadMyDues();
      });
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(duesNotifierProvider.notifier).loadMyDues(),
      child: ListView(
        padding: AppSizes.screenBodyScrollPadding,
        children: _buildBody(context, duesState, highlightDueId),
      ),
    );
  }

  List<Widget> _buildBody(
    BuildContext context,
    DuesState duesState,
    String? highlightDueId,
  ) {
    if (duesState.isLoading) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: AppSizes.spacingXL),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (duesState.dues.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: AppSizes.spacingXL),
          child: Center(
            child: Text(
              context.t.common.noDuesYet,
              style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
      ];
    }

    final split = splitResidentDuesForDisplay(duesState.dues);
    final children = <Widget>[
      ..._buildActionButtons(context),
    ];

    if (split.current.isNotEmpty) {
      children.addAll([
        Text(
          context.t.common.currentPeriodDue,
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSizes.spacingM),
        for (final due in split.current)
          _buildDueCard(
            context,
            due,
            highlighted:
                highlightDueId == null || highlightDueId == due.id,
          ),
      ]);
    }

    if (split.past.isNotEmpty) {
      if (split.current.isNotEmpty) {
        children.add(const SizedBox(height: AppSizes.spacingL));
      }
      children.addAll([
        Text(
          context.t.common.myPastDues,
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSizes.spacingM),
        for (final due in split.past)
          _buildDueCard(
            context,
            due,
            highlighted: highlightDueId == due.id,
          ),
      ]);
    }

    return children;
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final t = context.t.features.dekont;
    return [
      Row(
        children: [
          Expanded(
            child: SizedBox(
              height: AppSizes.buttonHeightSecondary,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/resident-dashboard/payment'),
                style: AppButtonStyles.elevatedPayment(),
                icon: const Icon(Icons.payment_outlined),
                label: Text(t.makePaymentTitle),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: SizedBox(
              height: AppSizes.buttonHeightSecondary,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/resident-dashboard/dekonts'),
                icon: const Icon(Icons.receipt_long_outlined),
                label: Text(t.myDekontsTitle),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSizes.spacingL),
    ];
  }

  Widget _buildDueCard(
    BuildContext context,
    DueEntity due, {
    required bool highlighted,
  }) {
    final statusVisual = _statusVisual(context, due.status);
    final periodLabel =
        '${_monthName(context, due.month)} ${due.year} • ${context.t.common.apartmentLabel} ${due.apartmentNumber}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.fill : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: highlighted
            ? Border.all(color: AppColors.primary, width: 2)
            : AppColors.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  periodLabel,
                  style: (highlighted ? AppTypography.h3 : AppTypography.h4)
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusVisual.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusVisual.label,
                  style: AppTypography.caption.copyWith(
                    color: statusVisual.fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            '₺${due.amount.toStringAsFixed(2)}',
            style: (highlighted ? AppTypography.h3 : AppTypography.bodyLarge)
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  String _monthName(BuildContext context, int month) {
    final t = context.t.common;
    switch (month) {
      case 1:
        return t.monthJanuary;
      case 2:
        return t.monthFebruary;
      case 3:
        return t.monthMarch;
      case 4:
        return t.monthApril;
      case 5:
        return t.monthMay;
      case 6:
        return t.monthJune;
      case 7:
        return t.monthJuly;
      case 8:
        return t.monthAugust;
      case 9:
        return t.monthSeptember;
      case 10:
        return t.monthOctober;
      case 11:
        return t.monthNovember;
      case 12:
        return t.monthDecember;
      default:
        return '$month';
    }
  }

  _StatusVisual _statusVisual(BuildContext context, DueStatus status) {
    switch (status) {
      case DueStatus.paid:
        return _StatusVisual(
          label: context.t.common.paidStatus,
          fg: AppColors.success,
          bg: AppColors.successBg,
        );
      case DueStatus.overdue:
        return _StatusVisual(
          label: context.t.common.overdueStatus,
          fg: AppColors.error,
          bg: AppColors.errorBg,
        );
      case DueStatus.waived:
        return _StatusVisual(
          label: context.t.common.waivedStatus,
          fg: AppColors.textSecondary,
          bg: AppColors.fill,
        );
      case DueStatus.pending:
        return _StatusVisual(
          label: context.t.common.pendingStatus,
          fg: AppColors.warning,
          bg: AppColors.warningBg,
        );
    }
  }
}

class _StatusVisual {
  final String label;
  final Color fg;
  final Color bg;

  const _StatusVisual({
    required this.label,
    required this.fg,
    required this.bg,
  });
}
