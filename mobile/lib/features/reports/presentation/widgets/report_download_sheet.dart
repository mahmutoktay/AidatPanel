import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/api_user_message.dart';
import '../../../../core/utils/month_labels.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
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
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
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

  Future<void> _pickMonth(BuildContext context) async {
    if (_isLoading) return;
    final t = context.t.features.reports;
    final picked = await PremiumBottomSheetScaffold.show<int>(
      context: context,
      builder: (ctx) => PremiumBottomSheetScaffold(
        title: t.selectMonthTitle,
        scrollable: true,
        body: PremiumActionSheetList(
          children: [
            for (var month = 1; month <= 12; month++)
              PremiumActionSheetTile(
                icon: Icons.calendar_month_outlined,
                label: localizedMonthName(context, month),
                trailing: _month == month
                    ? Icon(Icons.check_rounded, color: AppColors.inkDark)
                    : null,
                onTap: () => Navigator.pop(ctx, month),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _month = picked);
  }

  Future<void> _pickYear(BuildContext context) async {
    if (_isLoading) return;
    final t = context.t.features.reports;
    final picked = await PremiumBottomSheetScaffold.show<int>(
      context: context,
      builder: (ctx) => PremiumBottomSheetScaffold(
        title: t.selectYearTitle,
        scrollable: true,
        body: PremiumActionSheetList(
          children: [
            for (final year in _yearOptions)
              PremiumActionSheetTile(
                icon: Icons.date_range_outlined,
                label: '$year',
                trailing: _year == year
                    ? Icon(Icons.check_rounded, color: AppColors.inkDark)
                    : null,
                onTap: () => Navigator.pop(ctx, year),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _year = picked);
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

    return PremiumBottomSheetScaffold(
      scrollable: false,
      header: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spacingL,
          AppSizes.spacingM,
          AppSizes.spacingS,
          AppSizes.spacingS,
        ),
        child: Row(
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
              child: Icon(
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
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              style: IconButton.styleFrom(
                minimumSize: const Size(
                  AppSizes.minTouchTarget,
                  AppSizes.minTouchTarget,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  child: MinimalPickerField(
                    label: t.fieldMonth,
                    value: localizedMonthName(context, _month),
                    hint: t.fieldMonth,
                    icon: Icons.calendar_month_outlined,
                    enabled: !_isLoading,
                    onTap: () => _pickMonth(context),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingS),
              ],
              Expanded(
                child: MinimalPickerField(
                  label: t.fieldYear,
                  value: '$_year',
                  hint: t.fieldYear,
                  icon: Icons.date_range_outlined,
                  enabled: !_isLoading,
                  onTap: () => _pickYear(context),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: PremiumSheetActions(
        primaryLabel: _isLoading ? t.downloading : t.download,
        onPrimary: _isLoading ? null : _onShowReport,
        primaryLoading: _isLoading,
        icon: Icons.picture_as_pdf_outlined,
      ),
    );
  }
}
