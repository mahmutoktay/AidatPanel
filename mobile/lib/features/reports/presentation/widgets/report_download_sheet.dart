import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/api_user_message.dart';
import '../../../../core/utils/month_labels.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_select_field.dart';
import '../../../../shared/widgets/sliding_segmented_control.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../domain/entities/report_entity.dart';
import '../providers/report_provider.dart';
import '../screens/report_preview_screen.dart';

class ReportDownloadSheet extends ConsumerStatefulWidget {
  const ReportDownloadSheet({super.key, required this.building});

  final BuildingEntity building;

  static Future<void> show(
    BuildContext context, {
    required BuildingEntity building,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ReportDownloadSheet(building: building),
    );
  }

  @override
  ConsumerState<ReportDownloadSheet> createState() =>
      _ReportDownloadSheetState();
}

class _ReportDownloadSheetState extends ConsumerState<ReportDownloadSheet> {
  ReportType _type = ReportType.monthly;
  late int _month;
  late int _year;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
  }

  List<int> get _yearOptions {
    final current = DateTime.now().year;
    return [current, current - 1, current - 2];
  }

  String _previewSubtitle(BuildContext context) {
    if (_type == ReportType.annual) {
      return '${widget.building.name} · $_year';
    }
    final monthLabel = localizedMonthName(context, _month);
    return '${widget.building.name} · $monthLabel $_year';
  }

  String _periodSummary(BuildContext context) {
    final t = context.t.features.reports;
    if (_type == ReportType.annual) {
      return t.periodHintAnnual.replaceAll('{year}', '$_year');
    }
    return t.periodHintMonthly
        .replaceAll('{month}', localizedMonthName(context, _month))
        .replaceAll('{year}', '$_year');
  }

  Future<void> _onShowReport() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final result = await ref.read(reportServiceProvider).fetchReport(
            ReportDownloadParams(
              buildingId: widget.building.id,
              buildingName: widget.building.name,
              type: _type,
              year: _year,
              month: _type == ReportType.monthly ? _month : null,
            ),
          );

      if (!mounted) return;
      final navigator = Navigator.of(context);
      navigator.pop();
      await navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ReportPreviewScreen(
            result: result,
            subtitle: _previewSubtitle(context),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userFacingError(e, context: ApiMessageContext.general)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.reports;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.spacingL,
        AppSizes.spacingS,
        AppSizes.spacingL,
        AppSizes.spacingL + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderColor.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.fill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderColor.withValues(alpha: 0.14),
                    width: 0.5,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.sheetTitle,
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.building.name,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              InkResponse(
                onTap: () => Navigator.of(context).pop(),
                radius: 24,
                child: Container(
                  width: AppSizes.minTouchTarget,
                  height: AppSizes.minTouchTarget,
                  alignment: Alignment.center,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.fill,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderColor.withValues(alpha: 0.14),
                        width: 0.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingL),
          Text(
            t.reportTypeLabel,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          SlidingSegmentedControl(
            segments: [t.typeMonthly, t.typeAnnual],
            selectedIndex: _type == ReportType.monthly ? 0 : 1,
            enabled: !_isLoading,
            onChanged: (index) => setState(
              () => _type = index == 0 ? ReportType.monthly : ReportType.annual,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            _periodSummary(context),
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            children: [
              if (_type == ReportType.monthly) ...[
                Expanded(
                  child: AppSelectField<int>(
                    label: t.fieldMonth,
                    sheetTitle: t.selectMonthTitle,
                    value: _month,
                    enabled: !_isLoading,
                    displayText: (v) =>
                        v == null ? '' : localizedMonthName(context, v),
                    options: [
                      for (var m = 1; m <= 12; m++)
                        AppSelectOption(
                          value: m,
                          label: localizedMonthName(context, m),
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _month = v);
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.spacingS),
              ],
              Expanded(
                child: AppSelectField<int>(
                  label: t.fieldYear,
                  sheetTitle: t.selectYearTitle,
                  value: _year,
                  enabled: !_isLoading,
                  displayText: (v) => v == null ? '' : '$v',
                  options: [
                    for (final y in _yearOptions)
                      AppSelectOption(value: y, label: '$y'),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _year = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingL),
          SizedBox(
            height: AppSizes.minTouchTargetComfort,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _onShowReport,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: Text(_isLoading ? t.downloading : t.download),
            ),
          ),
        ],
      ),
    );
  }
}
