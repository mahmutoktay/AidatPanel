import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    final items = _buildBodyItems(context, duesState, highlightDueId);

    return RefreshIndicator(
      onRefresh: () => ref.read(duesNotifierProvider.notifier).loadMyDues(),
      child: ListView.builder(
        padding: AppSizes.screenBodyScrollPadding,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is _LoadingItem) {
            return const Padding(
              padding: EdgeInsets.only(top: AppSizes.spacingXL),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (item is _EmptyStateItem) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSizes.spacingXL),
              child: Center(
                child: Text(
                  context.t.common.noDuesYet,
                  style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
                ),
              ),
            );
          }
          if (item is _ActionButtonsItem) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildActionButtons(context),
            );
          }
          if (item is _SectionHeaderItem) {
            return Text(
              item.title,
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            );
          }
          if (item is _DueCardItem) {
            return _buildDueCard(
              context,
              item.due,
              highlighted: item.highlighted,
            );
          }
          if (item is _SpacingItem) {
            return SizedBox(height: item.height);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<_ResidentDuesRowItem> _buildBodyItems(
    BuildContext context,
    DuesState duesState,
    String? highlightDueId,
  ) {
    if (duesState.isLoading) {
      return const [_LoadingItem()];
    }

    if (duesState.dues.isEmpty) {
      return const [_EmptyStateItem()];
    }

    final split = splitResidentDuesForDisplay(duesState.dues);
    final items = <_ResidentDuesRowItem>[
      const _ActionButtonsItem(),
    ];

    if (split.current.isNotEmpty) {
      items.add(_SectionHeaderItem(context.t.common.currentPeriodDue));
      items.add(const _SpacingItem(AppSizes.spacingM));
      for (final due in split.current) {
        items.add(_DueCardItem(
          due,
          highlighted: highlightDueId == null || highlightDueId == due.id,
        ));
      }
    }

    if (split.past.isNotEmpty) {
      if (split.current.isNotEmpty) {
        items.add(const _SpacingItem(AppSizes.spacingL));
      }
      items.add(_SectionHeaderItem(context.t.common.myPastDues));
      items.add(const _SpacingItem(AppSizes.spacingM));
      for (final due in split.past) {
        items.add(_DueCardItem(
          due,
          highlighted: highlightDueId == due.id,
        ));
      }
    }

    return items;
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final t = context.t.features.dekont;
    return [
      Row(
        children: [
          Expanded(
            child: Material(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => context.push('/resident-dashboard/payment'),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Icon(Icons.payment_outlined, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        t.makePaymentTitle,
                        style: AppTypography.button.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Material(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => context.push('/resident-dashboard/dekonts'),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Icon(Icons.receipt_long_outlined, color: AppColors.textPrimary),
                      const SizedBox(height: 8),
                      Text(
                        t.myDekontsTitle,
                        style: AppTypography.button.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
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
        color: highlighted ? AppColors.primary.withValues(alpha: 0.08) : AppColors.fill,
        borderRadius: BorderRadius.circular(20),
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

sealed class _ResidentDuesRowItem {
  const _ResidentDuesRowItem();
}

class _LoadingItem extends _ResidentDuesRowItem {
  const _LoadingItem();
}

class _EmptyStateItem extends _ResidentDuesRowItem {
  const _EmptyStateItem();
}

class _ActionButtonsItem extends _ResidentDuesRowItem {
  const _ActionButtonsItem();
}

class _SectionHeaderItem extends _ResidentDuesRowItem {
  final String title;
  const _SectionHeaderItem(this.title);
}

class _DueCardItem extends _ResidentDuesRowItem {
  final DueEntity due;
  final bool highlighted;
  const _DueCardItem(this.due, {required this.highlighted});
}

class _SpacingItem extends _ResidentDuesRowItem {
  final double height;
  const _SpacingItem(this.height);
}
