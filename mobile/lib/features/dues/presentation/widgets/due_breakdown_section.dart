import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/action_chevron.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/due_breakdown_entity.dart';

class DueBreakdownSection extends StatefulWidget {
  final DueBreakdownEntity? breakdown;
  final String currency;
  final bool initiallyExpanded;

  const DueBreakdownSection({
    super.key,
    required this.breakdown,
    required this.currency,
    this.initiallyExpanded = false,
  });

  @override
  State<DueBreakdownSection> createState() => _DueBreakdownSectionState();
}

class _DueBreakdownSectionState extends State<DueBreakdownSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = widget.breakdown;
    if (breakdown == null || !breakdown.hasExtras) {
      return const SizedBox.shrink();
    }

    final t = context.t.features.dekont;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  t.breakdownDetails,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                ActionChevron(
                  direction: _expanded ? ChevronDirection.down : ChevronDirection.right,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSizes.spacingXS),
                  child: Column(
                    children: [
                      _BreakdownRow(
                        label: t.breakdownBaseDue,
                        amount: breakdown.baseAmount,
                        currency: widget.currency,
                      ),
                      for (final line in breakdown.expenseLines)
                        _BreakdownRow(
                          label: line.title,
                          amount: line.amount,
                          currency: widget.currency,
                        ),
                      const Divider(height: 16),
                      _BreakdownRow(
                        label: t.breakdownTotal,
                        amount: breakdown.total,
                        currency: widget.currency,
                        emphasized: true,
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final bool emphasized;

  const _BreakdownRow({
    required this.label,
    required this.amount,
    required this.currency,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = emphasized ? AppTypography.body2 : AppTypography.caption;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: style.copyWith(
                color: AppColors.textSecondary,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            AppCurrencyFormat.formatWithCode(amount, currency),
            style: style.copyWith(
              color: AppColors.textPrimary,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
