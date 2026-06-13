import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/api_user_message.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
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

  String _previewSubtitle() {
    if (_type == ReportType.annual) {
      return '${widget.building.name} · $_year';
    }
    return '${widget.building.name} · $_month/$_year';
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
            subtitle: _previewSubtitle(),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.spacingM,
        AppSizes.spacingS,
        AppSizes.spacingM,
        AppSizes.spacingM + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            t.sheetTitle,
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.building.name,
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.spacingM),
          SegmentedButton<ReportType>(
            segments: [
              ButtonSegment(
                value: ReportType.monthly,
                label: Text(t.typeMonthly),
              ),
              ButtonSegment(
                value: ReportType.annual,
                label: Text(t.typeAnnual),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (value) {
              setState(() => _type = value.first);
            },
          ),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            children: [
              if (_type == ReportType.monthly) ...[
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _month,
                    decoration: InputDecoration(
                      labelText: t.fieldMonth,
                      isDense: true,
                    ),
                    items: List.generate(12, (i) {
                      final m = i + 1;
                      return DropdownMenuItem(
                        value: m,
                        child: Text('$m'),
                      );
                    }),
                    onChanged: _isLoading
                        ? null
                        : (v) {
                            if (v != null) setState(() => _month = v);
                          },
                  ),
                ),
                const SizedBox(width: AppSizes.spacingS),
              ],
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _year,
                  decoration: InputDecoration(
                    labelText: t.fieldYear,
                    isDense: true,
                  ),
                  items: _yearOptions
                      .map(
                        (y) => DropdownMenuItem(
                          value: y,
                          child: Text('$y'),
                        ),
                      )
                      .toList(),
                  onChanged: _isLoading
                      ? null
                      : (v) {
                          if (v != null) setState(() => _year = v);
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
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
