import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/app_currency_format.dart';
import '../../../../../core/utils/app_intl_locale.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../domain/entities/manager_dashboard_entities.dart';
import '../../utils/manager_overdue_remind_helper.dart';
import 'manager_dashboard_card.dart';

/// Bankacılık tarzı aidat özet kartı — toplanan/beklenen + progress + gecikmiş + Hatırlat.
class ManagerDuesSummaryCard extends ConsumerStatefulWidget {
  final ManagerDuesAmountSummary summary;
  final String currency;
  final Map<String, List<String>>? remindDueIdsByBuilding;

  const ManagerDuesSummaryCard({
    super.key,
    required this.summary,
    this.currency = 'TRY',
    this.remindDueIdsByBuilding,
  });

  @override
  ConsumerState<ManagerDuesSummaryCard> createState() =>
      _ManagerDuesSummaryCardState();
}

class _ManagerDuesSummaryCardState extends ConsumerState<ManagerDuesSummaryCard> {
  bool _isReminding = false;

  int get _overdueCount {
    final remindMap = widget.remindDueIdsByBuilding;
    if (remindMap != null && remindMap.isNotEmpty) {
      return overdueDueCount(remindMap);
    }
    return widget.summary.overdueCount;
  }

  bool get _showRemind =>
      widget.remindDueIdsByBuilding != null &&
      overdueDueCount(widget.remindDueIdsByBuilding!) > 0;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final languageCode = AppIntlLocale.fromContext(context);
    final symbol =
        widget.currency == 'TRY' ? AppCurrencyFormat.symbol : widget.currency;
    final collectedText = AppCurrencyFormat.format(
      widget.summary.collectedAmount,
      languageCode: languageCode,
      decimalDigits: 0,
    ).replaceAll(AppCurrencyFormat.symbol, symbol);
    final expectedText = AppCurrencyFormat.format(
      widget.summary.expectedAmount,
      languageCode: languageCode,
      decimalDigits: 0,
    ).replaceAll(AppCurrencyFormat.symbol, symbol);
    final progress = widget.summary.expectedAmount <= 0
        ? 0.0
        : (widget.summary.collectedAmount / widget.summary.expectedAmount)
            .clamp(0.0, 1.0);

    return ManagerDashboardCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            text: TextSpan(
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                height: 1.1,
              ),
              children: [
                TextSpan(text: collectedText),
                TextSpan(
                  text: ' / $expectedText',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppColors.lineLight,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
            ),
          ),
          if (_overdueCount > 0) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: AppColors.chartRed,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t.overdueDuesBadge.replaceAll(
                      '{count}',
                      '$_overdueCount',
                    ),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.chartRed,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (_showRemind) ...[
                  const SizedBox(width: 8),
                  _CompactRemindButton(
                    isLoading: _isReminding,
                    onPressed: _isReminding ? null : _onRemindPressed,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _onRemindPressed() async {
    final dueIdsByBuilding = widget.remindDueIdsByBuilding;
    if (dueIdsByBuilding == null || dueIdsByBuilding.isEmpty) return;

    await remindOverdueDuesByBuilding(
      context: context,
      ref: ref,
      dueIdsByBuilding: dueIdsByBuilding,
      onLoadingChanged: (isLoading) {
        if (!mounted) return;
        setState(() => _isReminding = isLoading);
      },
    );
  }
}

class _CompactRemindButton extends StatelessWidget {
  const _CompactRemindButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  static const double _width = 88;
  static const double _height = 28;

  @override
  Widget build(BuildContext context) {
    final label = context.t.features.dashboard.remind;

    return SizedBox(
      width: _width,
      height: _height,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: isLoading
            ? const Center(
                key: ValueKey('loading'),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : FilledButton(
                key: const ValueKey('idle'),
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.action,
                  foregroundColor: AppColors.onAction,
                  minimumSize: const Size(_width, _height),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onAction,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
      ),
    );
  }
}
